# Testing Guide & Manual Verification Checklist (TESTING.md)

This document provides a comprehensive test strategy, automated test verification commands, and a manual acceptance checklist for **Musical** (Retro Pixel Art YouTube Music Player for Android).

---

## 1. Automated Test Suite

Run the full automated test suite using:
```bash
flutter test
```

### Coverage Overview:
- **Milestone 0: Spike Verification (`test/spike_test.dart`)**:
  - Live InnerTube stream resolution across 3 YouTube video IDs (`dQw4w9WgXcQ`, `9bZkp7q19f0`, `kJQP7kiw5Fk`).
  - HTTP Range Request (`206 Partial Content`) playability verification.
  - Multi-client fallback verification (`WEB_REMIX`, `ANDROID_MUSIC`, `IOS`, `TVHTML5`).
- **Milestone 1: Pixel Widgets & Golden/Unit Tests (`test/widget/pixel_widgets_test.dart`)**:
  - Pixel design geometry (0-radius borders, hard offset shadows).
  - `PixelButton`, `PixelCard`, `PixelProgressBar`, `PixelSwitch`, `PixelIcon`.
- **Milestone 2: Authentication & Account Switching (`test/unit/account_repo_test.dart`)**:
  - `SAPISIDHASH` SHA1 computation test.
  - Secure storage credential persistence & cookie verification.
  - Account switching and rollback upon invalid token error.
- **Milestone 3: Library & InnerTube Parsers (`test/unit/innertube_parser_test.dart`, `test/unit/library_repo_test.dart`)**:
  - Realistic InnerTube fixture parsing (`library_playlists.json`, `playlist_tracks.json`).
  - Continuation pagination handling.
  - Offline drift SQLite synchronization.
- **Milestone 4: QueueController, Shuffle Bag & Player (`test/unit/queue_controller_test.dart`)**:
  - Non-repeating Shuffle Bag (unbiased permutation).
  - 4 Loop Modes: `OFF`, `ONE`, `ALL`, `ONE×N` (2–10 repeats).
  - Dynamic queue manipulations (`playNext`, `addToEnd`, `removeAt`, `reorder`).
- **Milestone 5: AudioHandler & Background Playback (`test/unit/audio_handler_test.dart`)**:
  - Background `AudioService` state synchronization.
  - Notification and lock screen playback actions.
  - Audio focus loss/duck/pause and headphone unplug (`becomingNoisy`) interruptions.
- **Milestone 6: Search & History (`test/unit/search_repo_test.dart`)**:
  - 400ms debounced search query.
  - Search filter chips (Song, Video, Album, Artist, Playlist).
  - Local SQLite search history CRUD with deduplication.
  - 5-minute memory cache TTL.
- **Milestone 7: Playlist Mutations & Offline Sync (`test/unit/sync_repo_test.dart`)**:
  - Optimistic offline playlist creation with temporary ID cascade.
  - `pending_ops` queue with exponential backoff and retry limits.
  - Two-phase reorder position update preventing compound primary key collisions.
  - Random Shuffle Bag (50 random tracks from library).
- **Milestone 8: Data Saver & Network Policy (`test/unit/network_policy_test.dart`, `test/unit/data_meter_test.dart`, `test/unit/audio_cache_manager_test.dart`, `test/unit/byte_count_test.dart`)**:
  - Verification that 48kbps Opus stream consumes $\approx 20.6\text{ MB/hour} \le 25\text{ MB/hour}$.
  - Verification that playing a cached audio file consumes **0 network bytes**.
  - LRU disk audio cache eviction when exceeding user limit.
  - Data meter tracking across Audio, Image, and API payloads.
  - Super Data Saver mode blocking remote thumbnails and prefetching.

---

## 2. Manual Acceptance Checklist

The following manual test procedures must be verified on a physical Android device or emulator before production release:

### 2.1 Background Playback with Screen Locked
| # | Step | Expected Result | Pass/Fail |
|---|---|---|:---:|
| 1 | Play any track and press the power button to lock the screen. | Music continues playing continuously without stutter or pause. | [ ] |
| 2 | Keep screen locked for 30 minutes on Wi-Fi. | Music advances from track to track smoothly in background. | [ ] |
| 3 | Keep screen locked for 30 minutes on 4G/5G Cellular. | Playback remains active with low data consumption ($\le 25\text{MB/h}$). | [ ] |
| 4 | Wake screen to lock screen media player. | Shows pixel artwork, track title, artist name, and playback progress bar. | [ ] |
| 5 | Tap **Next** and **Previous** buttons on lock screen. | Player responds instantly and updates track information. | [ ] |

### 2.2 Headphone & Audio Focus Interruptions
| # | Step | Expected Result | Pass/Fail |
|---|---|---|:---:|
| 1 | While music is playing through wired/bluetooth headphones, unplug/disconnect headphones (`becomingNoisy`). | Playback pauses immediately to avoid loudspeaker embarrassment. | [ ] |
| 2 | Simulate incoming telephone call. | Playback pauses while ringing/on call, and automatically resumes when call ends. | [ ] |
| 3 | Play audio in another app (e.g. YouTube video or navigation prompt). | Musical ducks (lowers volume) or pauses, then restores volume upon completion. | [ ] |

### 2.3 Battery Optimization Advisory
| # | Step | Expected Result | Pass/Fail |
|---|---|---|:---:|
| 1 | Open **Settings** screen on Xiaomi / Samsung / Oppo / Huawei device. | Prominent warning banner advises disabling MIUI / OneUI battery optimization for Musical. | [ ] |

### 2.4 Offline Mode & Data Saving Verification
| # | Step | Expected Result | Pass/Fail |
|---|---|---|:---:|
| 1 | Turn on Airplane Mode. | Top banner displays `⚡ NGOẠI TUYẾN: PHÁT TỪ THƯ VIỆN & CACHE`. | [ ] |
| 2 | Play a previously listened track while in Airplane Mode. | Track plays instantly from local LRU cache without error. | [ ] |
| 3 | Create or edit a playlist while in Airplane Mode. | Playlist updates immediately in UI and increments `SYNC: N` badge on AppBar. | [ ] |
| 4 | Turn off Airplane Mode and tap `SYNC: N`. | All pending operations push to YouTube InnerTube API and badge disappears. | [ ] |
| 5 | Toggle "Chế độ Siêu Tiết Kiệm" in Settings. | Remote images stop loading (replaced with pixel note placeholder) and bitrate drops to 48kbps. | [ ] |
