# CODEBUDDY.md

This file provides guidance to CodeBuddy Code when working with code in this repository.

## Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on a specific device
flutter run -d <device_id>
```

### Code Generation
Code generation is required after modifying any files with `@riverpod`, `@freezed`, `@TypedGoRoute`, or `.arb` localization files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Build
```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build macos        # macOS
```

### Testing & Analysis
```bash
flutter test               # Run all tests
flutter test test/path/to/test_file.dart  # Run a single test
flutter analyze            # Static analysis
```

## Architecture

### Directory Structure
```
lib/
├── main.dart              # App entry point; initializes GetIt services, wraps app in ProviderScope
├── route.dart             # GoRouter configuration with @TypedGoRoute annotations
├── app_key.dart           # API credentials (Qwen, Xunfei) — do not commit secrets
├── common/                # Shared widgets, themes, utilities
├── feat/                  # Feature modules
│   ├── chat/              # Chat UI (ChatPage, message list, input)
│   ├── home/              # Home page (AI service selection)
│   ├── me/                # Profile/settings tab
│   └── main/              # Bottom nav shell
├── provider/              # Riverpod state providers
│   ├── locale_state.dart  # Locale persistence (SharedPreferences)
│   └── theme_state.dart   # Theme mode persistence (SharedPreferences)
├── service/               # Business logic & external integrations
│   ├── ai_service/        # AI backends (abstract base + Qwen implementation)
│   ├── asr_service/       # Xunfei speech-to-text
│   ├── kv_service/        # SharedPreferences wrapper
│   ├── record_service/    # Audio recording
│   └── service_manager.dart  # GetIt registration
├── tools/                 # Tool integrations for AI
└── l10n/                  # intl_en.arb, intl_zh.arb (EN/ZH localization)
```

### State Management
- **Riverpod** (v3+ with code generation) for all UI state
- `@riverpod` annotation on providers; generated files are `.g.dart` siblings
- Global persistent state: `LocaleState` and `ThemeState` providers backed by `KvService`

### Dependency Injection
- **GetIt** service locator initialized in `main.dart` before `runApp`
- `ServiceManager` registers `KvService`, `RecordService`, and `AsrService`
- Access services via `GetIt.instance<ServiceType>()`

### Navigation
- **GoRouter** with typed routes defined via `@TypedGoRoute` annotations in `route.dart`
- Key routes:
  - `/` → `MainPage` (shell with Home/Me tabs)
  - `/chat` → `ChatPage` (receives `serviceType` query param)
  - `/setting/theme` → theme picker
  - `/setting/locale` → language picker

### AI Service Layer
- `AiServiceBase` (`service/ai_service/ai_service_base.dart`) — abstract class with a streaming state machine
- `AiServiceQwen` — concrete implementation using Dio to call Aliyun DashScope SSE endpoint (`https://dashscope.aliyuncs.com`)
- Currently supports model: `qwen3.7-plus`
- Messages are in-memory only; no local persistence of chat history

### Code Generation Files
The following generated file types must not be edited manually:
- `*.g.dart` — Riverpod providers, GoRouter, JSON serialization
- `*.freezed.dart` — Freezed data classes
- `l10n/` generated files — Flutter intl output

### Responsive Design
- Uses `flutter_screenutil` with design base `375×812`
- Initialize via `ScreenUtil.init()` in the widget tree before using `.w`, `.h`, `.sp` extensions

### Localization
- ARB source files: `lib/l10n/intl_en.arb`, `lib/l10n/intl_zh.arb`
- Run `build_runner` after modifying ARB files to regenerate delegates
