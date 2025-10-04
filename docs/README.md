# 🚀 Invariant - Master Project Hub

모든 프로젝트들을 통합 관리하는 메인 허브 시스템

## 🎯 주요 기능

- **통합 관리**: 모든 프로젝트들을 한 곳에서 관리
- **자동 업데이트**: GitHub 기반 자동 업데이트 시스템
- **버전 관리**: 안정화/베타 버전 선택 가능
- **원클릭 실행**: 각 프로젝트별 원클릭 실행
- **설치/제거**: 프로젝트 설치 및 제거 관리

## 📋 관리되는 프로젝트들

### Project 1
- **설명**: 첫 번째 프로젝트
- **저장소**: `DARC0625/Project1`
- **실행 파일**: `main.py`

### Project 2
- **설명**: 두 번째 프로젝트
- **저장소**: `DARC0625/Project2`
- **실행 파일**: `app.py`

### Project 3
- **설명**: 세 번째 프로젝트
- **저장소**: `DARC0625/Project3`
- **실행 파일**: `start.py`

### Project 4 - AI Agent
- **설명**: Android 에뮬레이터 AI 에이전트
- **저장소**: `DARC0625/Project4_AI_Agent`
- **실행 파일**: `windows_ai_agent_gui.py`
- **설치 스크립트**: `install_complete.bat`

## 🚀 사용 방법

### 1. Master Launcher 실행
```bash
python Master_Launcher.py
```

### 2. 프로젝트 관리
- **프로젝트 선택**: 왼쪽 목록에서 원하는 프로젝트 선택
- **업데이트 확인**: 선택한 프로젝트의 최신 버전 확인
- **다운로드/설치**: 최신 버전 다운로드 및 설치
- **실행**: 설치된 프로젝트 실행
- **제거**: 불필요한 프로젝트 제거

### 3. 전체 제어
- **모든 프로젝트 업데이트 확인**: 모든 프로젝트의 업데이트 상태 확인
- **새 프로젝트 추가**: 새로운 프로젝트 등록
- **설정**: GitHub 계정 및 기본 설정 변경
- **프로젝트 새로고침**: 프로젝트 목록 새로고침

## ⚙️ 설정

### GitHub 설정
- **사용자명**: `DARC0625`
- **저장소 형식**: `Project[N]` 또는 `Project[N]_[Name]`

### 설치 경로
- **기본 경로**: `C:/Projects/`
- **프로젝트별 경로**: `C:/Projects/Project[N]/`

## 🔄 자동 업데이트 시스템

### 버전 관리
- **안정화 버전**: 안정적인 기능들만 포함
- **베타 버전**: 새로운 기능과 실험적 기능 포함

### 업데이트 프로세스
1. GitHub API를 통한 릴리즈 정보 확인
2. 현재 설치된 버전과 비교
3. 업데이트 필요 시 자동 알림
4. 원클릭 다운로드 및 설치

## 📁 프로젝트 구조

```
Project0/
├── Master_Launcher.py          # 메인 런처
├── README.md                   # 프로젝트 설명
├── master_config.json          # 설정 파일
└── temp/                       # 임시 다운로드 폴더
```

## 🛠️ 새 프로젝트 추가

새로운 프로젝트를 추가하려면:

1. `default_projects` 딕셔너리에 프로젝트 정보 추가
2. GitHub에 해당 저장소 생성
3. 릴리즈 생성 및 ZIP 파일 업로드

### 프로젝트 정보 형식
```python
"ProjectN": {
    "name": "Project N - 이름",
    "description": "프로젝트 설명",
    "repo_name": "ProjectN_이름",
    "main_file": "실행파일.py",
    "install_script": "설치스크립트.bat"
}
```

## 🔧 요구사항

- **Python**: 3.7+
- **tkinter**: GUI 인터페이스
- **urllib**: HTTP 요청
- **zipfile**: ZIP 파일 처리
- **subprocess**: 외부 프로세스 실행

## 📝 라이센스

MIT License

## 🤝 기여

새로운 프로젝트나 기능 추가는 언제든 환영합니다!

---

**Master Project Hub** - 모든 프로젝트의 중심
