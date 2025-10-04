#!/usr/bin/env python3
"""
Invariant Build Script
"""

import os
import sys
import subprocess
from pathlib import Path

def build_exe():
    """EXE 빌드"""
    print("🔨 Building Invariant EXE...")
    
    # PyInstaller 명령어
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--onefile",
        "--windowed", 
        "--name", "Invariant",
        "--distpath", "dist",
        "--workpath", "build",
        "--hidden-import", "tkinter",
        "--hidden-import", "tkinter.ttk",
        "--hidden-import", "tkinter.messagebox",
        "--hidden-import", "tkinter.filedialog",
        "invariant.py"
    ]
    
    try:
        result = subprocess.run(cmd, check=True)
        print("✅ EXE built successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Build failed: {e}")
        return False

def create_portable_package():
    """포터블 패키지 생성"""
    print("📦 Creating portable package...")
    
    # 포터블 디렉토리 생성
    portable_dir = Path("Invariant_Portable")
    portable_dir.mkdir(exist_ok=True)
    
    # EXE 파일 복사
    exe_path = Path("dist/Invariant.exe")
    if exe_path.exists():
        shutil.copy2(exe_path, portable_dir / "Invariant.exe")
        print("✅ EXE copied to portable package")
    
    # 추가 파일들 복사
    additional_files = ["requirements.txt", "version.json", "README.md"]
    for file in additional_files:
        if os.path.exists(file):
            shutil.copy2(file, portable_dir / file)
    
    # 실행 스크립트 생성
    run_script = """@echo off
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
"""
    
    with open(portable_dir / "run.bat", "w", encoding="utf-8") as f:
        f.write(run_script)
    
    print("✅ Portable package created")

if __name__ == "__main__":
    if build_exe():
        create_portable_package()
        print("🎉 Build completed successfully!")
    else:
        print("❌ Build failed")
        sys.exit(1)
