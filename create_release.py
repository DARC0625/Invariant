#!/usr/bin/env python3
"""
Invariant 릴리즈 생성 스크립트
"""

import os
import sys
import zipfile
import json
from pathlib import Path

def create_release(version, is_beta=False):
    """릴리즈 생성"""
    
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
