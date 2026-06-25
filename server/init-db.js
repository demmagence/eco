const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'eco_db',
  port: process.env.DB_PORT || 3306
};

async function main() {
  console.log('Initializing database...');
  let connection;
  try {
    // Connect without database first in case it doesn't exist
    const { database, ...configWithoutDb } = dbConfig;
    connection = await mysql.createConnection(configWithoutDb);
    console.log('Connected to MySQL host.');
    
    // Create database if not exists
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${database}\``);
    console.log(`Database "${database}" verified/created.`);
    await connection.changeUser({ database });
    
    // Read schema.sql
    const schemaPath = path.join(__dirname, 'schema.sql');
    if (!fs.existsSync(schemaPath)) {
      throw new Error(`schema.sql not found at ${schemaPath}`);
    }
    const sql = fs.readFileSync(schemaPath, 'utf8');
    
    // Execute queries
    // Split queries by semicolon and filter empty ones
    const queries = sql
      .split(';')
      .map(q => q.trim())
      .filter(q => q.length > 0);
      
    for (const query of queries) {
      // Remove SQL comments
      const queryClean = query
        .split('\n')
        .filter(line => !line.trim().startsWith('--') && !line.trim().startsWith('#'))
        .join('\n')
        .trim();
        
      if (!queryClean) continue;
      if (queryClean.toUpperCase().startsWith('USE ')) continue; // Skip USE statements since we changeUser
      
      console.log(`Executing query...`);
      await connection.query(queryClean);
    }
    
    console.log('Database initialization completed successfully!');
  } catch (error) {
    console.error('Error initializing database:', error);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

main();
