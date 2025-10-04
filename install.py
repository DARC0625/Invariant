#!/usr/bin/env python3
"""
Invariant 설치 스크립트
"""

import os
import sys
import subprocess
import urllib.request
from pathlib import Path

def install_requirements():
    """필요한 패키지 설치"""
    print("📦 필요한 패키지 설치 중...")
    
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ 패키지 설치 완료")
        return True
    except Exception as e:
        print(f"❌ 패키지 설치 실패: {e}")
        return False

def create_desktop_shortcut():
    """바탕화면 바로가기 생성"""
    try:
        desktop = Path.home() / "Desktop"
        if not desktop.exists():
            desktop = Path.home() / "바탕화면"
        
        shortcut_path = desktop / "Invariant.bat"
        
        with open(shortcut_path, 'w', encoding='utf-8') as f:
            f.write(f"""@echo off
title Invariant
cd /d "{Path.cwd()}"
python Master_Launcher.py
pause""")
        
        print(f"✅ 바탕화면 바로가기 생성: {shortcut_path}")
        return True
        
    except Exception as e:
        print(f"❌ 바로가기 생성 실패: {e}")
        return False

def main():
    """메인 설치 함수"""
    print("🚀 Invariant 설치 시작")
    print("=" * 50)
    
    # 패키지 설치
    if not install_requirements():
        return False
    
    # 바로가기 생성
    create_desktop_shortcut()
    
    print("\n✅ Invariant 설치 완료!")
    print("\n📝 사용 방법:")
    print("1. 바탕화면의 'Invariant' 바로가기를 더블클릭")
    print("2. 또는 'python Master_Launcher.py' 명령어 실행")
    
    return True

if __name__ == "__main__":
    main()
