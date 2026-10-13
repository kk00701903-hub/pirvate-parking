# 인수인계 (2026-10-13)

이전 대화(삭제 예정)에서 한 작업과 지금 상태. 새 클라우드 세션은 이 파일과 `CLAUDE.md`, `docs/work-log.md`부터 읽는다.

## 지금 상태

| 항목 | 상태 |
|---|---|
| 저장소 | `kk00701903-hub/pirvate-parking`, 브랜치 `main` |
| PWA | `web/` 완성. 아직 어디에도 배포하지 않음 |
| APK | GitHub Actions `Build APK`로 빌드 성공 (main 푸시마다 자동, 약 50초). Actions → 실행 → Artifacts `find-my-car-apk` |
| 서명 | 디버그 서명 (직접 설치용) |
| 휴대폰 설치 확인 | **아직 안 함** |

## 지금까지의 결정

1. 원본 주차장 웹(<https://mobile-find-my-car.vercel.app/find>)은 우리가 관리하지 않는다.
2. 웹 페이지 안에 iframe으로 넣는 방식은 원본이 막아 두었을 수 있어서 쓰지 않고, 바로가기 화면 + 버튼 방식으로 정했다 (`extras/`에 두 시안 보관).
3. 바로가기 화면을 PWA로 만들었다 (`web/`).
4. APK는 `web/`을 그대로 담는 네이티브 WebView 앱으로 만들었다. 앱 안에서는 iframe 제한이 없어서 버튼을 누르면 주차장 웹이 **앱 안에서** 열린다.

## 다음에 할 수 있는 일

- [ ] Actions에서 APK를 내려받아 휴대폰에 설치하고 동작 확인 (첫 화면, 버튼, 뒤로가기, 비행기 모드에서 오프라인 안내)
- [ ] 필요하면 앱을 열자마자 주차장 웹으로 바로 들어가게 변경 (지금은 바로가기 화면을 거친다)
- [ ] 주차장 웹이 위치·카메라 권한을 쓰면 WebView 권한 처리 추가 (지금은 넣지 않음)
- [ ] PWA 배포: `web/`을 Vercel 등 HTTPS 주소에 올리기
- [ ] Play 스토어 배포 시 release 서명 키 생성 + GitHub Secrets 등록 + release 빌드 워크플로 추가
- [ ] Actions 경고 정리: `actions/upload-artifact@v4`가 Node 20 기반이라 경고가 뜬다 (빌드에는 영향 없음)

## 작업 환경 메모

- 클라우드 작업 환경에서는 Google Android SDK·Maven 서버 접속이 막혀 있어 로컬 Gradle 빌드가 안 된다. 빌드와 검증은 GitHub Actions로 한다.
- 클라우드 작업 환경에서는 Actions 로그·Artifacts 내려받기도 막혀 있었다. 실패 원인은 `gh run view <id>`의 단계별 결과와 `gh api .../check-runs/<job id>/annotations`로 확인했다.
- 예전 로컬 사본 `C:\Develop\parking`(PC jpd013843)은 이 저장소보다 오래된 버전이다 (CLAUDE.md·워크플로 수정 없음). 앞으로는 이 저장소가 기준이다.
- Claude 아티팩트로 바로가기 페이지를 하나 게시해 두었다 (claude.ai 아티팩트 목록의 「내 차 찾기」). 저장소의 `extras/shortcut.html`과 같은 내용이다.
