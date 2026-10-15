# 🎵 Musical - Retro Pixel Art YouTube Music Player

**Musical** là ứng dụng nghe nhạc YouTube Music cho Android với phong cách **Retro Pixel Art** (lấy cảm hứng từ bảng màu ấm áp của [Mistral.ai](https://mistral.ai/): cam `#FA520F`, hổ phách `#FFAF00`, vàng `#FFD800`, kem `#FFFAEB`, viền đen phẳng không bo góc và đổ bóng offset đặc).

Ứng dụng được thiết kế tối ưu cho trải nghiệm nghe nhạc liên tục khi tắt màn hình, khả năng hoạt động ngoại tuyến linh hoạt và **chính sách tiết kiệm dữ liệu di động tối đa ($\le 25\text{ MB/giờ}$ trên mạng 4G/5G)**.

---

## ✨ Tính năng nổi bật

### 1. 📴 Phát nền khi tắt màn hình & Màn hình khoá
- Sử dụng `audio_service` + `just_audio` + `audio_session` chạy dưới dạng Android Foreground Service (`mediaPlayback`).
- Điều khiển đầy đủ trên thanh thông báo và màn hình khoá: Play/Pause, Next, Previous, Seek, hình bìa pixelated.
- Xử lý thông minh khi có sự kiện âm thanh (Audio Focus): tạm dừng khi có cuộc gọi và tự phát lại khi ngắt máy; tự động dừng khi rút tai nghe (`becomingNoisy`).
- Hướng dẫn vô hiệu hoá tối ưu pin (Battery Optimization) cho các dòng máy Xiaomi, Samsung, Oppo, Huawei để ngăn chặn hệ điều hành tắt ngầm ứng dụng.

### 2. ⚡ Tiết kiệm dữ liệu di động ($\le 25\text{ MB/giờ}$) & Siêu Tiết Kiệm
- **Nhận diện mạng thời gian thực (`NetworkPolicy`)**: Tự động phân biệt Wi-Fi và Di động (4G/5G), nhận diện Wi-Fi chia sẻ từ điện thoại (Metered Hotspot) như mạng di động để bảo vệ lưu lượng.
- **Chọn luồng âm thanh thông minh**:
  - Trên di động: Ưu tiên luồng Opus ~48 kbps (itag 249/250) hoặc AAC ~48 kbps (itag 139) $\approx 20.6\text{ MB/giờ} \le 25\text{ MB/giờ}$.
  - Trên Wi-Fi: Chọn luồng chất lượng cao nhất (Opus ~160 kbps itag 251 hoặc AAC 128 kbps itag 140).
- **Chế độ Siêu Tiết Kiệm (Super Data Saver)**: Tắt tải ảnh bìa từ xa (thay bằng icon pixel art âm nhạc), khoá bitrate 48kbps, tắt tải đệm trước (Prefetch), giúp mức tiêu thụ $< 20\text{ MB/giờ}$.
- **Bộ nhớ đệm đĩa LRU (`AudioCacheManager`)**: Tự động lưu bài hát vào đĩa khi nghe. **Nghe lại lần thứ hai tiêu thụ chính xác 0 byte mạng**. Tự động dọn dẹp theo thuật toán LRU khi vượt quá giới hạn (100MB – 5GB, mặc định 500MB).
- **Đồng hồ đo lưu lượng thực tế (`DataMeter`)**: Đo chính xác từng byte mạng theo ngày/tháng phân loại theo Audio, Ảnh, API với biểu đồ cột 8-bit Pixel Bar Chart trong Cài đặt.
- **Hạn mức 4G/5G hàng tháng**: Tự động cảnh báo và chuyển sang Siêu Tiết Kiệm khi chạm ngưỡng (ví dụ 500 MB/tháng).

### 3. 💾 Ngoại tuyến trước (Offline-First) & Hàng đợi đồng bộ (`pending_ops`)
- Toàn bộ thư viện, playlist, bài hát được lưu vào SQLite cục bộ bằng thư viện `drift`.
- Mọi thao tác tạo danh sách phát, đổi tên, xoá danh sách, thêm/xoá bài và kéo thả sắp xếp thứ tự đều phản hồi ngay lập tức trên giao diện mà không cần chờ mạng.
- Các thao tác khi offline được ghi vào hàng đợi `pending_ops` với cơ chế retry luỹ thừa (Exponential Backoff) và tự động đồng bộ lên YouTube ngay khi có mạng trở lại.
- Tự động cascade cập nhật ID tạm thời sang ID YouTube chính thức cho toàn bộ bài hát và tác vụ tiếp theo.

### 4. 🎲 Hàng đợi phát, Shuffle Bag không lặp & Chế độ Lặp Đa dạng
- **Shuffle Bag (Túi trộn không lặp)**: Xáo trộn danh sách bài hát công bằng, đảm bảo tất cả bài trong danh sách đều được phát đúng 1 lần trước khi chu kỳ lặp lại bắt đầu.
- **Tính năng "Trộn ngẫu nhiên"**: Lấy ngẫu nhiên 50 bài hát từ toàn bộ thư viện hoặc playlist và có tuỳ chọn **"Lưu thành playlist mới"** chỉ với 1 chạm.
- **4 Chế độ lặp lại**:
  - `OFF`: Hết hàng đợi thì dừng.
  - `ONE`: Lặp mãi bài hát hiện tại.
  - `ALL`: Lặp lại toàn bộ hàng đợi từ đầu.
  - `ONE×N`: Lặp bài hát hiện tại N lần (mặc định $N=3$, tuỳ chỉnh 2–10 lần) rồi mới tự động sang bài kế tiếp.

### 5. 🔍 Tìm kiếm & Lịch sử
- Ô tìm kiếm với debounce 400ms và cơ chế huỷ request cũ khi người dùng tiếp tục gõ.
- Bộ lọc danh mục theo chuẩn YouTube Music: Bài hát, Video, Album, Nghệ sĩ, Playlist.
- Phân trang vô hạn bằng token continuation của InnerTube.
- Lưu trữ lịch sử tìm kiếm cục bộ trên SQLite, xoá nhanh từng mục hoặc xoá toàn bộ.

---

## 🛠️ Yêu cầu môi trường & Cài đặt

### Yêu cầu:
- **Flutter SDK**: `>= 3.16.0` (Khuyến nghị 3.24+ hoặc 3.47+)
- **Dart SDK**: `>= 3.2.0 < 4.0.0`
- **Java**: JDK 17
- **Android SDK**: `minSdkVersion 21` (Android 5.0+), `targetSdkVersion 34`

### Các bước cài đặt:
1. Clone mã nguồn về máy:
   ```bash
   git clone https://github.com/your-username/musical.git
   cd musical
   ```
2. Cài đặt các gói phụ thuộc:
   ```bash
   flutter pub get
   ```
3. Sinh mã nguồn cho cơ sở dữ liệu Drift:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Chạy toàn bộ bộ kiểm thử tự động để kiểm tra:
   ```bash
   flutter test
   ```
5. Chạy ứng dụng trên thiết bị Android:
   ```bash
   flutter run
   ```

---

## 🔐 Hướng dẫn đăng nhập tài khoản

Ứng dụng hỗ trợ 2 phương thức đăng nhập an toàn:

### Cách 1: Đăng nhập Google qua WebView (Khuyến nghị)
1. Mở ứng dụng, vào tab **Cài đặt** -> chọn **ĐĂNG NHẬP**.
2. Nhấn nút **"ĐĂNG NHẬP GOOGLE (WEBVIEW)"**.
3. Điền tài khoản và mật khẩu Google trên trang xác thực chính thức của Google.
4. Ứng dụng tự động phát hiện phiên đăng nhập YouTube Music thành công, trích xuất cookie `SAPISID` / `__Secure-3PAPISID`, mã hoá và lưu an toàn vào `flutter_secure_storage`.

### Cách 2: Nhập Cookie Dev (Dành cho nhà phát triển / Máy ảo không hỗ trợ WebView)
1. Đăng nhập vào [music.youtube.com](https://music.youtube.com) trên trình duyệt máy tính.
2. Mở DevTools (F12) -> vào tab **Application** (hoặc Storage) -> **Cookies** -> `https://music.youtube.com`.
3. Sao chép giá trị của cookie `SAPISID` (hoặc `__Secure-3PAPISID`) hoặc toàn bộ chuỗi Header Cookie.
4. Mở ứng dụng Musical -> vào màn hình Đăng nhập -> nhấn **"DEV: NHẬP COOKIE THỦ CÔNG"**.
5. Dán cookie và nhấn **XÁC NHẬN**.

> **Cam kết bảo mật**: Cookie tài khoản chỉ được lưu cục bộ trên thiết bị trong khoá bảo mật phần cứng `flutter_secure_storage`. Ứng dụng **tuyệt đối không gửi cookie, token hay thông tin đăng nhập của bạn đến bất kỳ máy chủ bên thứ ba nào**.

---

## 🔋 Khắc phục hiện tượng tắt nhạc nền trên Android

Một số nhà sản xuất thiết bị Android (đặc biệt là Xiaomi/Redmi - MIUI/HyperOS, Samsung - OneUI, Oppo/Realme - ColorOS, Huawei - EMUI) áp dụng chính sách ngắt các ứng dụng chạy nền rất quyết liệt để tiết kiệm pin:

1. Vào **Cài đặt hệ thống** của điện thoại.
2. Chọn **Ứng dụng** -> **Quản lý ứng dụng** -> Tìm **Musical**.
3. Chọn mục **Tiết kiệm pin (Battery Saver)** -> Đổi từ *Khuyến nghị (MIUI)* sang **"Không giới hạn" (No restrictions)**.
4. Bật quyền **"Tự khởi chạy" (Auto-start)** nếu có.

---

## 📦 Biên dịch Release APK

Để tạo file cài đặt APK tối ưu:
```bash
flutter build apk --release
```
File APK hoàn thiện sẽ nằm tại:
`build/app/outputs/flutter-apk/app-release.apk`

---

## ⚖️ Tuyên bố miễn trừ trách nhiệm (Legal Disclaimer)

- **Musical** là dự án mã nguồn mở phục vụ cho mục đích học tập, nghiên cứu và thưởng thức âm nhạc cá nhân.
- Ứng dụng sử dụng API InnerTube không chính thức của YouTube và có thể thay đổi hoặc ngừng hoạt động nếu YouTube cập nhật giao thức hoặc thay đổi điều khoản dịch vụ.
- Ứng dụng không hỗ trợ tải video, không can thiệp hay phá vỡ các giới hạn nội dung có bản quyền, và tuân thủ các quy tắc bảo vệ dữ liệu người dùng.
