# Project Progress & Roadmap (PROGRESS.md)

| Milestone | Task | Status | Notes |
|:---:|---|:---:|---|
| **M0** | **Spike**: Dev cookie -> InnerTube API (`FEmusic_liked_playlists`, `VL<id>`, `player`) -> Audio Stream -> CLI/test playback 10s | ✅ Completed | All fixtures & live InnerTube streams (3 video IDs) verified via HTTP range checks |
| **M1** | Project setup, `PixelTheme`, pixel widget kit, routing (`go_router`), DB tables (`drift`) | ✅ Completed | PixelTheme, widgets kit, Drift SQLite DB & code generation, GoRouter, 0 analyzer issues, green tests |
| **M2** | Authentication: WebView login + Dev cookie sheet + account switcher | ✅ Completed | WebView Google auth, DevCookieBottomSheet, AccountSwitcher, AuthStorage, rollback on error, unit tests passed |
| **M3** | Library & Playlist view with continuation pagination + parsers + fixture tests | ✅ Completed | InnerTubeParser, LibraryRepo, offline caching to SQLite, pagination continuation, full fixture tests passed |
| **M4** | Player: `just_audio`, queue management, shuffle bag, loop modes (OFF/ONE/ALL/ONE×N), mini player | ✅ Completed | QueueController, PlayerService, MiniPlayer, PlayerScreen, PixelVisualizer, QueueBottomSheet, 100% test coverage |
| **M5** | Background playback: `audio_service`, notification, lock screen, audio focus | ✅ Completed | Android foreground service, AudioSession interruptions (focus duck/pause), lock screen controls, battery optimization advisory |
| **M6** | Search: debounced search, filters, pagination continuation, search history | ✅ Completed | 400ms debounce, search filter chips, SQLite search_history, 5-min cache TTL, pagination & auto-play integration |
| **M7** | Playlist mutations + `pending_ops` offline sync + Random Shuffle Bag | ✅ Completed | Optimistic mutations, SQLite pending_ops queue with exponential backoff & tempId cascade, reorder 2-phase update, random shuffle bag |
| **M8** | Data Saving: NetworkPolicy, bitrate selection, LRU disk cache, conditional prefetch, Data Meter | ⏳ Pending | |
| **M9** | UI Polish, Pixel animations, accessibility, app icons, release APK build, docs | ⏳ Pending | |
