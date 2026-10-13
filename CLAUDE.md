# 내 차 찾기 (pirvate-parking)

주차 차량 찾기 웹(<https://mobile-find-my-car.vercel.app/find>)으로 들어가는 바로가기 앱. 같은 소스로 PWA와 Android APK를 만든다.
원본 주차장 웹은 우리가 관리하지 않는다 (수정 불가, iframe 허용 여부도 모름).

새 세션은 `docs/HANDOFF.md`(현재 상태·다음 할 일)부터 읽는다.

## 작업 규칙

- 답변과 문서는 한국어로 쓴다.
- 요청받은 부분만 바꾼다. 다른 곳을 바꿔야 하면 먼저 묻는다.
- 모든 작업 내역과 특이사항을 `docs/work-log.md`에 날짜별로 남긴다.

## 구조

- `web/` PWA 원본 (index.html, manifest.webmanifest, sw.js, offline.html, icons/)
- `android/` 네이티브 WebView 앱. `app/build.gradle`의 `assets.srcDirs += ["$rootDir/../web"]`로 `web/`을 그대로 assets에 넣는다 → 웹을 고치면 APK에 반영됨
  - 패키지 `com.parking.findmycar`, minSdk 24, targetSdk/compileSdk 35, AGP 8.7.3, Gradle 8.11.1 래퍼, Java 17
  - `MainActivity.java`: 앱 안 WebView로 index.html을 띄우고, 바로가기 버튼을 누르면 주차장 웹을 앱 안에서 연다. 뒤로가기, 오프라인 시 offline.html, 시스템바 여백 처리
- `.github/workflows/build-apk.yml` main/master 푸시 또는 수동 실행 시 디버그 APK 빌드 → Artifacts `find-my-car-apk`
- `build-apk.bat` + `tools/build-apk.ps1` Windows PC에서 더블클릭 빌드 (JDK·SDK 없으면 E:\android-build에 설치) → `dist/find-my-car.apk`, 로그 `build-log.txt`
- `extras/` 이전 시안 (iframe 래퍼, 단일 파일 바로가기)

## 빌드

- 클라우드 작업 환경에서는 Google Android SDK/Maven 서버 접속이 막혀 있어 로컬 Gradle 빌드가 안 된다. APK 빌드·검증은 GitHub Actions(`Build APK` 워크플로)로 한다.
  - 실행: `gh workflow run build-apk.yml` / 결과 확인: `gh run list --workflow build-apk.yml`, `gh run view <id> --log-failed`
- Windows PC: `build-apk.bat` 더블클릭, 또는 Android Studio에서 `android/` 열기 → Build APK(s)

## 주의

- 디버그 서명 APK라 직접 설치용. Play 스토어 배포 시 release 서명 키 필요(키 파일은 저장소에 올리지 않는다).
