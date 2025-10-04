# GitHub 설정 가이드

## 🚀 Invariant 프로젝트 GitHub 업로드

### 1. GitHub에서 저장소 생성

1. **GitHub.com** 접속 후 로그인
2. **"New repository"** 클릭
3. **Repository name**: `Invariant`
4. **Description**: `Master Project Hub - 모든 프로젝트들의 통합 관리 시스템`
5. **Public** 선택
6. **"Create repository"** 클릭

### 2. 로컬에서 GitHub 연결 및 푸시

```bash
# 현재 디렉토리에서 실행
cd /home/darc0/projects/project_0

# GitHub에 푸시
git push -u origin main
```

### 3. 첫 번째 릴리즈 생성

1. GitHub 저장소 페이지에서 **"Releases"** 클릭
2. **"Create a new release"** 클릭
3. **Tag version**: `v1.0.0`
4. **Release title**: `Invariant v1.0.0`
5. **Description**:
   ```markdown
   # Invariant v1.0.0
   
   ## 🚀 Master Project Hub
   
   모든 프로젝트들을 통합 관리하는 메인 허브 시스템
   
   ### 주요 기능
   - 통합 프로젝트 관리
   - GitHub 기반 자동 업데이트  
   - 버전 관리 (안정화/베타)
   - 원클릭 실행 및 설치
   - GUI 인터페이스
   
   ### 설치 방법
   1. `Invariant_v1.0.0.zip` 다운로드
   2. 압축 해제
   3. `python Master_Launcher.py` 실행
   
   ### 요구사항
   - Python 3.7+
   - tkinter
   - Windows 10/11
   ```
6. **"Attach binaries"**에서 `Invariant_v1.0.0.zip` 파일 업로드
7. **"Publish release"** 클릭

### 4. 확인사항

업로드 완료 후 다음 URL들이 정상 작동하는지 확인:
- 저장소: https://github.com/DARC0625/Invariant
- 릴리즈: https://github.com/DARC0625/Invariant/releases/tag/v1.0.0
- 다운로드: https://github.com/DARC0625/Invariant/releases/download/v1.0.0/Invariant_v1.0.0.zip

### 5. 향후 업데이트 방법

새 버전이 있을 때:
1. 코드 수정 후 커밋
2. `python create_release.py [새버전]` 실행
3. GitHub에서 새 릴리즈 생성
4. 생성된 ZIP 파일 업로드

---

## 📁 현재 파일 구조

```
project_0/
├── Master_Launcher.py          # 메인 GUI 런처
├── Project_Manager.py          # 프로젝트 관리 유틸리티
├── README.md                   # 프로젝트 문서
├── requirements.txt            # 필요한 패키지
├── install.py                  # 설치 스크립트
├── start_invariant.bat         # Windows 실행 파일
├── create_release.py           # 릴리즈 생성 스크립트
├── version.json                # 버전 정보
├── .gitignore                  # Git 무시 파일
├── Invariant_v1.0.0.zip        # 릴리즈 패키지
└── GITHUB_SETUP_GUIDE.md       # 이 가이드
```

## 🎯 Invariant의 역할

- **통합 관리**: 모든 프로젝트들을 한 곳에서 관리
- **자동 업데이트**: GitHub 기반 자동 업데이트 시스템
- **원클릭 실행**: 각 프로젝트별 원클릭 실행 및 설치
- **확장성**: 새로운 프로젝트 자동 추가 및 관리

모든 준비가 완료되었습니다! GitHub에서 저장소를 생성하고 위의 단계를 따라 진행하시면 됩니다.
