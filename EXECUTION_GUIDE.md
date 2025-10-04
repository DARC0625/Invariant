# Invariant v1.1.0 실행 가이드

## 🚀 실행 방법

### 1. GitHub에서 다운로드

#### 방법 1: Releases에서 다운로드 (권장)
1. [GitHub Releases](https://github.com/DARC0625/Invariant/releases) 페이지 방문
2. 최신 버전 `Invariant v14` (또는 최신 버전) 클릭
3. `Invariant_Portable_Windows.zip` 다운로드
4. 압축 해제

#### 방법 2: GitHub에서 직접 다운로드
1. [Invariant Repository](https://github.com/DARC0625/Invariant) 방문
2. 초록색 `Code` 버튼 클릭
3. `Download ZIP` 선택
4. 압축 해제 후 `Invariant_Portable` 폴더 사용

### 2. Windows에서 실행

#### 포터블 버전 (권장)
1. `Invariant_Portable` 폴더를 원하는 위치에 복사
2. `Invariant.exe` 더블클릭으로 실행
3. 또는 `run.bat` 더블클릭으로 실행

#### 시스템 설치 버전
1. `install.bat` 파일을 관리자 권한으로 실행
2. 설치 완료 후 바탕화면 바로가기 생성
3. `C:\Invariant\Invariant.exe` 실행

### 3. 실행 확인

#### 정상 실행 시
- 사이버틱 스타일의 GUI 창이 열림
- "INVARIANT" 제목과 네온 그린 색상 표시
- 8개의 프로젝트 카드가 그리드 형태로 표시
- 하단에 컨트롤 패널 (DEPLOY, UPDATE, TERMINATE, CONFIGURE, STATUS)

#### 실행 오류 시
1. **Windows Defender 경고**
   - "추가 정보" 클릭
   - "실행" 선택
   - "Windows Defender SmartScreen"에서 "추가 정보" → "실행"

2. **바이러스 백신 차단**
   - 바이러스 백신에서 예외 추가
   - Invariant 폴더를 신뢰할 수 있는 위치로 설정

3. **관리자 권한 필요**
   - `Invariant.exe` 우클릭
   - "관리자 권한으로 실행" 선택

4. **PyQt5 관련 오류**
   - Windows에서 PyQt5가 설치되지 않은 경우
   - `install.bat` 실행하여 시스템에 설치

### 4. 첫 실행 설정

1. **프로젝트 목록 확인**
   - 8개의 프로젝트 카드 표시
   - 각 프로젝트의 상태 (ACTIVE/STANDBY) 확인
   - 버전 정보 표시

2. **UI 테스트**
   - 프로젝트 카드에 마우스 호버 (네온 글로우 효과)
   - 컨트롤 버튼 클릭 테스트
   - 스크롤 기능 테스트

3. **시스템 트레이 확인**
   - 작업 표시줄 우측 하단에 Invariant 아이콘 표시
   - 우클릭으로 메뉴 확인

### 5. 문제 해결

#### 일반적인 문제들

**문제**: "Invariant.exe를 찾을 수 없습니다"
**해결**: 
- 파일이 완전히 다운로드되었는지 확인
- 바이러스 백신이 파일을 삭제했는지 확인
- 다시 다운로드 시도

**문제**: "PyQt5 모듈을 찾을 수 없습니다"
**해결**: 
- `install.bat` 실행하여 시스템에 설치
- 또는 포터블 버전 사용 (PyQt5 포함됨)

**문제**: "권한이 부족합니다"
**해결**: 
- 관리자 권한으로 실행
- Windows 사용자 계정 컨트롤(UAC) 설정 확인
- 바이러스 백신 실시간 보호 일시 비활성화

**문제**: GUI가 표시되지 않음
**해결**: 
- Windows 호환성 모드 설정
- 그래픽 드라이버 업데이트
- .NET Framework 최신 버전 설치

#### 고급 문제 해결

**문제**: 프로젝트 카드가 표시되지 않음
**해결**: 
- 화면 해상도 확인 (최소 1000x600 필요)
- 그래픽 카드 드라이버 업데이트
- Windows 테마 설정 확인

**문제**: 네온 효과가 표시되지 않음
**해결**: 
- 하드웨어 가속 활성화
- 그래픽 카드 성능 설정 확인
- Windows 시각 효과 설정 확인

### 6. 시스템 요구사항

#### 최소 요구사항
- **운영체제**: Windows 10 (64-bit) 이상
- **메모리**: 4GB RAM
- **저장공간**: 2GB 여유 공간
- **해상도**: 1000x600 이상
- **그래픽**: DirectX 11 지원

#### 권장 요구사항
- **운영체제**: Windows 11 (64-bit)
- **메모리**: 8GB RAM 이상
- **저장공간**: 5GB 여유 공간
- **해상도**: 1920x1080 이상
- **그래픽**: 전용 그래픽 카드

### 7. 지원 및 문의

#### 공식 채널
- **GitHub Issues**: [버그 리포트](https://github.com/DARC0625/Invariant/issues)
- **GitHub Discussions**: [기능 요청](https://github.com/DARC0625/Invariant/discussions)

#### 커뮤니티
- **Discord**: [실시간 지원](링크)
- **Reddit**: [커뮤니티](링크)

---

## 🎉 실행 완료!

Invariant v1.1.0이 성공적으로 실행되었습니다. 이제 사이버틱 UI로 프로젝트를 관리할 수 있습니다!

### 다음 단계
1. **프로젝트 탐색**: 8개의 프로젝트 카드 확인
2. **UI 테스트**: 호버 효과 및 버튼 동작 확인
3. **기능 테스트**: DEPLOY, UPDATE, CONFIGURE 버튼 테스트
4. **피드백 제공**: GitHub Issues에 사용 후기 작성

**Happy Coding with Invariant v1.1.0! 🚀**
