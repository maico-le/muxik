# AGENTS.md - Repository Conventions & Agent Instructions

This document defines conventions, guidelines, and commands for AI agents working in this repository.

## Project Overview
- **Name**: Musical (Pixel Art YouTube Music Player for Android)
- **Framework**: Flutter (Dart)
- **Target Platform**: Android (primary)
- **Design Philosophy**: Retro Pixel Art (Mistral-inspired amber/gold/orange palette, hard borders, stepped animations, pixel icons, 0-radius blocks)
- **Key Features**:
  1. Google/YouTube session login via WebView (extracting cookies: SAPISID / __Secure-3PAPISID).
  2. Background audio playback with lock screen controls via `just_audio` + `audio_service`.
  3. Maximum data-saving policies on cellular networks (opus 48kbps / AAC 48kbps, local LRU cache, conditional prefetch, data meter).
  4. Local SQLite database via `drift` for playlists, tracks, sync, and pending offline actions.
  5. Unofficial InnerTube YouTube API client (`WEB_REMIX`, `ANDROID_MUSIC`, etc.) with fallback support.

---

## Directory Architecture
```
lib/
  core/             # Pixel theme, pixel widgets, constants, utils, network meter & interceptors
  data/
    yt/             # InnerTube API client, models, parsers, cipher solving (pure Dart, fully testable)
    db/             # Drift tables, DAOs, database migrations
    repo/           # AccountRepo, LibraryRepo, PlaylistRepo, PlayerRepo, SearchRepo, SyncRepo
  audio/            # AudioHandler (audio_service), StreamResolver, CacheManager, QueueController
  features/
    auth/           # Login WebView, Dev cookie input bottom sheet, account switcher
    library/        # User library, playlists list, offline synced tracks
    playlist/       # Playlist details, track list, reordering, inline actions
    player/         # Full pixel player, mini player, equalizer visualizer
    search/         # Debounced search, filter chips, continuation pagination, history
    settings/       # Data meter, streaming quality settings, cache clear, account management
  main.dart
test/
  fixtures/         # Real, anonymized JSON responses for InnerTube endpoints
  unit/             # Unit tests for parsers, QueueController, StreamResolver, NetworkPolicy
  widget/           # Widget & Golden tests for pixel UI components
```

---

## Security & Sensitive Information
- **Zero Secret Commitment**: NEVER log, display, or commit cookies, auth tokens, `SAPISID`, or `SAPISIDHASH`.
- Cookies MUST be stored exclusively in `flutter_secure_storage`.
- In test cases, only synthetic or sanitized fixture tokens are permitted.

---

## Commands Reference
- Run analyzer:
  `flutter analyze`
- Run test suite:
  `flutter test`
- Run build runner (for drift / code generation):
  `dart run build_runner build --delete-conflicting-outputs`
- Build release APK:
  `flutter build apk --release`
- Spike / CLI runner:
  `dart run bin/spike.dart` (or `test/spike_test.dart`)
