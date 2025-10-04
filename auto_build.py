#!/usr/bin/env python3
"""
Auto Build Script for Invariant
자동으로 Windows EXE를 빌드하고 GitHub에 업로드하는 스크립트
"""

import os
import sys
import json
import subprocess
import shutil
from pathlib import Path
from datetime import datetime

def check_git_status():
    """Git 상태 확인"""
    try:
        result = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
        if result.stdout.strip():
            print("📝 Changes detected, committing...")
            return True
        else:
            print("✅ No changes to commit")
            return False
    except:
        print("❌ Git not available")
        return False

def commit_and_push():
    """변경사항 커밋 및 푸시"""
    try:
        # 변경사항 추가
        subprocess.run(["git", "add", "."], check=True)
        
        # 커밋
        commit_message = f"Auto build - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        subprocess.run(["git", "commit", "-m", commit_message], check=True)
        
        # 푸시
        subprocess.run(["git", "push", "origin", "main"], check=True)
        
        print("✅ Changes committed and pushed to GitHub")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Git operation failed: {e}")
        return False

def trigger_github_actions():
    """GitHub Actions 트리거"""
    print("🚀 GitHub Actions will automatically build Windows EXE")
    print("📋 Check the Actions tab in your GitHub repository")
    print("⏱️  Build usually takes 5-10 minutes")
    print("📦 Download the built EXE from the Releases section")

def create_local_build():
    """로컬에서 빌드 (테스트용)"""
    print("🔨 Creating local build for testing...")
    
    # 현재 빌드된 파일들 확인
    if os.path.exists("dist/Invariant.exe"):
        print("✅ Local EXE found")
        
        # 포터블 패키지 생성
        portable_dir = Path("Invariant_Portable_Local")
        portable_dir.mkdir(exist_ok=True)
        
        # 파일들 복사
        shutil.copy2("dist/Invariant.exe", portable_dir / "Invariant.exe")
        
        # 추가 파일들
        additional_files = ["version.json", "requirements.txt", "README.md"]
        for file in additional_files:
            if os.path.exists(file):
                shutil.copy2(file, portable_dir / file)
        
        # 실행 스크립트 생성
        run_script = '''@echo off
title Invariant - Master Project Hub
echo.
echo ========================================
echo    Invariant - Master Project Hub
echo ========================================
echo.
echo Starting Invariant...
echo.

Invariant.exe

if %errorLevel% neq 0 (
    echo.
    echo Error: Failed to start Invariant
    pause
)
'''
        
        with open(portable_dir / "run.bat", "w", encoding="utf-8") as f:
            f.write(run_script)
        
        print(f"✅ Local portable package created: {portable_dir}")
        return portable_dir
    else:
        print("❌ No local EXE found")
        return None

def main():
    """메인 함수"""
    print("🚀 Invariant Auto Build System")
    print("=" * 50)
    
    # 1. Git 상태 확인
    has_changes = check_git_status()
    
    if has_changes:
        # 2. 커밋 및 푸시
        if commit_and_push():
            # 3. GitHub Actions 트리거
            trigger_github_actions()
        else:
            print("❌ Failed to push changes")
            return 1
    else:
        print("ℹ️ No changes to build")
    
    # 4. 로컬 빌드 생성 (테스트용)
    local_build = create_local_build()
    
    print("\n" + "=" * 50)
    print("BUILD SUMMARY")
    print("=" * 50)
    
    if has_changes:
        print("✅ Changes pushed to GitHub")
        print("🔄 GitHub Actions building Windows EXE...")
        print("📋 Check: https://github.com/DARC0625/Invariant/actions")
        print("📦 Download: https://github.com/DARC0625/Invariant/releases")
    
    if local_build:
        print(f"✅ Local build: {local_build}")
        print("⚠️ Note: Local build is for Linux, not Windows")
    
    print("\n🎯 Next Steps:")
    print("1. Wait for GitHub Actions to complete (5-10 minutes)")
    print("2. Check the Actions tab for build status")
    print("3. Download Windows EXE from Releases")
    print("4. Test on Windows machine")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
