# 작업 기록

## 2026-10-11

- 주차장 웹(<https://mobile-find-my-car.vercel.app/find>)을 감싸는 iframe 래퍼 작성 → `extras/iframe-wrapper.html`
  - 특이사항: 원본 사이트를 관리하지 않아, 원본이 다른 페이지 안에 들어가는 것을 막아 두었다면 iframe 방식은 열리지 않음
- iframe 대신 바로가기 방식으로 변경 → `extras/shortcut.html`
- 바로가기를 PWA로 변환 → `web/` (manifest, 서비스 워커, 오프라인 안내, 아이콘 5종)

## 2026-10-12

- `C:\Develop\parking` 폴더로 소스 이관
  - `web/` PWA 원본, `extras/` 이전 시안 2종
- APK용 Android 프로젝트 작성 → `android/`
  - 방식: 네이티브 WebView 앱 (외부 라이브러리 없음). `web/` 폴더를 Gradle 설정으로 앱에 직접 포함
  - 바로가기 버튼을 누르면 주차장 웹을 앱 안에서 엶 → APK에서는 iframe 차단 문제가 없음
  - 뒤로가기, 오프라인 안내, Android 15 화면 끝까지 그리기(상태바 겹침) 대응
  - 런처 아이콘: 남색 바탕 노란 P (적응형 아이콘 + 기존형 5개 해상도)
  - Gradle 8.11.1 래퍼, Android Gradle Plugin 8.7.3, compileSdk/targetSdk 35, minSdk 24
- GitHub Actions 빌드 설정 → `.github/workflows/build-apk.yml`
- 특이사항
  - Claude 작업 환경에서는 Google의 Android SDK·Maven 서버 접속이 막혀 있어 **APK를 직접 빌드하지 못함**. 빌드는 Android Studio 또는 GitHub Actions로 진행해야 함 (방법은 README 참고)
  - 같은 이유로 빌드 검증을 하지 못함. 첫 빌드에서 오류가 나면 메시지를 전달받아 수정 예정
  - 디버그 서명 APK라 직접 설치용. Play 스토어 배포 시 release 서명 필요
  - 커밋하지 않음 (사용자가 Cursor에서 직접 커밋)
- Windows 더블클릭 빌드 추가 → `build-apk.bat`, `tools/build-apk.ps1`
  - JDK 17·Android SDK를 찾고 없으면 `E:\android-build`에 설치, Gradle 캐시도 같은 곳에 둠 (C 드라이브 용량 보호)
  - 결과 `dist/find-my-car.apk`, 로그 `build-log.txt` (둘 다 .gitignore)
  - 특이사항: jpd013843 PC에서 탐색기 실행을 시도했으나 원격 조작으로는 실행하지 못함. 사용자가 daniel PC에서 작업하려 했으나 이 대화는 jpd013843에 연결되어 있어 폴더 추가 불가

## 2026-10-13

- GitHub 저장소 `kk00701903-hub/pirvate-parking`(빈 저장소)에 전체 소스 첫 푸시 (사용자 요청)
- 클라우드 작업 준비: `CLAUDE.md` 추가 (구조, 작업 규칙, 빌드 방법). 이후 APK 빌드·검증은 GitHub Actions `Build APK` 워크플로로 진행
- 특이사항: 로컬 PC(jpd013843) 폴더 연결 해제는 Claude가 할 수 없어 사용자가 데스크톱 앱에서 직접 해야 함
- GitHub Actions 첫 빌드 실패 → 원인: `android-actions/setup-android@v3` 단계 실패. GitHub 러너에 Android SDK가 이미 있어 그 단계를 빼고 checkout·setup-java를 v5로 올림
- 두 번째 빌드 성공 (46초). Artifacts `find-my-car-apk`로 APK 생성 확인 — 처음으로 빌드 검증 완료
  - 클라우드 작업 환경에서는 Artifacts 내려받기가 막혀 있어 APK 내용은 직접 열어 보지 못함. 사용자가 Actions 화면에서 내려받아 설치 확인 필요
- 이전 대화 삭제에 대비해 인수인계 문서 `docs/HANDOFF.md` 작성, `CLAUDE.md`에서 연결
