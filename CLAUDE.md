# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**eco** is a Flutter environmental app (Indonesian-language UI) that lets users scan their surroundings with the camera, get an AI environmental assessment from Google Gemini, chat with an "Eco Assistant", and view a dashboard of local weather, air quality, AI-generated tips, and news. Backend is Supabase (auth, Postgres, storage). User-facing strings, AI prompts, and AI responses are all in Bahasa Indonesia — keep new strings/prompts in Indonesian to match.

## Commands

```bash
flutter pub get                      # install dependencies
flutter run                          # run on connected device/emulator (Android, iOS, web, desktop all configured)
flutter analyze                      # static analysis / lint (flutter_lints via analysis_options.yaml)
flutter test                         # run all tests
flutter test test/widget_test.dart  # run a single test file
flutter test --name "Splash screen"  # run a single test by name
flutter build apk                    # release Android build
```

There is no separate formatter/codegen step — `dart format` and the standard `flutter` toolchain are all that's used.

## Architecture

Layered **MVVM + feature-first**. Dependencies flow strictly downward: View → ViewModel → Repository → Service → external API/SDK. Never skip a layer (e.g. a View must not call a Service directly).

```
lib/
  core/        constants (colors, strings, theme, api_constants), utils, shared widgets
  data/
    models/        immutable data classes with fromJson / toJson (+ toInsertJson for DB inserts)
    services/      thin wrappers over external SDKs/APIs (Supabase, Gemini, OpenWeatherMap, location)
    repositories/  orchestrate services + models; the API surface ViewModels consume
  features/<name>/  <name>_view.dart + <name>_viewmodel.dart (+ widgets/ subfolder for view pieces)
  routes/app_router.dart   named routes
  app.dart / main.dart     bootstrap
```

### State management (Provider + ChangeNotifier)
- Every ViewModel extends `ChangeNotifier` and exposes private fields via getters; UI mutates state only through ViewModel methods, each ending in `notifyListeners()`.
- ViewModels use **constructor dependency injection with defaults**: `DashboardViewModel({WeatherRepository? weatherRepository}) : _weatherRepository = weatherRepository ?? WeatherRepository()`. This pattern exists so tests can inject fakes; preserve it when adding repositories to a ViewModel.
- **Global** ViewModels are registered in `main.dart`'s `MultiProvider` (Auth, Dashboard, Camera, ScanResult, Chatbot, History, Profile). **Local** ViewModels are created inline (e.g. `HomeViewModel` via `ChangeNotifierProvider` inside `HomeView`). When adding a global ViewModel, register it in BOTH `main.dart` and `test/widget_test.dart` (the widget test rebuilds the same provider tree).

### Navigation
- Named routes in `lib/routes/app_router.dart` (`AppRouter.splash`, `.login`, `.home`, etc.); `initialRoute` is splash.
- `HomeView` is a shell with a `BottomNavigationBar` over an `IndexedStack` of Dashboard / Camera / History tabs, indexed by `HomeViewModel.currentIndex` (tabs are NOT routes — they stay mounted). Profile, Chatbot, and ScanResult are pushed as separate routes.

### Backend (Supabase)
- `SupabaseService` is a static façade: `client`, `auth`, `storage`, typed table getters (`profiles`, `scanResults`, `chatSessions`, `chatMessages`), the `scan-images` storage bucket, and `currentUserId`/`isAuthenticated`. Access Supabase through these getters, not `Supabase.instance` directly.
- DB columns are snake_case; Dart models are camelCase — conversion lives in each model's `fromJson`/`toJson`. Use `toInsertJson()` (omits `id`, lets Postgres generate it) for inserts.
- Auth is Google Sign-In → Supabase `signInWithIdToken`. `AuthRepository` merges the auth email into the profile row.

### AI — two providers
The app uses **two** AI backends, split by feature:
- **Gemini** (`GeminiService` / `GeminiRepository`) handles the vision/structured tasks: image analysis, daily tip, news. These build Indonesian prompts that instruct Gemini to reply as **JSON**. Gemini often wraps JSON in markdown ```` ```json ```` fences, so every consumer runs an `_extractJson()` regex helper before `jsonDecode`, wrapped in try/catch that **falls back to using the raw text** on parse failure. This duplicated helper appears in `DashboardViewModel` and `ScanResultViewModel` — match that resilient pattern for any new Gemini-parsing code; never assume the response is clean JSON.
- **Groq** (`GroqService` / `GroqRepository`) powers the Eco Assistant **chatbot** via Groq's OpenAI-compatible Chat Completions endpoint (`groqModel` in `ApiConstants`, currently `openai/gpt-oss-120b`). Groq has no stateful session like Gemini's `ChatSession`, so `GroqService` keeps the conversation itself as a `List<{role, content}>` and resends it each turn. `startChat()` / `startChatWithScanContext(scan)` seed the Eco Assistant persona (optionally with a scan analysis as context); `resetChat()` clears history. The model's `message.content` is the answer; the `message.reasoning` field (gpt-oss is a reasoning model) is ignored. `ChatbotViewModel` depends on `GroqRepository`; the Gemini chat methods remain but are no longer wired to the chatbot.

### Scan pipeline (core feature)
Camera capture → `ScanResultViewModel.analyzeImage(bytes)`: fetch location context → `GeminiRepository.analyzeImage` → parse JSON into condition/impact/suggestions/contacts. Then `saveResult()`: upload bytes to the `scan-images` bucket → build `ScanResultModel` → `ScanRepository.saveScanResult`. History reuses the same ViewModel via `loadExistingResult()`.

## Secrets / configuration

`lib/core/constants/api_constants.dart` currently holds **live** Supabase, Gemini, Groq, and OpenWeatherMap keys committed to the repo (intentional, for collaborators — see commit history). The Google Maps key is still a `YOUR_..._KEY` placeholder. This file is the single source of truth for all endpoints and credentials.
