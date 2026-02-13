# 🏸 PCM Mobile - Hệ thống Quản lý Sân Pickleball

**Phiên bản:** v2.0 (Completed Stable)  
**Trạng thái:** ✅ Đã hoàn thiện

---

## 🚀 Giới thiệu
PCM Mobile là giải pháp toàn diện cho việc quản lý và đặt sân Pickleball. Hệ thống bao gồm ứng dụng di động đa nền tảng (Android/iOS/Web) và Backend mạnh mẽ xử lý logic nghiệp vụ phức tạp.

### 🌟 Tính năng nổi bật
- **Đặt sân trực tuyến:** Xem lịch trống, đặt sân và thanh toán nhanh chóng.
- **Quản lý giải đấu:** Tạo và quản lý các giải đấu Pickleball chuyên nghiệp.
- **Hệ thống ví điện tử:** Nạp tiền, xem lịch sử giao dịch.
- **Admin Dashboard:** Quản lý sân, người dùng, và doanh thu (Dành cho Quản trị viên).
- **Đa nền tảng:** Chạy mượt mà trên Android và Trình duyệt Web.

---

## 🔗 Link Truy cập Nhanh

| Nền tảng | Link | Mô tả |
|----------|------|-------|
| **🌐 Web Version** | [**Chơi ngay (GitHub Pages)**](https://nguyen-tien-luc-dvelop23.github.io/test1/) | Chạy trực tiếp trên trình duyệt, không cần cài đặt. |
| **🤖 Android APK** | [**Tải xuống (v2.0)**](https://github.com/nguyen-tien-luc-dvelop23/test1/releases/tag/v2.0) | File cài đặt cho điện thoại Android. |
| **📡 API Server** | | Backend Server  |

---

## 🛠️ Công nghệ sử dụng

### 📱 Frontend (Mobile & Web)
- **Framework:** [Flutter](https://flutter.dev/) (SDK 3.x)
- **State Management:** Riverpod.
- **Architecture:** Clean Architecture (Presentation, Domain, Data).
- **Network:** Dio + Retrofit.

### 💻 Backend (API)
- **Framework:** [.NET 8 Web API](https://dotnet.microsoft.com/)
- **Language:** C#
- **Database:** MySQL 8.
- **ORM:** Entity Framework Core.
- **Authentication:** JWT Bearer Token.

### ☁️ Infrastructure & Deployment
- **Containerization:** Docker (Multi-stage build).
- **Hosting:** Render (Cloud).
- **CI/CD:** GitHub Actions / Manual Deploy Workflow.
- **Web Hosting:** GitHub Pages.

---

## ⚙️ Hướng dẫn Cài đặt (Local Development)

### 1. Backend (.NET 8)
```bash
cd backend
# Cấu hình chuỗi kết nối trong appsettings.json
dotnet restore
dotnet ef database update # Chạy Migration
dotnet run
```
*Server sẽ chạy tại: `http://localhost:5000`*

### 2. Mobile (Flutter)
```bash
cd mobile/pcm_mobile
flutter pub get
flutter run
```

### 3. Chạy bằng Docker (Khuyên dùng)
```bash
# Tại thư mục gốc
docker build -t pcm-api .
docker run -p 8080:8080 pcm-api
```

---

## 📸 Hình ảnh Minh họa
*(Hệ thống booking, Màn hình Admin, Lịch thi đấu...)*

---

## 👨‍💻 Tác giả
**Nguyễn Tiến Lực**  
Dự án thực tập/tốt nghiệp - Phát triển ứng dụng đa nền tảng.

> *"Code đẹp là code chạy được và... có comment!"* 😎
