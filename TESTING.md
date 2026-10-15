# Testing Guide & Manual Checklist (TESTING.md)

## Automated Tests
- Parser tests: innerTube parser validation with real sanitized JSON fixtures (`test/fixtures/*.json`).
- `QueueController`: tests for all playback loops (OFF, ONE, ALL, ONE×N) and shuffle bag behavior.
- `StreamResolver`: mocked player responses validating fallback order (WEB_REMIX -> ANDROID_MUSIC -> youtube_explode_dart).
- `NetworkPolicy` & Data Meter: byte tracking assertions, ensuring cached tracks download 0 additional network bytes.

## Background Playback & Android Validation Checklist
1. [ ] **Lock Screen Playback**: With display turned off, playback continues smoothly for 30+ minutes.
2. [ ] **Lock Screen Controls**: Title, artist, album art, Play/Pause, Next, Previous buttons work correctly on lock screen.
3. [ ] **Audio Focus Handling**:
   - Incoming phone call pauses playback.
   - Call termination automatically resumes playback.
   - `becomingNoisy`: Unplugging headphones or disconnecting Bluetooth pauses playback immediately.
4. [ ] **Continuous Queue**: Next track begins seamlessly when current track completes with screen off.
5. [ ] **URL Expiration Renewal**: Playback recovers transparently if stream URL expires during a long playlist session without user intervention.
6. [ ] **Battery Optimization**: Instructions provided to prompt user for `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` on aggressive OEM ROMs (Xiaomi, Samsung, Oppo).
