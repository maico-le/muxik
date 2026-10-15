# Architectural Decisions & Rationales (DECISIONS.md)

This log documents key technical choices made during the development of Musical.

---

### [DEC-001] Workspace Setup and SDK Configuration
- **Date**: 2026-10-15
- **Status**: Accepted
- **Context**: The development machine needed a clean Flutter environment.
- **Decision**: Installed Flutter SDK to `C:\flutter` using the `stable` branch. Added `C:\flutter\bin` to session PATH and project configuration. Reference repositories (`SimpMusic` and `core`) are cloned into `reference/` and excluded from source control.

---

### [DEC-002] Authentication Architecture & SAPISIDHASH Computation
- **Date**: 2026-10-15
- **Status**: Accepted
- **Context**: YouTube Music InnerTube requires cookie-based authentication with `SAPISIDHASH` in the `Authorization` header. SimpMusic code contains an inconsistent calculation (`epochSeconds / 1000`).
- **Decision**: 
  - Standard InnerTube SAPISIDHASH calculation uses UNIX epoch in seconds:
    `ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()`
    `hash = sha1("$ts $sapisid https://music.youtube.com")`
    `Authorization: SAPISIDHASH ${ts}_${hash}`
  - We extract either `SAPISID` or `__Secure-3PAPISID`.
  - Cookies are strictly stored in `flutter_secure_storage`.
  - For development and automated testing where interactive Google sign-in cannot be executed by an automated agent, a **Dev Mode Cookie Input** (`DevLogInBottomSheet`) is provided alongside mock fixtures (`FakeYtRepository`).

---

### [DEC-003] Stream Resolution Hierarchy & Data Saving Strategy
- **Date**: 2026-10-15
- **Status**: Accepted
- **Context**: YouTube formats change frequently and rate limits / cipher throttling can occur. Mobile users need minimal data consumption (~25 MB/hour).
- **Decision**:
  - `StreamResolver` queries InnerTube `player` endpoint using:
    1. `WEB_REMIX` client (with user cookie if authenticated).
    2. Fallback to `ANDROID_MUSIC` / `IOS` / `TVHTML5` clients.
    3. Final fallback: `youtube_explode_dart`.
  - Audio Format Selection:
    - Cellular ("Save Data"): Lowest playable audio stream >= ~48 kbps (typically opus itag 249/250, or AAC itag 139).
    - Wi-Fi ("High Quality"): Highest quality audio stream (typically opus itag 251 ~160 kbps, or AAC itag 140 128 kbps).
  - Audio Cache: Local file LRU cache keyed by `videoId + itag`. Once cached, subsequent plays require 0 network data.
  - Data Meter: Interceptor tracks exact byte transfers separated by network type (Cellular vs Wi-Fi) and payload category (Audio, Image, API).

---

### [DEC-004] Pixel Art Theme & Styling (Mistral.ai aesthetic)
- **Date**: 2026-10-15
- **Status**: Accepted
- **Context**: User requested a pixel art design inspired by mistral.ai.
- **Decision**:
  - Color Palette:
    - Background: Warm Cream (`#FFFAEB`) / Dark mode Slate Black (`#18181B`)
    - Surface: Pure Cream (`#FFFDF7`) / Dark surface (`#27272A`)
    - Primary Accent: Mistral Orange (`#FA520F`)
    - Secondary Accents: Bright Orange (`#FF8205`), Amber (`#FFAF00`), Gold (`#FFD800`)
    - Text: Pixel Dark (`#1E1E1E`) / Pixel Light (`#FAFAFA`)
    - Border: Hard Black (`#000000`)
  - Geometry:
    - Strict `BorderRadius.zero` (sharp edges everywhere).
    - Stepped solid offset box-shadows (e.g. `BoxShadow(color: Colors.black, offset: Offset(3, 3))`).
    - Pixel icons (drawn using custom painter grids or block SVG).
    - Image downscaling and rendering with `FilterQuality.none` to create genuine retro pixelated album artwork while saving network data.
