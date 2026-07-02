# Eco 🌿

A Flutter-based eco-friendly app featuring waste scanning, AI chatbot, weather monitoring, and environmental insights. It features a premium, minimalist light-mode design system with a clean, gradient-free interface.

## Tech Stack & Design

- **Frontend**: Flutter (Android, Web)
- **Backend**: Node.js + Express + MySQL
- **AI**: 
  - **Google Gemini 1.5 Flash** (highly cost-effective and fast image analysis & tips)
  - **Groq** (AI chatbot assistant)
- **Weather**: OpenWeatherMap API
- **Auth**: Google Sign-In + JWT
- **Design System**:
  - **Typography**: Plus Jakarta Sans (loaded via `google_fonts`)
  - **Theme**: Premium Light Mode (background: `#F7F9F4`, cards: `#FFFFFF`)
  - **Color Palette**:
    - Primary (Navy): `#143D60`
    - Secondary (Teal): `#27667B`
    - Accent (Green): `#A0C878`
    - Highlight (Light Yellow-Green): `#DDEB9D`
  - **Visuals**: Flat design with subtle shadows, zero gradients, and consistent card spacing and typography.

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.x
- Node.js ≥ 18.x
- MySQL (XAMPP / Laragon / standalone)
- A package manager: `npm` for the server

### 1. Clone & Flutter Setup

```bash
git clone https://github.com/demmagence/eco.git
cd eco
flutter pub get
```

### 2. Configure API Keys (Flutter)

Open `lib/core/constants/api_constants.dart` and fill in your keys:

| Constant | Where to get it | Default / Recommended Model |
|---|---|---|
| `geminiApiKey` | [Google AI Studio](https://aistudio.google.com/app/apikey) | - |
| `geminiModel` | [Google AI Studio](https://aistudio.google.com/app/apikey) | `gemini-1.5-flash` |
| `groqApiKey` | [Groq Console](https://console.groq.com/keys) | - |
| `owmApiKey` | [OpenWeatherMap](https://openweathermap.org/api) | - |
| `googleMapsApiKey` | [Google Cloud Console](https://console.cloud.google.com/google/maps-apis) | - |

Also update `web/index.html` — replace `YOUR_GOOGLE_WEB_CLIENT_ID` with your OAuth Web Client ID.

### 3. Configure Server

```bash
cd server
cp .env.example .env   # Windows: copy .env.example .env
```

Edit `server/.env` and fill in:
- `JWT_SECRET` — a strong random string (min 32 chars)
- `DB_PASSWORD` — your MySQL root password (if any)

### 4. Initialize Database & Run Server

```bash
cd server
npm install
node init-db.js     # Creates eco_db schema
node server.js      # Starts on http://localhost:3000
```

### 5. Run the App

```bash
# Android (ensure server is running, emulator uses 10.0.2.2:3000)
flutter run

# Web
flutter run -d chrome
```

> **Emulator note**: If running on Android Emulator, change `apiBaseUrl` in `api_constants.dart` to `http://10.0.2.2:3000/api`.

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/your-feature`)
3. Commit your changes
4. Open a Pull Request

**Never commit real API keys or secrets.** All sensitive values belong in `api_constants.dart` (local only, not committed) and `server/.env` (git-ignored).
