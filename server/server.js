const express = require('express');
const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const app = express();

// Global error handlers to prevent Vercel serverless container from crashing on unhandled errors
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
});
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'YOUR_JWT_SECRET';

// Middleware
app.use(cors());
app.use(express.json());

// Create uploads directory path references
const uploadsDir = path.join(__dirname, 'uploads');
const avatarsDir = path.join(uploadsDir, 'avatars');
const scansDir = path.join(uploadsDir, 'scans');

// Create uploads directory if not exists (wrapped in try-catch for read-only systems like Vercel)
try {
  [uploadsDir, avatarsDir, scansDir].forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });
} catch (e) {
  console.warn('Warning: Gagal membuat folder upload (lingkungan read-only seperti Vercel):', e.message);
}

// Serve uploaded files statically
app.use('/uploads', express.static(uploadsDir));

// Database connection configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'eco_db',
  port: process.env.DB_PORT || 3306,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

// Create MySQL Pool
let pool;
async function initializeDb() {
  try {
    pool = mysql.createPool(dbConfig);
    
    // Add error listener to pool to prevent unhandled process crashes
    pool.on('error', (err) => {
      console.error('MySQL Pool error:', err);
    });

    // Test the connection
    const connection = await pool.getConnection();
    console.log('MySQL Database Connected successfully to:', dbConfig.database);
    connection.release();
  } catch (error) {
    console.error('CRITICAL ERROR: Failed to connect to MySQL database.');
    console.error('Message:', error.message);
    console.error('Pastikan MySQL server (XAMPP/Laragon) aktif dan database "eco_db" sudah dibuat menggunakan file "schema.sql".');
  }
}
initializeDb();

// DB Connection Check Middleware
const checkDb = (req, res, next) => {
  if (!pool) {
    return res.status(500).json({ 
      error: 'Database MySQL tidak aktif. Silakan hubungkan XAMPP/Laragon dan jalankan server MySQL.' 
    });
  }
  next();
};

// JWT Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Akses ditolak. Token JWT diperlukan.' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Token JWT tidak valid atau kedaluwarsa.' });
    }
    req.user = user;
    next();
  });
};

// Multer Storage Configuration for Avatar
const avatarStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, avatarsDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `avatar_${req.user.id}_${Date.now()}${ext}`);
  }
});
const uploadAvatar = multer({ storage: avatarStorage });

// Multer Storage Configuration for Scan Images
const scanStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, scansDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `scan_${uuidv4()}${ext}`);
  }
});
const uploadScan = multer({ storage: scanStorage });

// ==========================================
// ── AUTH ENDPOINTS ────────────────────────
// ==========================================

// 1. Register User (Username & Password)
app.post('/api/auth/register', checkDb, async (req, res) => {
  const { username, password, display_name, email } = req.body;

  if (!username || !password || !display_name) {
    return res.status(400).json({ error: 'Username, Password, dan Nama Lengkap wajib diisi.' });
  }

  try {
    // Check if username already exists
    const [existingUsername] = await pool.query('SELECT id FROM users WHERE username = ?', [username]);
    if (existingUsername.length > 0) {
      return res.status(400).json({ error: 'Username sudah terdaftar.' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const userId = uuidv4();
    const newUser = {
      id: userId,
      username,
      password: hashedPassword,
      display_name,
      email: email || null,
      photo_url: null,
      created_at: new Date()
    };

    await pool.query(
      'INSERT INTO users (id, username, password, display_name, email, photo_url, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [newUser.id, newUser.username, newUser.password, newUser.display_name, newUser.email, newUser.photo_url, newUser.created_at]
    );

    // Generate token
    const token = jwt.sign({ id: newUser.id, username: newUser.username }, JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({
      token,
      user: {
        id: newUser.id,
        username: newUser.username,
        display_name: newUser.display_name,
        email: newUser.email,
        photo_url: newUser.photo_url,
        created_at: newUser.created_at
      }
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Terjadi kesalahan server saat registrasi.' });
  }
});

// 2. Login User (Username & Password)
app.post('/api/auth/login', checkDb, async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: 'Username dan Password wajib diisi.' });
  }

  try {
    // Find user by username
    const [users] = await pool.query('SELECT * FROM users WHERE username = ?', [username]);
    if (users.length === 0) {
      return res.status(400).json({ error: 'Username atau password salah.' });
    }

    const user = users[0];

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Username atau password salah.' });
    }

    // Generate token
    const token = jwt.sign({ id: user.id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        display_name: user.display_name,
        email: user.email,
        photo_url: user.photo_url,
        created_at: user.created_at
      }
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Terjadi kesalahan server saat login.' });
  }
});

// ==========================================
// ── PROFILE ENDPOINTS ──────────────────────
// ==========================================

// Get current profile
app.get('/api/profile', checkDb, authenticateToken, async (req, res) => {
  try {
    const [users] = await pool.query('SELECT id, username, display_name, email, photo_url, created_at FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) {
      return res.status(404).json({ error: 'Profil tidak ditemukan.' });
    }
    res.json(users[0]);
  } catch (error) {
    res.status(500).json({ error: 'Gagal mengambil data profil.' });
  }
});

// Update profile fields
app.put('/api/profile', checkDb, authenticateToken, async (req, res) => {
  const { display_name } = req.body;
  if (!display_name) {
    return res.status(400).json({ error: 'Nama Lengkap wajib diisi.' });
  }

  try {
    await pool.query('UPDATE users SET display_name = ? WHERE id = ?', [display_name, req.user.id]);
    
    const [users] = await pool.query('SELECT id, username, display_name, email, photo_url, created_at FROM users WHERE id = ?', [req.user.id]);
    res.json(users[0]);
  } catch (error) {
    res.status(500).json({ error: 'Gagal memperbarui profil.' });
  }
});

// Upload and Update Avatar
app.post('/api/profile/avatar', checkDb, authenticateToken, uploadAvatar.single('avatar'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Pilih file gambar untuk diunggah.' });
  }

  try {
    // Fetch current photo_url to delete old file
    const [users] = await pool.query('SELECT photo_url FROM users WHERE id = ?', [req.user.id]);
    if (users.length > 0 && users[0].photo_url) {
      const oldPath = path.join(__dirname, users[0].photo_url);
      if (fs.existsSync(oldPath)) {
        fs.unlinkSync(oldPath);
      }
    }

    // Save relative path to DB
    const relativePath = `uploads/avatars/${req.file.filename}`;
    await pool.query('UPDATE users SET photo_url = ? WHERE id = ?', [relativePath, req.user.id]);

    const [updatedUser] = await pool.query('SELECT id, username, display_name, email, photo_url, created_at FROM users WHERE id = ?', [req.user.id]);
    res.json(updatedUser[0]);
  } catch (error) {
    res.status(500).json({ error: 'Gagal mengunggah foto profil.' });
  }
});

// Delete Avatar
app.delete('/api/profile/avatar', checkDb, authenticateToken, async (req, res) => {
  try {
    const [users] = await pool.query('SELECT photo_url FROM users WHERE id = ?', [req.user.id]);
    if (users.length > 0 && users[0].photo_url) {
      const oldPath = path.join(__dirname, users[0].photo_url);
      if (fs.existsSync(oldPath)) {
        fs.unlinkSync(oldPath);
      }
    }

    await pool.query('UPDATE users SET photo_url = NULL WHERE id = ?', [req.user.id]);
    
    const [updatedUser] = await pool.query('SELECT id, username, display_name, email, photo_url, created_at FROM users WHERE id = ?', [req.user.id]);
    res.json(updatedUser[0]);
  } catch (error) {
    res.status(500).json({ error: 'Gagal menghapus foto profil.' });
  }
});

// ==========================================
// ── SCANS ENDPOINTS ────────────────────────
// ==========================================

// Upload Image (Multipart)
app.post('/api/scans/upload', checkDb, authenticateToken, uploadScan.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Pilih file gambar untuk diunggah.' });
  }
  const relativePath = `uploads/scans/${req.file.filename}`;
  res.json({ image_url: relativePath });
});

// Save Scan Result
app.post('/api/scans', checkDb, authenticateToken, async (req, res) => {
  const { 
    image_url, 
    scan_type,
    environment_condition, 
    impact_prediction, 
    suggestions, 
    contacts, 
    correct_disposal,
    teacher_material,
    trash_classification,
    recycling_info,
    raw_ai_response,
    latitude,
    longitude,
    location_name
  } = req.body;

  if (!image_url) {
    return res.status(400).json({ error: 'Gambar wajib disertakan.' });
  }

  try {
    const scanId = uuidv4();
    const contactsStr = typeof contacts === 'string' ? contacts : JSON.stringify(contacts || []);

    await pool.query(
      'INSERT INTO scan_results (id, user_id, image_url, scan_type, environment_condition, impact_prediction, suggestions, contacts, correct_disposal, teacher_material, trash_classification, recycling_info, raw_ai_response, latitude, longitude, location_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        scanId, 
        req.user.id, 
        image_url, 
        scan_type || 'multiple', 
        environment_condition || '', 
        impact_prediction || '', 
        suggestions || '', 
        contactsStr, 
        correct_disposal || '', 
        teacher_material || '', 
        trash_classification || '', 
        recycling_info || '', 
        raw_ai_response || '', 
        latitude, 
        longitude, 
        location_name
      ]
    );

    const [scans] = await pool.query('SELECT * FROM scan_results WHERE id = ?', [scanId]);
    res.status(201).json(scans[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal menyimpan hasil scan.' });
  }
});

// Get Scan History
app.get('/api/scans', checkDb, authenticateToken, async (req, res) => {
  try {
    const [scans] = await pool.query(
      'SELECT * FROM scan_results WHERE user_id = ? ORDER BY created_at DESC', 
      [req.user.id]
    );
    res.json(scans);
  } catch (error) {
    res.status(500).json({ error: 'Gagal memuat riwayat scan.' });
  }
});

// Get Scan count
app.get('/api/scans/count', checkDb, authenticateToken, async (req, res) => {
  try {
    const [scans] = await pool.query('SELECT COUNT(*) as count FROM scan_results WHERE user_id = ?', [req.user.id]);
    res.json({ count: scans[0].count });
  } catch (error) {
    res.status(500).json({ error: 'Gagal memuat statistik scan.' });
  }
});

// Delete Scan
app.delete('/api/scans/:id', checkDb, authenticateToken, async (req, res) => {
  try {
    // Delete file first
    const [scans] = await pool.query('SELECT image_url FROM scan_results WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]);
    if (scans.length > 0 && scans[0].image_url) {
      const filePath = path.join(__dirname, scans[0].image_url);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    const [result] = await pool.query('DELETE FROM scan_results WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Data scan tidak ditemukan.' });
    }
    res.json({ success: true, message: 'Hasil scan berhasil dihapus.' });
  } catch (error) {
    res.status(500).json({ error: 'Gagal menghapus hasil scan.' });
  }
});

// ==========================================
// ── CHAT ENDPOINTS ────────────────────────
// ==========================================

// Create Session
app.post('/api/chat/sessions', checkDb, authenticateToken, async (req, res) => {
  const { title } = req.body;
  try {
    const sessionId = uuidv4();
    await pool.query(
      'INSERT INTO chat_sessions (id, user_id, title) VALUES (?, ?, ?)',
      [sessionId, req.user.id, title || 'Chat Baru']
    );
    const [sessions] = await pool.query('SELECT * FROM chat_sessions WHERE id = ?', [sessionId]);
    res.status(201).json(sessions[0]);
  } catch (error) {
    res.status(500).json({ error: 'Gagal membuat sesi chat baru.' });
  }
});

// Get Sessions
app.get('/api/chat/sessions', checkDb, authenticateToken, async (req, res) => {
  try {
    // Also join to get the last message for each session (optional, but good for UI if needed)
    const [sessions] = await pool.query(
      `SELECT cs.*, 
       (SELECT content FROM chat_messages WHERE session_id = cs.id ORDER BY created_at DESC LIMIT 1) as last_message 
       FROM chat_sessions cs 
       WHERE cs.user_id = ? 
       ORDER BY cs.updated_at DESC`,
      [req.user.id]
    );
    res.json(sessions);
  } catch (error) {
    res.status(500).json({ error: 'Gagal memuat sesi chat.' });
  }
});

// Update Session Title
app.put('/api/chat/sessions/:id', checkDb, authenticateToken, async (req, res) => {
  const { title } = req.body;
  if (!title) {
    return res.status(400).json({ error: 'Judul wajib diisi.' });
  }

  try {
    const [result] = await pool.query('UPDATE chat_sessions SET title = ? WHERE id = ? AND user_id = ?', [title, req.params.id, req.user.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Sesi chat tidak ditemukan.' });
    }
    res.json({ success: true, message: 'Judul sesi chat diperbarui.' });
  } catch (error) {
    res.status(500).json({ error: 'Gagal memperbarui judul sesi chat.' });
  }
});

// Delete Session
app.delete('/api/chat/sessions/:id', checkDb, authenticateToken, async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM chat_sessions WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Sesi chat tidak ditemukan.' });
    }
    res.json({ success: true, message: 'Sesi chat dihapus.' });
  } catch (error) {
    res.status(500).json({ error: 'Gagal menghapus sesi chat.' });
  }
});

// Get Session Messages
app.get('/api/chat/sessions/:id/messages', checkDb, authenticateToken, async (req, res) => {
  try {
    // Verify session belongs to user
    const [sessions] = await pool.query('SELECT id FROM chat_sessions WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]);
    if (sessions.length === 0) {
      return res.status(404).json({ error: 'Sesi chat tidak ditemukan.' });
    }

    const [messages] = await pool.query(
      'SELECT id, session_id, content, is_user, created_at FROM chat_messages WHERE session_id = ? ORDER BY created_at ASC',
      [req.params.id]
    );

    // Format is_user as boolean
    const formatted = messages.map(msg => ({
      ...msg,
      is_user: !!msg.is_user
    }));

    res.json(formatted);
  } catch (error) {
    res.status(500).json({ error: 'Gagal memuat pesan.' });
  }
});

// Save Message
app.post('/api/chat/messages', checkDb, authenticateToken, async (req, res) => {
  const { session_id, content, is_user } = req.body;
  if (!session_id || !content) {
    return res.status(400).json({ error: 'Session ID dan isi pesan wajib diisi.' });
  }

  try {
    // Verify session belongs to user
    const [sessions] = await pool.query('SELECT id FROM chat_sessions WHERE id = ? AND user_id = ?', [session_id, req.user.id]);
    if (sessions.length === 0) {
      return res.status(404).json({ error: 'Sesi chat tidak ditemukan.' });
    }

    const msgId = uuidv4();
    const isUserVal = is_user ? 1 : 0;

    await pool.query(
      'INSERT INTO chat_messages (id, session_id, content, is_user) VALUES (?, ?, ?, ?)',
      [msgId, session_id, content, isUserVal]
    );

    // Update session timestamp
    await pool.query(
      'UPDATE chat_sessions SET updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [session_id]
    );

    const [newMsg] = await pool.query('SELECT * FROM chat_messages WHERE id = ?', [msgId]);
    res.status(201).json({
      ...newMsg[0],
      is_user: !!newMsg[0].is_user
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengirim/menyimpan pesan.' });
  }
});

// Get Chat session count
app.get('/api/chat/sessions/count', checkDb, authenticateToken, async (req, res) => {
  try {
    const [sessions] = await pool.query('SELECT COUNT(*) as count FROM chat_sessions WHERE user_id = ?', [req.user.id]);
    res.json({ count: sessions[0].count });
  } catch (error) {
    res.status(500).json({ error: 'Gagal memuat statistik chat.' });
  }
});

// Export app for Vercel
module.exports = app;

// Start Server (only if not running on Vercel)
if (!process.env.VERCEL) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Eco Server running on port ${PORT}`);
    console.log(`Static uploads available at http://localhost:${PORT}/uploads`);
  });
}
