
FROM openjdk:17-jdk-slim

# 작업 디렉토리 설정
WORKDIR /app

# Gradle Wrapper 및 Gradle 설정 파일 복사
COPY gradle/ gradle/
COPY gradlew .
COPY gradlew.bat .
COPY settings.gradle .
COPY app/build.gradle /app/build.gradle
COPY app/ /app/


# 빌드된 JAR 파일 복사
COPY app/build/libs/*.jar app.jar

# 포트 노출
EXPOSE 8080

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "app.jar"]
