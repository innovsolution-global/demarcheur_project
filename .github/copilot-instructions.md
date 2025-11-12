## Copilot / AI agent quick guide — demarcheur_pro

Purpose
- Give AI agents the minimal, actionable knowledge to make safe and useful code changes in this Flutter app.

Big picture (read first)
- Flutter app arranged by feature and role: UI under `lib/apps/` and `lib/widgets/`, state under `lib/providers/`, services/network under `lib/services/`, and models under `lib/models/`.
- Root entry is `lib/main.dart`: it wires `MultiProvider`, app routes, and critical startup logic (authentication + chat initialization).

Critical integration points and patterns
- Authentication & Chat: `lib/main.dart` calls `AuthService.logedUser()` and `AuthService.initilizedChatPlugin()`; the `ChatPlugin` socket lifecycle is managed here. Changing init/order can break background/resume behavior — test on device/emulator.
- Providers: All app-wide `ChangeNotifier` providers are registered in `MultiProvider` inside `lib/main.dart`. To add global state, create a provider in `lib/providers/` and register it there.
- API & Repositories: Network calls live in `lib/services/` (e.g., `api_service.dart`) and are wrapped by repository classes (see `lib/job_repository.dart`). Maintain network logic in `services/`, models in `models/`, and provider consumption in `providers/`.
- Assets: Declared in `pubspec.yaml` under `flutter.assets`. Adding/removing assets requires updating `pubspec.yaml` and running `flutter pub get`.

Project-specific gotchas (discoverable facts)
- Mismatched names: `lib/job_repository.dart` contains a class named `DoctorRepository`. Search for such mismatches before renaming files/classes.
- Chat assumptions: many code paths assume `ChatConfig.instance.userId` is non-null after login. Guard any changes that can leave `userId` null at runtime.
- Error styles: existing code sometimes throws raw strings (`throw "this is the $ex"`). New code should prefer typed Exceptions but follow repo tone if altering nearby code.
- Linting: uses `flutter_lints` + `analysis_options.yaml`. Keep changes lint-clean where possible.

Typical changes & concrete examples
- Add provider
  1. Create `lib/providers/my_provider.dart` with `class MyProvider extends ChangeNotifier`.
  2. Register it in `lib/main.dart` inside the `providers:` list of `MultiProvider`.
  3. Use via `context.read<MyProvider>()` or `context.watch<MyProvider>()` in widgets.
- Add API endpoint
  1. Add a method in `lib/services/api_service.dart` to fetch/POST data.
  2. Add a small repository wrapper in `lib/repositories/` (or an existing repository file) that calls the service.
  3. Invoke repository from a provider and expose data to UI.

Build, run, and verification commands
- Install deps: `flutter pub get` (project root where `pubspec.yaml` is).
- Run: `flutter run -d <device>` (hot reload supported).
- Analyze: `flutter analyze` (useful after edits).
- Tests: `flutter test` (there is `test/widget_test.dart`).

Files to inspect for area-specific edits
- Startup & providers: `lib/main.dart`
- Auth + chat wiring: `lib/services/auth_service.dart` and uses of `ChatPlugin` in `lib/main.dart`
- Network layer: `lib/services/api_service.dart`
- Providers: `lib/providers/*`
- Models: `lib/models/*`

When NOT to change lightly
- `lib/main.dart` chat and lifecycle handling — small changes require device testing.
- `pubspec.yaml` asset entries — missing assets cause build failures.

If something is ambiguous
- Ask for the target platform (Android/iOS/web) and whether you can run the app; many chat/connection issues only reproduce on a device.

Closing note
- This file summarizes only discoverable, actionable patterns found in the repo. If you want more examples (typical PR changes, preferred test patterns, or a list of common imports), tell me which area to expand.
