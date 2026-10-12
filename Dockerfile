# ==========================================
# Multi-stage Dockerfile cho Spring Boot (Gradle)
# ==========================================

# Stage 1: Đóng gói ứng dụng Spring Boot bằng Gradle
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

# Copy các tệp cấu hình Gradle wrapper & build script
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Cấp quyền thực thi cho gradlew
RUN chmod +x ./gradlew

# Tải trước dependencies (tận dụng Docker layer caching)
RUN ./gradlew dependencies --no-daemon || true

# Copy toàn bộ mã nguồn
COPY src src

# Đóng gói ứng dụng thành tệp JAR (bỏ qua unit test vì đã chạy ở Job test trong CI)
RUN ./gradlew bootJar -x test --no-daemon

# ==========================================
# Stage 2: Môi trường thực thi tối giản (Runtime)
# ==========================================
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Tạo người dùng non-root 'spring' vì lý do bảo mật
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy tệp thực thi JAR từ Stage builder sang Stage runtime
COPY --from=builder /app/build/libs/*.jar app.jar

# Mở cổng 8080 theo chuẩn Spring Boot
EXPOSE 8080

# Thiết lập điểm khởi động cho container
ENTRYPOINT ["java", "-jar", "app.jar"]
