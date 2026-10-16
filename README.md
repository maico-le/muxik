<div align="center">

<img src="assets/app_icon.png" alt="Muxik Logo" width="128" height="128" />

# 🎵 Muxik
### *Retro Pixel Art YouTube Music Player for Android*

[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/maico-le/muxik/releases)
[![Version](https://img.shields.io/badge/Version-v1.0.0-FA520F?style=for-the-badge)](https://github.com/maico-le/muxik/releases/latest)
[![Data Saver](https://img.shields.io/badge/Data_Saver-≤25MB/hour-FFAF00?style=for-the-badge)](#)
[![Background Play](https://img.shields.io/badge/Background_Play-Enabled-blue?style=for-the-badge)](#)

<br/>

### 📲 [👉 DOWNLOAD LATEST MUXIK APK FOR ANDROID 👈](https://github.com/maico-le/muxik/releases/latest/download/app-release.apk)
*Or view all previous releases and changelogs on the [GitHub Releases](https://github.com/maico-le/muxik/releases) page.*

---

</div>

## 💡 Overview

**Muxik** is a lightweight, ad-free YouTube Music player for Android engineered for **screen-off background playback**, **extreme 4G/5G data savings ($\le 25\text{ MB/hour}$)**, and a warm **Retro Pixel Art** interface inspired by the aesthetic of [Mistral.ai](https://mistral.ai/).

Zero video bloat, zero intrusive ads. Enjoy pure music with seamless lock screen controls, offline disk caching, and authentic retro pixel album art.

---

## ✨ Key Features

### 📴 1. Screen-Off & Lock Screen Background Playback
- Runs as a persistent Android Foreground Service (`mediaPlayback`), streaming continuously when you lock your device, switch apps, or slip your phone into your pocket.
- Full notification shade and lock-screen media controls: Play, Pause, Next, Previous, Seek slider, and pixelated album artwork.
- Smart Audio Focus: Automatically pauses for incoming phone calls and resumes on hangup; auto-pauses when headphones are unplugged (`becomingNoisy`).

### ⚡ 2. Extreme Cellular Data Savings ($\le 25\text{ MB/hour}$)
- **Real-Time Network Intelligence**: Automatically distinguishes between Wi-Fi and Cellular (4G/5G). Treats metered phone hotspots as mobile data to protect your data plan.
- **Dynamic Bitrate Optimization**:
  - **On Cellular**: Prioritizes lightweight Opus streams (~48 kbps) $\approx 20.6\text{ MB/hour} \le 25\text{ MB/hour}$—cutting mobile data usage by over 60% compared to typical streaming apps.
  - **On Wi-Fi**: Automatically promotes streams to maximum fidelity (Opus 160 kbps or AAC 128 kbps).
- **Super Data Saver Mode**: Disables remote thumbnail downloads, locking audio to ultra-low bitrate for consumption below $20\text{ MB/hour}$.
- **Built-in Data Meter**: Tracks exact transfer bytes separated by day, month, network type, and category (Audio, Image, API) with an 8-bit stepped pixel bar chart.

### 💾 3. Zero-Data Subsequent Replays (LRU Disk Audio Cache)
- Played tracks are automatically cached to local device storage.
- **Replaying your favorite tracks consumes exactly 0 bytes of network data**.
- Automated Least Recently Used (LRU) cache manager cleans up old songs when disk usage reaches your preferred threshold (100MB to 5GB).

### 🎨 4. Warm Retro Pixel Art Aesthetic
- Palette inspired by Mistral.ai: Flame Orange (`#FA520F`), Bright Orange (`#FF8205`), Amber (`#FFAF00`), Gold (`#FFD800`), Cream (`#FFFAEB`), and crisp black borders.
- Handcrafted pixelated album art downsampling—crisp, authentic retro vibe while saving mobile bandwidth.
- Animated 8-bit stepped equalizer visualizer dancing to the rhythm of your music.

### 🔐 5. Official Google Sign-In & Library Sync
- Sign in directly through Google's official YouTube Music WebView authentication.
- Automatically syncs your custom Playlists, Liked Songs, and History.
- **Strict Privacy Guarantee**: Account cookies are strictly stored inside device hardware security (`flutter_secure_storage`). Credentials and tokens are **never** transmitted to any third-party server.

### 🎲 6. Fair Shuffle Bag & Multi-Mode Looping
- **Shuffle Bag**: Ensures truly fair playback—every track in your playlist is played exactly once before any song repeats.
- **Flexible Loop Modes**: Choose between `Off`, `Repeat Current Song`, `Repeat Entire Queue`, or `Repeat N Times (ONE×N)` (plays the current track 2–10 times before progressing).

---

## 📥 Quick Installation (Android)

1. Tap to download: [**Muxik APK (Latest)**](https://github.com/maico-le/muxik/releases/latest/download/app-release.apk).
2. Once downloaded, open the `.apk` file and tap **Install**.
   *(If prompted by Android, grant **Allow from this source** for your browser)*.
3. Open Muxik, head to **Settings** -> tap **Sign In** to sync your YouTube Music library!

---

## 🔋 Important: Prevent Android Background Killing

Aggressive OEM battery managers on certain devices (**Xiaomi/Redmi - MIUI/HyperOS**, **Samsung - OneUI**, **Oppo/Realme - ColorOS**, **Huawei - EMUI**) may kill background audio services:

1. Open your phone's **System Settings**.
2. Go to **Apps** -> **Manage Apps** -> Locate **Muxik**.
3. Tap **Battery Saver** -> Change to **No restrictions**.
4. Enable **Auto-start** if the option exists.

---

<div align="center">
  <sub>Crafted with passion by <a href="https://github.com/maico-le">maico-le</a> • Pure Retro Pixel Music Experience</sub>
</div>
