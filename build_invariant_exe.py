#!/usr/bin/env python3
"""
Invariant EXE Builder
Invariant를 단일 EXE 파일로 빌드하는 스크립트
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def check_pyinstaller():
    """PyInstaller 설치 확인"""
    try:
        import PyInstaller
        print("✅ PyInstaller found")
        return True
    except ImportError:
        print("❌ PyInstaller not found")
        return False

def build_invariant_exe():
    """Invariant EXE 빌드"""
    print("🔨 Building Invariant EXE...")
    
    # PyInstaller 명령어
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--onefile",                    # 단일 파일로 빌드
        "--windowed",                   # 콘솔 창 숨기기
        "--clean",                      # 빌드 전 정리
        "--noconfirm",                  # 확인 없이 진행
        "--name", "Invariant.exe",      # EXE 파일명
        "--distpath", "dist",           # 출력 디렉토리
        "--workpath", "build",          # 작업 디렉토리
        "--specpath", "specs",          # 스펙 파일 디렉토리
        "Invariant_Cyberpunk.py"        # 메인 파일
    ]
    
    print(f"Running: {' '.join(cmd)}")
    
    try:
        # PyInstaller 실행
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Invariant EXE built successfully")
            
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

def create_installer_package():
    """설치 패키지 생성"""
    print("📦 Creating installer package...")
    
    exe_path = Path("dist/Invariant.exe")
    if not exe_path.exists():
        print("❌ EXE file not found")
        return None
    
    # 설치 패키지 생성
    package_name = "Invariant_Installer.exe"
    
    try:
        # EXE 파일 복사
        shutil.copy2(exe_path, package_name)
        print(f"✅ Installer package created: {package_name}")
        return package_name
    except Exception as e:
        print(f"❌ Package creation failed: {e}")
        return None

def cleanup():
    """빌드 파일 정리"""
    print("🧹 Cleaning up build files...")
    
    # 빌드 디렉토리 정리
    dirs_to_clean = ["build", "specs", "__pycache__"]
    for dir_name in dirs_to_clean:
        if os.path.exists(dir_name):
            shutil.rmtree(dir_name)
            print(f"✅ Cleaned: {dir_name}")
    
    # 임시 파일 정리
    files_to_clean = ["*.pyc", "*.pyo"]
    for pattern in files_to_clean:
        for file in Path(".").glob(pattern):
            file.unlink()
            print(f"✅ Cleaned: {file}")

def main():
    """메인 함수"""
    print("🚀 Invariant EXE Builder")
    print("=" * 50)
    
    # PyInstaller 확인
    if not check_pyinstaller():
        print("❌ Please install PyInstaller first:")
        print("   pip3 install pyinstaller")
        return 1
    
    try:
        # EXE 빌드
        exe_path = build_invariant_exe()
        
        if exe_path:
            # 설치 패키지 생성
            package = create_installer_package()
            
            if package:
                print(f"\n🎉 SUCCESS!")
                print(f"📦 Invariant EXE: {exe_path}")
                print(f"📦 Installer: {package}")
                print(f"📊 Size: {exe_path.stat().st_size / (1024*1024):.1f} MB")
                
                print(f"\n🎯 Usage:")
                print(f"1. Copy {package} to target machine")
                print(f"2. Double-click to run Invariant")
                print(f"3. No Python installation required!")
            else:
                print("❌ Installer package creation failed")
                return 1
        else:
            print("❌ EXE build failed")
            return 1
            
    except KeyboardInterrupt:
        print("\n⚠️ Build interrupted by user")
        return 1
    except Exception as e:
        print(f"\n❌ Build error: {e}")
        return 1
    finally:
        # 정리
        cleanup()
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
