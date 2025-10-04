#!/usr/bin/env python3
"""
GitHub 저장소 설정 및 초기 업로드 스크립트
Invariant 프로젝트용
"""

import os
import subprocess
import json
from pathlib import Path

def setup_git():
    """Git 저장소 초기화 및 설정"""
    print("🔧 Git 저장소 설정 중...")
    
    # Git 초기화
    subprocess.run(["git", "init"], check=True)
    
    print("✅ Git 저장소 초기화 완료")

def create_requirements():
    """requirements.txt 생성"""
    requirements_content = """tkinter
urllib3
requests
"""
    
    with open("requirements.txt", "w", encoding="utf-8") as f:
        f.write(requirements_content)
    
    print("✅ requirements.txt 생성 완료")

def create_launcher_bat():
    """Windows 실행용 배치 파일 생성"""
    launcher_bat = """@echo off
title Invariant - Master Project Hub
echo.
echo ========================================
echo    Invariant - Master Project Hub
echo ========================================
echo.
echo Starting Invariant...
echo.

python Master_Launcher.py

if %errorLevel% neq 0 (
    echo.
    echo Error: Failed to start Invariant
    echo Please make sure Python is installed
    pause
)
"""
    
    with open("start_invariant.bat", "w", encoding="utf-8") as f:
        f.write(launcher_bat)
    
    print("✅ Windows 실행 파일 생성 완료")

def create_install_script():
    """설치 스크립트 생성"""
    install_script = """#!/usr/bin/env python3
\"\"\"
Invariant 설치 스크립트
\"\"\"

import os
import sys
import subprocess
import urllib.request
from pathlib import Path

def install_requirements():
    \"\"\"필요한 패키지 설치\"\"\"
    print("📦 필요한 패키지 설치 중...")
    
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ 패키지 설치 완료")
        return True
    except Exception as e:
        print(f"❌ 패키지 설치 실패: {e}")
        return False

def create_desktop_shortcut():
    \"\"\"바탕화면 바로가기 생성\"\"\"
    try:
        desktop = Path.home() / "Desktop"
        if not desktop.exists():
            desktop = Path.home() / "바탕화면"
        
        shortcut_path = desktop / "Invariant.bat"
        
        with open(shortcut_path, 'w', encoding='utf-8') as f:
            f.write(f\"\"\"@echo off
title Invariant
cd /d "{Path.cwd()}"
python Master_Launcher.py
pause\"\"\")
        
        print(f"✅ 바탕화면 바로가기 생성: {shortcut_path}")
        return True
        
    except Exception as e:
        print(f"❌ 바로가기 생성 실패: {e}")
        return False

def main():
    \"\"\"메인 설치 함수\"\"\"
    print("🚀 Invariant 설치 시작")
    print("=" * 50)
    
    # 패키지 설치
    if not install_requirements():
        return False
    
    # 바로가기 생성
    create_desktop_shortcut()
    
    print("\\n✅ Invariant 설치 완료!")
    print("\\n📝 사용 방법:")
    print("1. 바탕화면의 'Invariant' 바로가기를 더블클릭")
    print("2. 또는 'python Master_Launcher.py' 명령어 실행")
    
    return True

if __name__ == "__main__":
    main()
"""
    
    with open("install.py", "w", encoding="utf-8") as f:
        f.write(install_script)
    
    print("✅ 설치 스크립트 생성 완료")

def create_release_script():
    """릴리즈 생성 스크립트"""
    release_script = """#!/usr/bin/env python3
\"\"\"
Invariant 릴리즈 생성 스크립트
\"\"\"

import os
import sys
import zipfile
import json
from pathlib import Path

def create_release(version, is_beta=False):
    \"\"\"릴리즈 생성\"\"\"
    
    # 버전 정보 업데이트
    version_info = {
        "version": version,
        "build_date": str(Path().cwd()),
        "description": f"Invariant v{version} {'(Beta)' if is_beta else ''}",
        "project_name": "Invariant"
    }
    
    with open("version.json", "w", encoding="utf-8") as f:
        json.dump(version_info, f, indent=2, ensure_ascii=False)
    
    # 릴리즈 파일 생성
    release_files = [
        "Master_Launcher.py",
        "Project_Manager.py",
        "install.py",
        "start_invariant.bat",
        "requirements.txt",
        "README.md",
        "version.json",
        ".gitignore"
    ]
    
    zip_name = f"Invariant_v{version}.zip"
    
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file in release_files:
            if os.path.exists(file):
                zipf.write(file)
                print(f"Added {file}")
    
    print(f"Release package created: {zip_name}")
    return zip_name

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python create_release.py <version> [beta]")
        sys.exit(1)
    
    version = sys.argv[1]
    is_beta = len(sys.argv) > 2 and sys.argv[2].lower() == "beta"
    
    create_release(version, is_beta)
"""
    
    with open("create_release.py", "w", encoding="utf-8") as f:
        f.write(release_script)
    
    print("✅ 릴리즈 생성 스크립트 생성 완료")

def main():
    """메인 함수"""
    print("🚀 Invariant GitHub 저장소 설정 시작")
    print("=" * 50)
    
    try:
        # Git 설정
        setup_git()
        
        # 필요한 파일들 생성
        create_requirements()
        create_launcher_bat()
        create_install_script()
        create_release_script()
        
        print("\\n📝 다음 단계:")
        print("1. GitHub에서 새 저장소 'Invariant' 생성")
        print("2. git remote add origin https://github.com/DARC0625/Invariant.git")
        print("3. git add .")
        print("4. git commit -m 'Initial commit - Invariant v1.0.0'")
        print("5. git push -u origin main")
        print("\\n🎯 첫 릴리즈 생성:")
        print("python create_release.py 1.0.0")
        print("GitHub에서 릴리즈 생성 및 ZIP 파일 업로드")
        
        print("\\n✅ Invariant 설정 완료!")
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
