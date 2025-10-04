#!/usr/bin/env python3
"""
Invariant Complete Build Script
모든 컴포넌트를 빌드하고 통합 패키지를 생성하는 스크립트
"""

import os
import sys
import json
import zipfile
import shutil
from pathlib import Path
from datetime import datetime

def create_build_info():
    """빌드 정보 생성"""
    build_info = {
        "build_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "version": "1.0.0",
        "description": "Invariant - Master Project Hub Complete Package",
        "components": [
            "Invariant_Cyberpunk.py",
            "Project_Template.py", 
            "EXE_Builder.py",
            "Invariant_Installer.py",
            "Master_Launcher.py",
            "Project_Manager.py"
        ],
        "features": [
            "통합 프로젝트 관리",
            "사이버틱 UI 디자인",
            "EXE 빌더 시스템",
            "자동 설치 프로그램",
            "GitHub 기반 업데이트",
            "프로젝트 템플릿 시스템"
        ]
    }
    
    with open("build_info.json", "w", encoding="utf-8") as f:
        json.dump(build_info, f, indent=2, ensure_ascii=False)
    
    print("✅ Build info created")
    return build_info

def create_complete_package():
    """완전한 패키지 생성"""
    print("📦 Creating complete Invariant package...")
    
    # 패키지 파일 목록
    package_files = [
        # 메인 파일들
        "Invariant_Cyberpunk.py",
        "Project_Template.py",
        "EXE_Builder.py", 
        "Invariant_Installer.py",
        "Master_Launcher.py",
        "Project_Manager.py",
        
        # 설정 및 문서
        "README.md",
        "requirements.txt",
        "version.json",
        "build_info.json",
        ".gitignore",
        
        # 스크립트들
        "create_release.py",
        "setup_git.py",
        "start_invariant.bat"
    ]
    
    # ZIP 패키지 생성
    package_name = f"Invariant_Complete_v1.0.0_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip"
    
    with zipfile.ZipFile(package_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file in package_files:
            if os.path.exists(file):
                zipf.write(file, file)
                print(f"Added: {file}")
            else:
                print(f"⚠️ File not found: {file}")
    
    print(f"✅ Complete package created: {package_name}")
    return package_name

def create_installer_package():
    """설치 프로그램 전용 패키지 생성"""
    print("🔧 Creating installer package...")
    
    # 설치 프로그램 파일들
    installer_files = [
        "Invariant_Installer.py",
        "requirements.txt",
        "README.md",
        "version.json"
    ]
    
    # ZIP 패키지 생성
    package_name = f"Invariant_Installer_v1.0.0_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip"
    
    with zipfile.ZipFile(package_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file in installer_files:
            if os.path.exists(file):
                zipf.write(file, file)
                print(f"Added: {file}")
            else:
                print(f"⚠️ File not found: {file}")
    
    print(f"✅ Installer package created: {package_name}")
    return package_name

def create_development_package():
    """개발자용 패키지 생성"""
    print("🛠️ Creating development package...")
    
    # 개발용 파일들
    dev_files = [
        # 소스 코드
        "Invariant_Cyberpunk.py",
        "Project_Template.py",
        "EXE_Builder.py",
        "Invariant_Installer.py",
        "Master_Launcher.py",
        "Project_Manager.py",
        
        # 빌드 스크립트
        "build_invariant.py",
        "create_release.py",
        "setup_git.py",
        
        # 설정 파일
        "requirements.txt",
        "version.json",
        "build_info.json",
        ".gitignore",
        
        # 문서
        "README.md",
        "GITHUB_SETUP_GUIDE.md"
    ]
    
    # ZIP 패키지 생성
    package_name = f"Invariant_Development_v1.0.0_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip"
    
    with zipfile.ZipFile(package_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file in dev_files:
            if os.path.exists(file):
                zipf.write(file, file)
                print(f"Added: {file}")
            else:
                print(f"⚠️ File not found: {file}")
    
    print(f"✅ Development package created: {package_name}")
    return package_name

def main():
    """메인 함수"""
    print("🚀 Invariant Complete Build System")
    print("=" * 60)
    
    try:
        # 1. 빌드 정보 생성
        build_info = create_build_info()
        
        # 2. 완전한 패키지 생성
        complete_package = create_complete_package()
        
        # 3. 설치 프로그램 패키지 생성
        installer_package = create_installer_package()
        
        # 4. 개발자용 패키지 생성
        dev_package = create_development_package()
        
        # 결과 요약
        print("\n" + "=" * 60)
        print("BUILD SUMMARY")
        print("=" * 60)
        print(f"✅ Complete Package: {complete_package}")
        print(f"✅ Installer Package: {installer_package}")
        print(f"✅ Development Package: {dev_package}")
        print(f"✅ Build Info: build_info.json")
        
        print("\n📋 Package Contents:")
        for component in build_info["components"]:
            print(f"  - {component}")
        
        print("\n🎯 Features:")
        for feature in build_info["features"]:
            print(f"  - {feature}")
        
        print(f"\n🎉 Build completed successfully!")
        print(f"📅 Build Date: {build_info['build_date']}")
        print(f"🔢 Version: {build_info['version']}")
        
    except Exception as e:
        print(f"❌ Build failed: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
