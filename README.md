<div align="center">

# 🎵 Muxik
### *Trình Nghe Nhạc YouTube Music Phong Cách Retro Pixel Art*

[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/maico-le/muxik/releases)
[![Version](https://img.shields.io/badge/Version-v1.0.0-FA520F?style=for-the-badge)](https://github.com/maico-le/muxik/releases/latest)
[![Data Saver](https://img.shields.io/badge/Data_Saver-≤25MB/hour-FFAF00?style=for-the-badge)](#)
[![Background Play](https://img.shields.io/badge/Background_Play-Enabled-blue?style=for-the-badge)](#)

<br/>

### 📲 [👉 TẢI VỀ FILE CÀI ĐẶT APK CHO ANDROID (BẢN MỚI NHẤT) 👈](https://github.com/maico-le/muxik/releases/latest/download/app-release.apk)
*Hoặc truy cập trang [GitHub Releases](https://github.com/maico-le/muxik/releases) để xem toàn bộ các bản phát hành.*

---

</div>

## 💡 Giới thiệu

**Muxik** là ứng dụng nghe nhạc YouTube Music cho Android dành cho những ai tìm kiếm trải nghiệm **nghe nhạc thuần túy, mượt mà khi tắt màn hình, tiết kiệm dung lượng 4G/5G tối đa** và khoác lên mình phong cách đồ họa **Retro Pixel Art** ấm áp lấy cảm hứng từ [Mistral.ai](https://mistral.ai/).

Không quảng cáo phiền toái, không tải video tốn data, tập trung 100% vào âm thanh chất lượng cao và giao diện hoài cổ độc đáo.

---

## ✨ Điểm nổi bật không thể bỏ qua

### 📴 1. Phát nhạc nền khi Tắt màn hình & Màn hình khoá
- Sử dụng Android Foreground Service chuẩn chỉnh (`mediaPlayback`), nghe nhạc liên tục không bị gián đoạn khi bạn tắt máy, bỏ vào túi quần hoặc chuyển sang ứng dụng khác.
- Điều khiển đầy đủ ngay trên màn hình khoá và thanh thông báo: Play/Pause, Next, Previous, Seek tua bài, hiển thị bìa album pixelated.
- Xử lý âm thanh thông minh (Audio Focus): Tự động tạm dừng khi có cuộc gọi đến và tự phát lại sau khi cúp máy; tự động dừng khi bạn rút tai nghe.

### ⚡ 2. Siêu Tiết Kiệm dữ liệu di động ($\le 25\text{ MB/giờ}$)
- **Nhận diện mạng tự động**: Phân biệt Wi-Fi và Di động (4G/5G). Coi các điểm phát Wi-Fi Hotspot chia sẻ từ điện thoại như mạng di động để bảo vệ gói cước của bạn.
- **Tối ưu bitrate âm thanh**:
  - Khi dùng 4G/5G: Ưu tiên luồng âm thanh Opus tối ưu (~48 kbps) $\approx 20.6\text{ MB/giờ} \le 25\text{ MB/giờ}$ (tiết kiệm hơn 60% dữ liệu so với app YouTube thông thường).
  - Khi dùng Wi-Fi: Tự động chuyển sang luồng âm thanh chất lượng cao nhất (Opus 160 kbps hoặc AAC 128 kbps).
- **Chế độ Siêu Tiết Kiệm (Super Data Saver)**: Tắt tải ảnh bìa mạng, chỉ tải audio tiết kiệm, đưa mức tiêu thụ xuống dưới $20\text{ MB/giờ}$.
- **Đồng hồ đo lưu lượng thực tế (Data Meter)**: Thống kê chi tiết từng byte mạng tiêu thụ theo ngày và tháng, hiển thị trực quan bằng biểu đồ cột 8-bit trong phần Cài đặt.

### 💾 3. Nghe lại lần 2 tiêu tốn đúng 0 Byte mạng (Offline LRU Cache)
- Mọi bài hát bạn nghe sẽ được tự động lưu vào bộ nhớ đệm (Cache) trên máy.
- **Nghe lại các bài hát quen thuộc hoàn toàn không tốn thêm bất kỳ dung lượng mạng nào**.
- Tự động dọn dẹp theo cơ chế LRU (ưu tiên giữ bài hay nghe, tự dọn bài cũ khi đầy bộ nhớ đệm từ 100MB – 5GB tùy bạn chọn).

### 🎨 4. Phong cách Retro Pixel Art đầy cảm xúc
- Bảng màu cam ấm Mistral: Cam `#FA520F`, hổ phách `#FFAF00`, vàng `#FFD800`, nền kem `#FFFAEB` và viền đen phẳng không bo góc.
- Ảnh bìa album được xử lý điểm ảnh hóa (Pixelated Resampling) vừa mang chất hoài cổ vừa tối ưu dung lượng tải ảnh.
- Dàn Equalizer 8-bit sống động nhảy giật bậc thang theo giai điệu bài hát.

### 🔐 5. Đăng nhập Google & Đồng bộ Playlist chính chủ
- Đăng nhập trực tiếp qua trang Google WebView chính thức của YouTube Music.
- Tự động tải về toàn bộ Danh sách phát (Playlist), Bài hát đã thích (Liked Songs), và Lịch sử của bạn.
- **Cam kết an toàn tuyệt đối**: Phiên đăng nhập chỉ được lưu trong khoá bảo mật phần cứng (`flutter_secure_storage`) trên chính thiết bị của bạn, tuyệt đối không gửi tài khoản ra bất kỳ máy chủ bên thứ ba nào.

### 🎲 6. Thuật toán Trộn bài thông minh (Shuffle Bag)
- Cơ chế Shuffle Bag đảm bảo xáo trộn công bằng: Tất cả bài hát trong playlist đều được nghe đúng 1 lần trước khi chu kỳ lặp lại bắt đầu (không bị tình trạng bài phát liên tục, bài không bao giờ được nghe).
- Hỗ trợ 4 chế độ lặp: `Tắt`, `Lặp 1 bài`, `Lặp danh sách`, và `Lặp N lần (ONE×N)` (lặp bài hiện tại 2–10 lần rồi mới tự động chuyển bài kế tiếp).

---

## 📥 Hướng dẫn cài đặt cho Android

1. Nhấn vào link: [**Tải Muxik APK (Bản mới nhất)**](https://github.com/maico-le/muxik/releases/latest/download/app-release.apk).
2. Khi tải xong, mở file `.apk` và chọn **Cài đặt**.
   *(Nếu hệ điều hành hỏi quyền cho phép cài đặt ứng dụng từ nguồn ngoài trình duyệt, hãy chọn **Cho phép / Allow**)*.
3. Mở Muxik, vào **Cài đặt** -> chọn **Đăng nhập Google** để thưởng thức kho nhạc YouTube của riêng bạn!

---

## 🔋 Mẹo quan trọng: Tránh bị tắt nhạc nền trên các máy Android

Một số dòng máy (đặc biệt là **Xiaomi/Redmi - MIUI/HyperOS**, **Samsung - OneUI**, **Oppo/Realme - ColorOS**, **Huawei**) có chính sách tiết kiệm pin rất gắt gao có thể tắt ngầm ứng dụng:

1. Vào **Cài đặt hệ thống** của điện thoại.
2. Chọn **Ứng dụng** -> **Quản lý ứng dụng** -> Tìm **Muxik**.
3. Chọn mục **Tiết kiệm pin (Battery Saver)** -> Đổi thành **"Không giới hạn" (No restrictions)**.
4. Bật mục **"Tự khởi chạy" (Auto-start)** nếu có.

---

<div align="center">
  <sub>Phát triển bởi <a href="https://github.com/maico-le">maico-le</a> • Trải nghiệm âm nhạc phong cách Retro Pixel</sub>
</div>
