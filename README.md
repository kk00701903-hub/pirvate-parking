# 내 차 찾기 (parking)

주차 차량 찾기 웹(<https://mobile-find-my-car.vercel.app/find>)으로 들어가는 바로가기 앱.
같은 소스로 **PWA(웹 설치)** 와 **Android APK** 두 가지를 만든다.

## 폴더 구성

| 폴더 | 내용 |
|---|---|
| `web/` | PWA 원본. `index.html`(바로가기 화면), `manifest.webmanifest`, `sw.js`(서비스 워커), `offline.html`, `icons/` |
| `android/` | APK용 Android 프로젝트. `web/` 폴더를 그대로 앱에 넣어 WebView로 띄운다 |
| `extras/` | 이전에 만든 시안. `iframe-wrapper.html`(iframe 감싸기), `shortcut.html`(바로가기 단일 파일) |
| `.github/workflows/build-apk.yml` | GitHub에 올리면 APK를 자동으로 만드는 설정 |
| `docs/work-log.md` | 작업 기록 |

## APK 동작

1. 앱을 열면 `web/index.html` 바로가기 화면이 뜬다.
2. 「내 차 찾으러 가기」를 누르면 주차장 웹이 **앱 안에서** 열린다 (브라우저로 넘어가지 않음).
3. 뒤로가기를 누르면 이전 화면, 첫 화면에서 누르면 앱 종료.
4. 인터넷이 끊기면 `offline.html` 안내가 뜬다.

`web/`을 고치면 다음 빌드부터 APK에도 그대로 반영된다.

## APK 만들기

### 방법 0. 더블클릭 빌드 (Windows PC)

`build-apk.bat`을 더블클릭한다. JDK·Android SDK가 없으면 자동으로 내려받아 `E:\android-build`(E 드라이브가 없으면 `%LOCALAPPDATA%\parking-android-build`)에 설치한다.
결과: `dist\find-my-car.apk`, 로그: `build-log.txt`. 처음에는 내려받느라 10~20분쯤 걸린다.

### 방법 1. Android Studio (PC에서)

1. Android Studio 설치 (처음 실행 시 Android SDK가 자동 설치됨)
2. `File > Open` → `C:\Develop\parking\android` 폴더 선택
3. 동기화(Gradle Sync)가 끝나면 `Build > Build App Bundle(s) / APK(s) > Build APK(s)`
4. 결과: `android\app\build\outputs\apk\debug\app-debug.apk`

명령줄로 하려면 (Android SDK가 설치되어 있어야 함):

```bat
cd C:\Develop\parking\android
gradlew.bat assembleDebug
```

### 방법 2. GitHub Actions (PC에 아무것도 설치하지 않고)

1. 이 폴더를 GitHub 저장소에 올린다 (main 또는 master 브랜치)
2. 저장소 `Actions` 탭 → `Build APK` 실행이 끝나면
3. 실행 화면 아래 `Artifacts` 의 `find-my-car-apk` 를 내려받아 압축을 풀면 `find-my-car.apk`

`Actions` 탭에서 `Run workflow` 버튼으로 수동 실행도 된다.

## 휴대폰에 설치

APK 파일을 휴대폰으로 옮겨 열면 설치된다. 처음에는 「출처를 알 수 없는 앱 설치 허용」을 켜야 한다.
지금 빌드는 **디버그 서명**이라 직접 설치용이다. Play 스토어에 올리려면 별도 서명 키로 release 빌드를 해야 한다.

## PWA로 쓰기

`web/` 폴더를 HTTPS 주소(Vercel·Netlify 등)에 그대로 올리면 휴대폰에서 「홈 화면에 추가」로 설치된다.

## 앱 정보

- 앱 이름: 내 차 찾기
- 패키지: `com.parking.findmycar`
- 최소 Android 7.0 (API 24), 대상 Android 15 (API 35)
