# PROMPT CHO AI AGENT: Xây app nghe nhạc YouTube Music bằng Flutter, phong cách pixel

> Vai trò: bạn là senior Flutter engineer tự chạy end-to-end (không hỏi lại trừ khi bị chặn hoàn toàn).
> Khi gặp điểm mơ hồ: chọn phương án hợp lý nhất, ghi quyết định vào `DECISIONS.md`, rồi làm tiếp.

---

## 0. Mục tiêu

Tạo app nghe nhạc **Android (ưu tiên)**, viết bằng **Flutter**, tương tự **SimpMusic** (https://github.com/maxrave-dev/SimpMusic):

- Đăng nhập tài khoản Google/YouTube trong WebView, lấy danh sách phát của chính người dùng.
- Nghe nhạc (chỉ audio), chuyển bài, tìm kiếm, tạo/sửa danh sách phát, đồng bộ, shuffle, loop.
- **Phát nền khi tắt màn hình / khoá máy.**
- **Tiết kiệm lưu lượng tối đa khi dùng 4G/5G.**
- Giao diện **pixel art**, tham khảo https://mistral.ai/ (xem mục 8).

Nguồn tham khảo bắt buộc đọc trước khi code (clone về máy):

```
git clone --depth 1 https://github.com/maxrave-dev/SimpMusic.git
git clone --depth 1 https://github.com/maxrave-dev/core.git      # submodule "core" của SimpMusic
```

File cần đọc kỹ:

| Chủ đề | File |
|---|---|
| Màn đăng nhập WebView, bắt URL đích | `SimpMusic/composeApp/src/commonMain/.../ui/screen/login/LogInScreen.kt` |
| Lấy cookie WebView (Android) | `.../expect/ui/Cookies.android.kt` |
| Lưu tài khoản sau đăng nhập | `.../viewModel/SettingsViewModel.kt` → `addAccount()` |
| Header xác thực, SAPISIDHASH, mọi endpoint InnerTube | `core/service/kotlinYtmusicScraper/.../Ytmusic.kt` |
| Gọi cấp cao, parse response, `player()` | `core/service/kotlinYtmusicScraper/.../YouTube.kt` |
| Các client giả (WEB_REMIX, ANDROID_MUSIC, IOS...) | `.../models/YouTubeClient.kt` |
| Giải mã chữ ký stream (cipher) | `.../cipher/*`, `.../extractor/*` |
| Library playlist + phân trang | `core/data/.../repository/PlaylistRepositoryImpl.kt` → `getLibraryPlaylist()` |
| Account | `core/data/.../repository/AccountRepositoryImpl.kt` |
| Config URL | `core/common/.../Config.kt` |

Không sao chép nguyên văn code Kotlin; hiểu logic rồi viết lại bằng Dart.

---

## 1. Nguyên tắc làm việc (agent tự chạy)

1. Tạo `AGENTS.md` (quy ước repo, lệnh build/test/lint), `DECISIONS.md` (quyết định + lý do), `PROGRESS.md` (milestone đã xong / đang làm / bị chặn).
2. Làm theo milestone ở mục 11. **Mỗi milestone phải chạy được, có test, commit riêng.** Không sang milestone sau khi `flutter analyze` còn lỗi hoặc test đỏ.
3. **Làm Milestone 0 (spike) trước tiên**: chứng minh được chuỗi *cookie → browse playlist → player → URL audio → phát được*. Đây là phần rủi ro nhất. Chưa xong thì không làm UI.
4. Vì agent không đăng nhập Google tương tác được: viết sẵn **Dev mode dán cookie thủ công** (như `DevLogInBottomSheet` của SimpMusic) và `FakeYtRepository` dùng JSON fixture để test/CI. Người dùng sẽ tự đăng nhập thật khi nghiệm thu.
5. Không bao giờ log/commit cookie, SAPISID, SAPISIDHASH. Cookie lưu bằng `flutter_secure_storage`. Thêm lint/grep check trong CI.
6. API là **không chính thức** (InnerTube). Mọi parser phải chịu lỗi: thiếu field thì bỏ qua item, không crash; có test với fixture.
7. Commit nhỏ, message rõ. Không thêm tính năng ngoài danh sách trừ khi ghi trong `DECISIONS.md`.

---

## 2. Tech stack (đề xuất, có thể đổi nếu ghi lý do)

| Mục đích | Package |
|---|---|
| State | `flutter_riverpod` (+ `riverpod_generator` tuỳ chọn) |
| Routing | `go_router` |
| HTTP | `dio` (+ interceptor tự viết cho header/retry/đo data) |
| WebView đăng nhập + đọc cookie | `flutter_inappwebview` (`CookieManager.getCookies` đọc được cả cookie HttpOnly; `webview_flutter` thì hạn chế) |
| Phát nhạc + nền | `just_audio` + `audio_service` (+ `audio_session`) |
| DB local | `drift` (SQLite) |
| Lưu bí mật | `flutter_secure_storage` |
| Mạng | `connectivity_plus` (+ platform channel đọc `isActiveNetworkMetered`) |
| Cache ảnh | `cached_network_image` hoặc tự viết với `flutter_cache_manager` |
| Font pixel | bundle font trong `assets/fonts/` (Press Start 2P, VT323 hoặc Silkscreen – license OFL) |
| Giải cipher stream | ưu tiên thử `youtube_explode_dart` làm fallback; hoặc `flutter_js`/QuickJS nếu phải tự giải như SimpMusic |
| Test | `flutter_test`, `mocktail` |

Kiến trúc: Clean-ish theo feature.

```
lib/
  core/            # theme pixel, widgets pixel, utils, network (dio, data meter)
  data/
    yt/            # InnerTube client, models, parsers (thuần Dart, test được)
    db/            # drift tables + DAOs
    repo/          # AccountRepo, LibraryRepo, PlaylistRepo, PlayerRepo, SearchRepo, SyncRepo
  audio/           # AudioHandler (audio_service), StreamResolver, CacheManager, QueueController
  features/
    auth/ library/ playlist/ player/ search/ settings/ downloads/
  main.dart
```

---

## 3. Logic đăng nhập & xác thực (BẮT BUỘC làm đúng)

Không dùng Google OAuth, không dùng YouTube Data API key. Dùng **cookie phiên** từ WebView.

### 3.1 Đăng nhập
1. Mở `InAppWebView` tới URL:
   `https://accounts.google.com/ServiceLogin?ltmpl=music&service=youtube&uilel=3&passive=true&continue=https%3A%2F%2Fwww.youtube.com%2Fsignin%3Faction_handle_signin%3Dtrue%26app%3Ddesktop%26hl%3Den%26next%3Dhttps%253A%252F%252Fmusic.youtube.com%252F%26feature%3D__FEATURE__&hl=en`
   (xác minh lại trong `Config.LOG_IN_URL`).
2. Trước khi mở: xoá toàn bộ cookie WebView.
3. Ở `onLoadStop(url)`: nếu `url == "https://music.youtube.com/"` → đăng nhập xong.
4. Lấy cookie của `https://music.youtube.com/` bằng `CookieManager.getCookies(url)`, ghép thành chuỗi `k=v; k=v`.
5. Kiểm tra có `SAPISID` hoặc `__Secure-3PAPISID`. Thiếu → báo lỗi.
6. Gọi `getAccountSwitcherEndpoint` để xác thực cookie và lấy danh sách tài khoản (mục 3.3). Thành công mới lưu; thất bại thì **rollback** về cookie cũ.
7. Xoá cookie WebView sau khi lưu (app tự giữ cookie, không phụ thuộc WebView).

### 3.2 Header cho mọi request cần đăng nhập
Base URL InnerTube: `https://music.youtube.com/youtubei/v1/` (xác minh `defaultRequest` trong `Ytmusic.kt`), query `prettyPrint=false`, thêm `key=<api_key của client>` nếu cần.

| Header | Giá trị |
|---|---|
| `Cookie` | chuỗi cookie đầy đủ |
| `Authorization` | `SAPISIDHASH <ts>_<sha1("<ts> <SAPISID> https://music.youtube.com")>` — `ts` là epoch **giây**, lấy `SAPISID` hoặc `__Secure-3PAPISID` |
| `X-Goog-Authuser` | index tài khoản (mặc định `0`) |
| `X-Goog-Pageid` | `pageId` nếu dùng brand channel |
| `x-origin` | `https://music.youtube.com` |
| `X-YouTube-Client-Name` / `X-YouTube-Client-Version` | theo client (WEB_REMIX) |
| `User-Agent` | theo client |
| `Content-Type` | `application/json` |

Body luôn có `context.client` (`clientName`, `clientVersion`, `hl`, `gl`, `visitorData`...). Lấy `visitorData` từ `sw.js_data` hoặc response, lưu lại và gửi kèm.

> Lưu ý: code SimpMusic tính `currentTime` bằng `epochSeconds / 1000`. Hãy tự kiểm chứng bằng cách gọi thật; timestamp chuẩn của SAPISIDHASH là epoch giây. Đừng chép mù.

### 3.3 Nhiều tài khoản
`GET https://music.youtube.com/getAccountSwitcherEndpoint` (cần header như trên). Response bắt đầu bằng `)]}'\n` → cắt tiền tố rồi mới `jsonDecode`. Mỗi account có: tên, email, avatar, `pageId`, cờ đang dùng. Lưu bảng `accounts` (email, name, thumb, pageId, isUsed, cookie mã hoá). Đổi account = đổi `pageId`/`authUser` + cookie tương ứng.

---

## 4. Logic lấy danh sách nhạc

Tất cả là `POST` tới InnerTube, header ở 3.2, client `WEB_REMIX`.

| Việc | Endpoint | Ghi chú |
|---|---|---|
| Danh sách playlist trong Library | `browse` với `browseId = "FEmusic_liked_playlists"` | Parse `contents.singleColumnBrowseResultsRenderer.tabs[0].tabRenderer.content.sectionListRenderer.contents[0].gridRenderer.items` (item là `musicTwoRowItemRenderer`: title, thumbnail, `navigationEndpoint.browseEndpoint.browseId` dạng `VL<playlistId>`). Phân trang bằng `gridRenderer.continuations[0].nextContinuationData.continuation` → `browse` với `continuation` cho tới khi hết. |
| Bài trong 1 playlist | `browse` với `browseId = "VL<playlistId>"` | Parse `musicPlaylistShelfRenderer.contents[].musicResponsiveListItemRenderer` (videoId, title, artists, album, duration, thumbnail, `playlistSetVideoId`). Có continuation tương tự. Layout có thể là `singleColumn` hoặc `twoColumn`: viết helper tìm theo key thay vì hard-code index. |
| Bài đã thích | playlist id `LM` → `browse` `VLLM` | xác minh |
| Tìm kiếm | `search` (body có `query`, `params` cho filter song/video/album/artist/playlist) | Các filter param xem `YouTube.SearchFilter` trong `YouTube.kt`. |
| Gợi ý khi gõ | `music/get_search_suggestions` | Tắt/giới hạn khi mạng di động (mục 7). |
| Up next / radio | `next` (body: `videoId`, `playlistId`, `params`) | Dùng khi hết queue hoặc phát radio. |
| Tạo playlist | `playlist/create` (`title`, `videoIds`, `privacyStatus`) | Trả `playlistId`. |
| Thêm / xoá / đổi thứ tự / đổi tên | `browse/edit_playlist` với `actions[]`: `ACTION_ADD_VIDEO`, `ACTION_REMOVE_VIDEO` (cần `setVideoId`), `ACTION_MOVE_VIDEO_BEFORE`, `ACTION_SET_PLAYLIST_NAME` | `playlistId` bỏ tiền tố `VL`. |
| Like / bỏ like | `like/like`, `like/removelike` | |
| Thông tin tài khoản | `account/account_menu` | Tuỳ chọn. |

Yêu cầu parser:
- Hàm tiện ích `findAll(json, key)` / `firstOrNull(json, path...)` thay cho truy cập index cứng.
- Mọi parser có test với fixture JSON thật (lưu vào `test/fixtures/`, đã xoá dữ liệu cá nhân).
- Khi cấu trúc đổi: trả `ParseFailure` có mô tả, UI hiện "Không đọc được dữ liệu, thử lại", **không crash**.

---

## 5. Lấy URL audio và phát (phần khó nhất)

Quy trình `StreamResolver.resolve(videoId)`:

1. `POST player` với `videoId`, `playlistId`, `signatureTimestamp`, `cpn` ngẫu nhiên 16 ký tự. Client thử theo thứ tự (xem `YouTube.player()` và `YouTubeClient.kt`): `WEB_REMIX` (có đăng nhập) → các client dự phòng (`ANDROID_MUSIC`, `IOS`, `TVHTML5`...).
2. Đọc `streamingData.adaptiveFormats`, **chỉ lấy format audio** (`mimeType` bắt đầu `audio/`). Không bao giờ tải video.
3. Mỗi format có `url` hoặc `signatureCipher`. Nếu là cipher: giải bằng logic trong `cipher/` hoặc `youtube_explode_dart`. Nếu URL có tham số `n` bị throttle thì cần biến đổi `n` (SimpMusic xử lý trong `cipher/`, đọc cách làm).
4. Chọn format theo **chính sách chất lượng** (mục 7.2).
5. Trả về `ResolvedStream{url, mime, bitrate, contentLength, expiresAt, loudnessDb}`. `expiresAt` lấy từ tham số `expire` trong URL (thường vài giờ).
6. Cache kết quả resolve theo `videoId` tới `expiresAt - 5 phút`.
7. Nếu phát lỗi 403/410 hoặc hết hạn giữa chừng: resolve lại, nối tiếp tại vị trí hiện tại, người dùng không phải thao tác.
8. Khi `player` trả `playabilityStatus` khác OK (age-gate, region, premium): đánh dấu bài "không phát được", **tự nhảy bài kế**, không dừng hàng đợi.
9. Fallback cuối: `youtube_explode_dart`. Mọi fallback ghi log (không có cookie) để debug.
10. googlevideo có thể throttle nếu tải một khối lớn; kiểm tra xem SimpMusic/media3 có đọc theo đoạn (`range`) không và làm tương tự nếu cần. Đo thực tế tốc độ buffer, không đoán.

Bắt buộc ở Milestone 0: một script/CLI Dart nhỏ in ra `videoId → url → phát thử 10s bằng just_audio`. Ghi lại client nào hoạt động vào `DECISIONS.md`.

---

## 6. Tính năng (có tiêu chí nghiệm thu)

### 6.1 Thư viện & Sync
- Màn Library: lưới playlist của tài khoản + "Liked" + playlist local. Có pull-to-refresh.
- **Sync (đồng bộ)**:
  - *Pull*: kéo toàn bộ playlist + bài từ YouTube về DB local (upsert theo `playlistId`/`videoId`, giữ thứ tự và `setVideoId`). Chạy ngầm, hiện tiến độ, có thể huỷ. Chỉ kéo metadata, không tải audio.
  - *Push*: thay đổi local (tạo, thêm, xoá, đổi tên, sắp xếp) vào hàng đợi `pending_ops` → đẩy lên YouTube qua `edit_playlist` khi có mạng; thất bại thì retry với backoff; xung đột thì **YouTube là nguồn đúng**, ghi vào log.
  - Tự sync khi mở app nếu lần sync cuối > N giờ (mặc định 6h), **chỉ trên Wi-Fi** nếu bật "Chỉ sync khi Wi-Fi". Sync thủ công luôn được phép.
  - Dùng `ETag`/so sánh `trackCount` + `lastModified` (nếu có) để bỏ qua playlist không đổi.
- **Sync ngẫu nhiên / Random**: (xem DECISIONS.md, giải thích) = nút **"Trộn ngẫu nhiên"** lấy N bài ngẫu nhiên (mặc định 50) từ toàn bộ bài đã sync (hoặc từ playlist đang chọn) và đưa thẳng vào queue; kèm tuỳ chọn **"Lưu thành playlist mới"** (gọi `playlist/create`).
- Nghiệm thu: tắt mạng vẫn xem được playlist/bài đã sync; thêm bài khi offline → có mạng lại tự đẩy lên YouTube.

### 6.2 Phát nhạc
- Play/Pause, Next, Previous (Previous: nếu đã phát > 3s thì tua về 0, ngược lại lùi bài), seek, hiển thị thời lượng/buffer.
- Queue: xem, kéo sắp xếp, xoá, "phát tiếp theo", "thêm vào cuối".
- Phát từ playlist/kết quả tìm/radio.
- **Shuffle**: thuật toán "túi" (shuffle bag): mỗi bài chỉ phát một lần trước khi trộn lại; "Previous" quay về đúng bài đã phát trước đó (lưu lịch sử).
- **Loop**: chu kỳ nút bấm `OFF → ONE → ALL → ONE×N`:
  - `OFF`: hết queue thì dừng.
  - `ONE` (loop 1): lặp mãi bài hiện tại.
  - `ALL` (loop 2): hết queue quay lại đầu.
  - `ONE×N` (loop 3): lặp bài hiện tại N lần (mặc định N=3, chỉnh được 2–10) rồi sang bài kế.
  - Hiển thị icon pixel khác nhau cho từng chế độ; lưu lựa chọn.
- Hẹn giờ tắt (sleep timer) 15/30/60 phút hoặc hết bài.
- Lưu và khôi phục queue + vị trí khi mở lại app.

### 6.3 Tìm kiếm
- Ô tìm có debounce 400ms, filter (Bài hát/Video/Album/Nghệ sĩ/Playlist), lịch sử tìm kiếm local.
- Kết quả phân trang bằng continuation. Huỷ request cũ khi gõ tiếp.

### 6.4 Tạo / sửa danh sách phát
- Tạo playlist (tên, riêng tư/không công khai/công khai) → `playlist/create`.
- Thêm bài vào playlist từ bất kỳ đâu (menu 3 chấm), xoá bài, kéo đổi thứ tự, đổi tên.
- Hoạt động offline qua `pending_ops` (6.1).

### 6.5 Gợi ý thêm (nếu còn thời gian, sau M7)
Lịch sử nghe, Like, tải offline theo playlist, equalizer đơn giản, chia sẻ link, dark/light pixel theme.

---

## 7. Tiết kiệm lưu lượng (yêu cầu cốt lõi)

Mục tiêu: nghe 1 giờ trên 4G/5G **≤ ~25 MB** ở chế độ tiết kiệm, và có đồng hồ đo thực tế trong app.

### 7.1 Phát hiện mạng
- Dùng `connectivity_plus` + platform channel `ConnectivityManager.isActiveNetworkMetered()`. Coi Wi-Fi bị đánh dấu metered (hotspot) như di động.
- Phát sự kiện đổi mạng cho `NetworkPolicy` để thay đổi hành vi ngay (không cần restart).

### 7.2 Chính sách chất lượng audio
- Chỉ audio-only. Chọn theo **bitrate thực** trong `adaptiveFormats` (không tin mỗi `itag`):
  - **Di động (mặc định "Tiết kiệm")**: opus thấp nhất ≥ ~48 kbps (thường itag 249/250) hoặc AAC ~48 kbps (itag 139). ≈ 22 MB/giờ.
  - **Wi-Fi**: mặc định chất lượng cao (opus ~160 kbps itag 251 hoặc AAC 128 kbps itag 140). 128 kbps ≈ 58 MB/giờ.
  - Người dùng chỉnh riêng cho Wi-Fi / Di động: Thấp / Trung bình / Cao / Tự động.
- Ưu tiên opus (webm) nếu thiết bị hỗ trợ vì cùng chất lượng thì nhẹ hơn AAC.

### 7.3 Cache audio trên đĩa
- Cache theo `videoId + itag`, LRU, giới hạn mặc định 500 MB (chỉnh 100 MB – 5 GB). Bài đã nghe lại lần sau **không tốn data**.
- Dùng `just_audio` `LockCachingAudioSource` hoặc proxy cache tự viết hỗ trợ range request, sao cho vừa phát vừa ghi file và seek không tải lại.
- Cho phép "ghim" playlist để giữ lâu (offline).

### 7.4 Prefetch có điều kiện
- **Wi-Fi**: prefetch trọn vẹn 1–2 bài kế tiếp.
- **Di động**: mặc định chỉ prefetch bài kế tiếp ở mức vừa đủ chống ngắt (ví dụ ~20–30 giây đầu), hoặc tắt hoàn toàn nếu bật "Siêu tiết kiệm". Không prefetch khi shuffle chưa biết bài kế.
- Giới hạn buffer ahead trên di động (ví dụ 30–60s) thay vì tải cả bài; trên Wi-Fi có thể tải cả bài.
- Không tải lại bài khi tạm dừng lâu; dừng tải khi `pause` quá 60s trên di động.

### 7.5 Giảm lưu lượng "phụ"
- UI pixel dùng asset trong app, không tải ảnh nền/banner.
- Ảnh bìa: xin kích thước nhỏ (đổi tham số `=w60-h60`, `=s120`... của URL thumbnail) trên di động, cache đĩa vĩnh viễn; chế độ "Siêu tiết kiệm" thì không tải ảnh (dùng placeholder pixel).
- Không tải lyrics/canvas/video/clip. Không gọi API bên thứ ba (chỉ `youtubei`, `googlevideo`).
- Cache response `browse`/`search` với TTL (playlist 10 phút, search 5 phút); không gọi lại khi quay lại màn hình.
- Bật gzip/brotli (`Accept-Encoding`), tái sử dụng kết nối (HTTP/2 keep-alive), `fields`/mask nếu endpoint hỗ trợ.
- Sync trên di động chỉ kéo metadata của playlist **thay đổi**; không sync tự động khi bật "Chỉ Wi-Fi".
- Tắt gợi ý tìm kiếm tự động trên di động (chỉ gọi khi bấm tìm), hoặc cho tuỳ chọn.

### 7.6 Công cụ cho người dùng
- Tuỳ chọn trong Settings: *Chế độ dữ liệu* (Tiết kiệm / Cân bằng / Chất lượng), *Chỉ Wi-Fi cho sync/prefetch/tải*, *Cảnh báo khi dùng di động*.
- **Data meter**: interceptor Dio + proxy cache đếm byte thật (audio, ảnh, API) theo ngày/tháng, theo Wi-Fi/di động. Hiển thị trong Settings. Có ngưỡng cảnh báo (ví dụ 500 MB/tháng di động) và tự hạ xuống "Siêu tiết kiệm" khi vượt (bật/tắt được).
- Test tự động: dùng `FakeHttpServer` giả lập stream, assert số byte tải khi: phát lại bài đã cache (=0), seek trong vùng đã cache (=0), prefetch trên di động không vượt giới hạn.

---

## 8. Giao diện pixel (tham khảo mistral.ai)

Mở https://mistral.ai/ để xem trực tiếp rồi trích xuất phong cách. Các nhận xét ban đầu (agent tự xác minh và chỉnh):
- Khối màu **cam–vàng–hổ phách** dạng bậc thang/gradient theo khối pixel, nền **kem sáng**, chữ **đen**, bố cục lưới vuông vức.
- Logo chữ "M" dựng bằng khối vuông; có mascot/gif pixel (mèo, cờ).
- Palette tham khảo (ước chừng, cần đối chiếu với trang): cam `#FA520F`, cam sáng `#FF8205`, hổ phách `#FFAF00`, vàng `#FFD800`, kem `#FFFAEB`, đen `#1E1E1E`.

Yêu cầu thiết kế:
- Tạo `PixelTheme` (ThemeExtension) + bộ widget dùng chung: `PixelButton`, `PixelCard`, `PixelSlider` (thanh tiến trình dạng ô), `PixelIcon`, `PixelDialog`, `PixelTabBar`, `PixelProgressBar`, `PixelSwitch`.
- Viền **cứng, không bo góc, không blur, không bóng mờ**; bóng đổ bằng khối offset đặc (ví dụ 4px). Dùng `CustomPainter` hoặc `Container` + `BorderSide` không anti-alias (`FilterQuality.none` cho ảnh pixel).
- Font pixel (bundle), cỡ chữ tối thiểu dễ đọc (≥ 12sp, tiêu đề Press Start 2P cỡ 14–18). Tiếng Việt: **kiểm tra font hỗ trợ dấu tiếng Việt**; nếu thiếu thì dùng font pixel khác hoặc font dự phòng cho nội dung thân bài.
- Ảnh bìa bài hát: hiển thị bằng làm pixel hoá (downscale rồi phóng lớn `FilterQuality.none`) – tiện thể tiết kiệm data vì xin ảnh nhỏ.
- Icon dạng pixel (vẽ từ ma trận bool hoặc SVG pixel) cho: play, pause, next, prev, shuffle, loop OFF/ONE/ALL/ONE×N, queue, search, sync, add, heart, menu, download.
- Animation: nhảy theo bước (step) kiểu 8-bit (ví dụ equalizer pixel nhảy khi đang phát), không dùng chuyển động mượt quá mức.
- Màn hình: Library, Playlist detail, Player (full) + MiniPlayer, Search, Queue, Settings (Data, Account, Cache, Sync), Login.
- Hỗ trợ khả năng truy cập: contrast đủ, kích thước chạm ≥ 48dp.

---

## 9. Phát nền khi tắt màn hình

- `audio_service` + `just_audio`: `AudioHandler` chạy **foreground service** kiểu `mediaPlayback`.
- AndroidManifest: `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (Android 14+), `POST_NOTIFICATIONS` (Android 13+), `WAKE_LOCK`; khai báo service `com.ryanheise.audioservice.AudioService` với `android:foregroundServiceType="mediaPlayback"`, receiver `MediaButtonReceiver`.
- Thông báo media có: ảnh bìa, tên bài, Prev/Play/Next, nút loop/shuffle (custom action), hiển thị trên **màn hình khoá**.
- `audio_session`: cấu hình `AudioSessionConfiguration.music()`, xử lý **audio focus** (tạm dừng khi có cuộc gọi, tự phát lại khi hết), `becomingNoisy` (rút tai nghe → pause), nút tai nghe Bluetooth/có dây.
- Giữ CPU và Wi-Fi khi phát (`just_audio` đã wake lock; kiểm tra thêm `WifiLock` nếu cần phát khi màn tắt trên Wi-Fi).
- Màn hình Settings có hướng dẫn xin **bỏ tối ưu pin** (`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`) vì một số hãng (Xiaomi, Oppo, Samsung, Huawei) kill service.
- Tự khôi phục: nếu service bị kill, mở lại từ queue đã lưu; xử lý hết hạn URL (mục 5.7) ngay cả khi màn hình tắt.
- Nghiệm thu thủ công (ghi vào `TESTING.md`): phát 30 phút với màn tắt trên Wi-Fi và trên 4G, chuyển bài tự động, loop/shuffle hoạt động, điều khiển từ màn hình khoá, nhận cuộc gọi rồi phát lại.
- iOS (nếu làm sau): `UIBackgroundModes: audio`. Ghi rõ trong `DECISIONS.md` là chưa hỗ trợ ở giai đoạn đầu.

---

## 10. Mô hình dữ liệu (drift)

```
accounts(email PK, name, thumbUrl, pageId, authUser, isUsed)      # cookie ở secure storage, khoá = email
tracks(videoId PK, title, artists, album, durationMs, thumbUrl, isPlayable, lastPlayedAt)
playlists(id PK, title, thumbUrl, owner, source[youtube|local], privacy, trackCount, syncedAt, etag)
playlist_tracks(playlistId, position, videoId, setVideoId, PRIMARY KEY(playlistId, position))
pending_ops(id PK AUTOINCREMENT, type, payloadJson, createdAt, attempts, lastError)
queue_state(id=1, trackIdsJson, index, positionMs, shuffleOn, loopMode, loopCount)
cache_index(videoId, itag, path, bytes, lastAccess)
data_usage(day, network[wifi|cell], kind[audio|image|api], bytes)
search_history(query PK, at)
settings  # có thể dùng SharedPreferences
```

---

## 11. Milestone

| # | Nội dung | Nghiệm thu |
|---|---|---|
| M0 | **Spike**: cookie dev → `FEmusic_liked_playlists` → `VL<id>` → `player` → URL audio → phát 10s (CLI/test app tối giản). Viết xong `YtClient`, `StreamResolver` | Log 3 videoId phát được; `DECISIONS.md` ghi client/itag thành công |
| M1 | Khung app, `PixelTheme`, bộ widget pixel, routing, DB, settings | `flutter analyze` sạch; golden test vài widget |
| M2 | Đăng nhập WebView + Dev mode cookie + account switcher | Đăng nhập thật được; cookie lưu secure; rollback khi sai |
| M3 | Library + Playlist detail (có phân trang) + parser có fixture test | Hiện đúng playlist/bài; offline xem được bản cache |
| M4 | Player: just_audio, queue, next/prev, seek, shuffle bag, loop OFF/ONE/ALL/ONE×N, mini player | Test unit cho `QueueController` đủ các tổ hợp |
| M5 | Phát nền: audio_service, notification, lock screen, audio focus, khôi phục queue, URL hết hạn | Checklist `TESTING.md` (mục 9) |
| M6 | Tìm kiếm + gợi ý + lịch sử | Filter + continuation hoạt động |
| M7 | Tạo/sửa playlist + `pending_ops` + Sync pull/push + Trộn ngẫu nhiên | Offline-edit rồi sync lên YouTube thành công |
| M8 | **Tiết kiệm data**: NetworkPolicy, chọn bitrate, cache LRU, prefetch có điều kiện, data meter, Siêu tiết kiệm | Test byte-count mục 7.6; đo 1 giờ phát trên di động ≤ ~25 MB ở "Tiết kiệm" |
| M9 | Hoàn thiện UI pixel, animation, accessibility, icon app, README, build release APK | APK release chạy; README có hướng dẫn đăng nhập/dev cookie |

---

## 12. Definition of Done

- `flutter analyze` không lỗi; `flutter test` xanh; có test cho parser (fixture), `QueueController`, `StreamResolver` (mock), `NetworkPolicy`, data meter.
- Không có cookie/secret trong log, commit hay crash report.
- Không crash khi: mất mạng giữa chừng, URL hết hạn, bài không phát được, cookie hết hạn (yêu cầu đăng nhập lại có hướng dẫn), response đổi cấu trúc.
- Có `README.md` (cài đặt, đăng nhập, cấu hình), `AGENTS.md`, `DECISIONS.md`, `PROGRESS.md`, `TESTING.md`.
- Build `flutter build apk --release` thành công.

## 13. Rủi ro cần ghi rõ trong README

- Dùng API YouTube Music **không chính thức**; có thể hỏng khi YouTube đổi; có thể trái điều khoản dịch vụ. App dành cho mục đích cá nhân/học tập.
- Cookie phiên tương đương quyền truy cập tài khoản Google: chỉ lưu cục bộ, mã hoá, cho phép "Đăng xuất & xoá dữ liệu".
- Không hỗ trợ tải video, không bỏ qua giới hạn nội dung trả phí/khu vực.