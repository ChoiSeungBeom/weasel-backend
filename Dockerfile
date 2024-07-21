# Gradle과 JDK 21을 포함하는 이미지
FROM openjdk:21-jdk-slim

# 작업 디렉토리 설정
WORKDIR /app

# Gradle Wrapper 및 Gradle 설정 파일 복사
COPY gradle/ gradle/
COPY gradlew .
COPY gradlew.bat .
COPY settings.gradle .
COPY app/build.gradle /app/build.gradle
COPY app/ /app/

# Gradle 의존성 설치 및 애플리케이션 빌드
# Jenkins에서 이 단계는 수행되므로, Dockerfile에서는 이 단계가 없습니다.

# 빌드된 JAR 파일 복사
COPY app/build/libs/*.jar app.jar

# 포트 노출
EXPOSE 8080

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "app.jar"]
