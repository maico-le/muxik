# Project Progress & Roadmap (PROGRESS.md)

| Milestone | Task | Status | Notes |
|:---:|---|:---:|---|
| **M0** | **Spike**: Dev cookie -> InnerTube API (`FEmusic_liked_playlists`, `VL<id>`, `player`) -> Audio Stream -> CLI/test playback 10s | ✅ Completed | All fixtures & live InnerTube streams (3 video IDs) verified via HTTP range checks |
| **M1** | Project setup, `PixelTheme`, pixel widget kit, routing (`go_router`), DB tables (`drift`) | ✅ Completed | PixelTheme, widgets kit, Drift SQLite DB & code generation, GoRouter, 0 analyzer issues, green tests |
| **M2** | Authentication: WebView login + Dev cookie sheet + account switcher | ✅ Completed | WebView Google auth, DevCookieBottomSheet, AccountSwitcher, AuthStorage, rollback on error, unit tests passed |
| **M3** | Library & Playlist view with continuation pagination + parsers + fixture tests | ✅ Completed | InnerTubeParser, LibraryRepo, offline caching to SQLite, pagination continuation, full fixture tests passed |
| **M4** | Player: `just_audio`, queue management, shuffle bag, loop modes (OFF/ONE/ALL/ONE×N), mini player | 🔄 In Progress | Ready to implement |
| **M5** | Background playback: `audio_service`, notification, lock screen, audio focus | ⏳ Pending | |
| **M6** | Search: debounced search, filters, pagination continuation, search history | ⏳ Pending | |
| **M7** | Playlist mutations + `pending_ops` offline sync + Random Shuffle Bag | ⏳ Pending | |
| **M8** | Data Saving: NetworkPolicy, bitrate selection, LRU disk cache, conditional prefetch, Data Meter | ⏳ Pending | |
| **M9** | UI Polish, Pixel animations, accessibility, app icons, release APK build, docs | ⏳ Pending | |
