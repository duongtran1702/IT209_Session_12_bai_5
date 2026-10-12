# BÁO CÁO THỰC HÀNH - BÀI 5
## CHỦ ĐỀ: CHẨN ĐOÁN VÀ KHẮC PHỤC 3 SỰ CỐ ĐỨT GÃY PIPELINE CI/CD THỰC TẾ

---

### Thông tin học viên
- **Họ và tên**: Trần Trí Dương
- **Mã sinh viên / GitHub Username**: [duongtran1702](https://github.com/duongtran1702)
- **Email**: duong170226@gmail.com
- **Môn học**: IT209 - Quản lý Phiên bản và Hợp tác Mã nguồn / CI-CD Pipeline
- **Đường dẫn thư mục nộp bài**: `Session_12/bai_5/` *(hoặc đường dẫn gợi ý: `homework/session_12/ex5/`)*

---

## 1. Mục tiêu bài tập

1. **Phân tích log lỗi thực tế trên GitHub Actions**:
   - Khám nghiệm hệ thống ghi nhận lỗi (Error Logs) khi một Pipeline CI/CD bị gãy do các lỗi cấu hình phổ biến trong thực tế.
2. **Khắc phục triệt để 3 sự cố đứt gãy tuần tự**:
   - **Lỗi 1 (Permission Denied)**: Khắc phục quyền thực thi cho tệp Gradle Wrapper (`gradlew`) trên môi trường Linux Runner.
   - **Lỗi 2 (Authentication Failed)**: Sửa chính tả biến secret `${{ secrets.REGISTRY_TOKEN }}` để xác thực thành công vào Docker Registry (`ghcr.io`).
   - **Lỗi 3 (Build Context Error)**: Khắc phục sai lệch thư mục làm việc và đường dẫn `Dockerfile` trong bước đóng gói Docker Image bằng action `docker/build-push-action@v5`.
3. **Đưa toàn bộ luồng CI/CD trở về trạng thái tích xanh (Passed)**:
   - Đảm bảo cả hai Job `test` và `docker-build` hoàn thành 100% không lỗi.

---

## 2. Cấu trúc thư mục dự án

```text
Session_12/bai_5/
├── .github/
│   └── workflows/
│       ├── broken-pipeline.yml          # Kịch bản ĐÃ ĐƯỢC KHẮC PHỤC HOÀN TOÀN (Tích xanh)
│       └── broken-pipeline.original.yml.bak # Kịch bản GỐC bị 3 lỗi (Dùng để đối chiếu)
├── troubleshooting.md                   # Báo cáo chuyên sâu Root Cause Analysis (RCA) 3 lỗi
├── Dockerfile                           # Dockerfile chuẩn đa tầng đóng gói Spring Boot
├── build.gradle                         # Cấu hình dự án Java 21, Spring Boot 3.3.4, JUnit 5
├── settings.gradle                      # Tên dự án
├── gradlew                              # Script Gradle Wrapper (Linux/macOS)
├── gradlew.bat                          # Script Gradle Wrapper (Windows)
├── gradle/wrapper/                      # Wrapper JAR & cấu hình
├── src/
│   ├── main/java/...                    # Mã nguồn ứng dụng Spring Boot
│   └── test/java/...                    # Bộ Unit Test (Đã kiểm tra pass 100%)
├── images/
│   ├── error1-permission-denied.png     # Ảnh chụp log lỗi 1
│   ├── error2-authentication-failed.png # Ảnh chụp log lỗi 2
│   ├── error3-build-context-not-found.png # Ảnh chụp log lỗi 3
│   └── all-fixed-green.png              # Ảnh chụp luồng sau khi sửa thành công tích xanh
├── .dockerignore                        # Tệp bỏ qua thư mục build khi đóng gói Docker
├── .gitignore                           # Tệp bỏ qua tệp nhị phân trên Git
└── README.md                            # Báo cáo tổng kết bài thực hành
```

---

## 3. Tóm tắt 3 lỗi và phương án sửa chữa

| STT | Tên lỗi | Dòng log lỗi đặc trưng | Nguyên nhân | Giải pháp |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **Permission Denied** | `./gradlew: Permission denied`<br>`exit code 126` | Tệp `gradlew` thiếu quyền execute `+x` khi chạy trên runner Linux. | Thêm bước: `run: chmod +x gradlew` trước lệnh test. |
| **2** | **Authentication Failed** | `401 Unauthorized`<br>`authentication required` | Sai chính tả biến Secret (`REGISTRY_TOKKEN`), khiến token gửi đi là chuỗi rỗng. | Sửa thành: `${{ secrets.REGISTRY_TOKEN }}` (kèm fallback `GITHUB_TOKEN`). |
| **3** | **Build Context Error** | `failed to read dockerfile: no such file or directory` | Chỉ định sai `context: ./invalid-context/` và sai đường dẫn `file`. | Cấu hình: `context: .` và `file: ./Dockerfile`. |

> Chi tiết phân tích nguyên nhân gốc rễ, đoạn log đầy đủ và đoạn diff so sánh mã nguồn được trình bày chi tiết trong tệp [`troubleshooting.md`](troubleshooting.md).

---

## 4. Hướng dẫn kiểm thử thực tế

### Bước 1: Kiểm tra chạy bộ test nội bộ (Local Test)
Chạy lệnh kiểm tra Gradle Test trên máy tính:
```bash
./gradlew test
# Hoặc trên Windows:
.\gradlew.bat test
```
*Kết quả:* `BUILD SUCCESSFUL - 3 actionable tasks: 3 executed`. Bộ kiểm thử JUnit 5 hoàn thành xuất sắc.

### Bước 2: Đẩy commit lên GitHub và kiểm tra tab Actions
1. Đẩy mã nguồn lên kho lưu trữ GitHub:
   ```bash
   git add .
   git commit -m "fix(ci): resolve all 3 pipeline failures (perm, auth, context)"
   git push origin main
   ```
2. Mở tab **Actions** trên GitHub:
   - Job **Gradle Test & Build**: Chạy bước `chmod +x gradlew`, sau đó thực thi `./gradlew test` xanh hoàn toàn.
   - Job **Build & Push Docker Image**: Chờ Job test hoàn thành (`needs: test`), tiến hành đăng nhập với token hợp lệ, nạp đúng Dockerfile từ thư mục gốc `.` và build push Docker Image lên Registry.
   - Cả 2 Job đều sáng màu xanh lục (Passed).

---

## 5. Minh chứng kết quả (Ảnh chụp màn hình)

| STT | Nội dung minh chứng | Vị trí tệp ảnh |
| :---: | :--- | :---: |
| 1 | Log lỗi 1: `./gradlew: Permission denied` (Exit code 126) | `images/error1-permission-denied.png` |
| 2 | Log lỗi 2: Docker Registry 401 Unauthorized do sai Secret | `images/error2-authentication-failed.png` |
| 3 | Log lỗi 3: Build Context Error không tìm thấy Dockerfile | `images/error3-build-context-not-found.png` |
| 4 | Kết quả toàn bộ Pipeline tích xanh sau khi khắc phục triệt để | `images/all-fixed-green.png` |
