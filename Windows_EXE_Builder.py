#!/usr/bin/env python3
"""
Windows EXE Builder for Invariant
Windows에서 실행할 수 있는 EXE 파일 생성
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def create_windows_spec():
    """Windows용 PyInstaller spec 파일 생성"""
    spec_content = '''# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['Invariant_Cyberpunk.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('version.json', '.'),
        ('requirements.txt', '.'),
    ],
    hiddenimports=[
        'tkinter',
        'tkinter.ttk',
        'tkinter.messagebox',
        'tkinter.filedialog',
        'requests',
        'urllib3',
        'PIL',
        'numpy',
        'cv2',
        'ultralytics',
        'psutil',
        'mss',
        'pyautogui',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='Invariant',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
'''
    
    with open("Invariant.spec", "w", encoding="utf-8") as f:
        f.write(spec_content)
    
    print("✅ Windows spec file created")

def build_windows_exe():
    """Windows EXE 빌드"""
    print("🔨 Building Windows EXE...")
    
    # spec 파일 생성
    create_windows_spec()
    
    # PyInstaller 명령어
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--clean",
        "--noconfirm",
        "Invariant.spec"
    ]
    
    print(f"Running: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Windows EXE built successfully")
            
            # 생성된 EXE 파일 확인
            exe_path = Path("dist/Invariant.exe")
            if exe_path.exists():
                print(f"📦 EXE file: {exe_path.absolute()}")
                print(f"📊 File size: {exe_path.stat().st_size / (1024*1024):.1f} MB")
                return exe_path
            else:
                print("❌ EXE file not found")
                return None
        else:
            print(f"❌ Build failed: {result.stderr}")
            return None
            
    except Exception as e:
        print(f"❌ Build error: {e}")
        return None

def create_installer_script():
    """Windows 설치 스크립트 생성"""
    installer_script = '''@echo off
title Invariant Installer
echo.
echo ========================================
echo    Invariant - Master Project Hub
echo ========================================
echo.
echo Installing Invariant...
echo.

REM 설치 디렉토리 생성
if not exist "C:\\Invariant" mkdir "C:\\Invariant"

REM EXE 파일 복사
copy "Invariant.exe" "C:\\Invariant\\Invariant.exe"

REM 바로가기 생성
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\\Desktop\\Invariant.lnk'); $Shortcut.TargetPath = 'C:\\Invariant\\Invariant.exe'; $Shortcut.WorkingDirectory = 'C:\\Invariant'; $Shortcut.Save()"

echo.
echo ✅ Installation complete!
echo.
echo Invariant has been installed to C:\\Invariant
echo Desktop shortcut created
echo.
echo Press any key to launch Invariant...
pause >nul

REM Invariant 실행
start "" "C:\\Invariant\\Invariant.exe"

exit
'''
    
    with open("install.bat", "w", encoding="utf-8") as f:
        f.write(installer_script)
    
    print("✅ Windows installer script created")

def create_portable_package():
    """포터블 패키지 생성"""
    print("📦 Creating portable package...")
    
    exe_path = Path("dist/Invariant.exe")
    if not exe_path.exists():
        print("❌ EXE file not found")
        return None
    
    # 포터블 디렉토리 생성
    portable_dir = Path("Invariant_Portable")
    portable_dir.mkdir(exist_ok=True)
    
    # EXE 파일 복사
    shutil.copy2(exe_path, portable_dir / "Invariant.exe")
    
    # 추가 파일들 복사
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
    
    print(f"✅ Portable package created: {portable_dir}")
    return portable_dir

def main():
    """메인 함수"""
    print("🚀 Windows EXE Builder for Invariant")
    print("=" * 50)
    
    try:
        # Windows EXE 빌드
        exe_path = build_windows_exe()
        
        if exe_path:
            # 설치 스크립트 생성
            create_installer_script()
            
            # 포터블 패키지 생성
            portable_dir = create_portable_package()
            
            print(f"\n🎉 SUCCESS!")
            print(f"📦 Windows EXE: {exe_path}")
            print(f"📦 Installer: install.bat")
            print(f"📦 Portable: {portable_dir}")
            print(f"📊 Size: {exe_path.stat().st_size / (1024*1024):.1f} MB")
            
            print(f"\n🎯 Usage:")
            print(f"1. Copy files to Windows machine")
            print(f"2. Run install.bat for installation")
            print(f"3. Or run Invariant.exe directly (portable)")
            print(f"4. No Python installation required!")
        else:
            print("❌ Windows EXE build failed")
            return 1
            
    except Exception as e:
        print(f"❌ Build error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
