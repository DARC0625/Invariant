#!/usr/bin/env python3
"""
EXE Builder - Invariant 프로젝트 EXE 빌더
모든 프로젝트를 EXE 파일로 변환하는 시스템
"""

import os
import sys
import json
import shutil
import subprocess
from pathlib import Path
import zipfile

class InvariantEXEBuilder:
    """Invariant EXE 빌더"""
    
    def __init__(self):
        self.build_dir = Path("build")
        self.dist_dir = Path("dist")
        self.spec_dir = Path("specs")
        
        # PyInstaller 설정
        self.pyinstaller_opts = [
            "--onefile",           # 단일 파일로 빌드
            "--windowed",          # 콘솔 창 숨기기
            "--clean",             # 빌드 전 정리
            "--noconfirm",         # 확인 없이 진행
            "--distpath", str(self.dist_dir),
            "--workpath", str(self.build_dir),
            "--specpath", str(self.spec_dir)
        ]
        
    def check_dependencies(self):
        """의존성 확인"""
        print("🔍 Checking dependencies...")
        
        # PyInstaller 확인
        try:
            import PyInstaller
            print("✅ PyInstaller found")
        except ImportError:
            print("❌ PyInstaller not found. Installing...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
            print("✅ PyInstaller installed")
        
        # 기타 필요한 패키지들
        required_packages = ["tkinter", "requests", "urllib3"]
        for package in required_packages:
            try:
                __import__(package)
                print(f"✅ {package} found")
            except ImportError:
                print(f"⚠️ {package} not found (optional)")
        
        return True
        
    def create_project_exe(self, project_name, main_file, icon_file=None, additional_files=None):
        """프로젝트 EXE 생성"""
        print(f"🔨 Building EXE for {project_name}...")
        
        # 디렉토리 생성
        self.build_dir.mkdir(exist_ok=True)
        self.dist_dir.mkdir(exist_ok=True)
        self.spec_dir.mkdir(exist_ok=True)
        
        # PyInstaller 명령어 구성
        cmd = [sys.executable, "-m", "PyInstaller"] + self.pyinstaller_opts
        
        # 아이콘 추가
        if icon_file and os.path.exists(icon_file):
            cmd.extend(["--icon", icon_file])
        
        # 추가 파일들
        if additional_files:
            for file in additional_files:
                if os.path.exists(file):
                    cmd.extend(["--add-data", f"{file};."])
        
        # 메인 파일 추가
        cmd.append(main_file)
        
        print(f"Running: {' '.join(cmd)}")
        
        try:
            # PyInstaller 실행
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ {project_name} EXE built successfully")
                
                # 생성된 EXE 파일 찾기
                exe_files = list(self.dist_dir.glob("*.exe"))
                if exe_files:
                    exe_file = exe_files[0]
                    new_name = f"{project_name}.exe"
                    new_path = self.dist_dir / new_name
                    shutil.move(str(exe_file), str(new_path))
                    print(f"📦 EXE file: {new_path}")
                    return new_path
                else:
                    print("❌ EXE file not found")
                    return None
            else:
                print(f"❌ Build failed: {result.stderr}")
                return None
                
        except Exception as e:
            print(f"❌ Build error: {e}")
            return None
            
    def create_invariant_exe(self):
        """Invariant 메인 EXE 생성"""
        print("🚀 Building Invariant EXE...")
        
        # Invariant 메인 파일
        main_file = "Invariant_Cyberpunk.py"
        
        # 추가 파일들
        additional_files = [
            "Project_Template.py",
            "version.json"
        ]
        
        return self.create_project_exe("Invariant", main_file, additional_files=additional_files)
        
    def create_project1_exe(self):
        """Project 1 EXE 생성"""
        print("🔨 Building Project 1 EXE...")
        
        # Project 1 메인 파일 (템플릿 기반)
        project1_code = '''#!/usr/bin/env python3
"""
Project 1 - Invariant Project
"""

from Project_Template import Project1Template

if __name__ == "__main__":
    app = Project1Template()
    app.run()
'''
        
        # 임시 파일 생성
        with open("temp_project1.py", "w", encoding="utf-8") as f:
            f.write(project1_code)
        
        try:
            result = self.create_project_exe("Project1", "temp_project1.py", 
                                           additional_files=["Project_Template.py"])
            return result
        finally:
            # 임시 파일 정리
            if os.path.exists("temp_project1.py"):
                os.remove("temp_project1.py")
                
    def create_project2_exe(self):
        """Project 2 EXE 생성"""
        print("🔨 Building Project 2 EXE...")
        
        # Project 2 메인 파일 (템플릿 기반)
        project2_code = '''#!/usr/bin/env python3
"""
Project 2 - Invariant Project
"""

from Project_Template import Project2Template

if __name__ == "__main__":
    app = Project2Template()
    app.run()
'''
        
        # 임시 파일 생성
        with open("temp_project2.py", "w", encoding="utf-8") as f:
            f.write(project2_code)
        
        try:
            result = self.create_project_exe("Project2", "temp_project2.py", 
                                           additional_files=["Project_Template.py"])
            return result
        finally:
            # 임시 파일 정리
            if os.path.exists("temp_project2.py"):
                os.remove("temp_project2.py")
                
    def create_project3_exe(self):
        """Project 3 EXE 생성"""
        print("🔨 Building Project 3 EXE...")
        
        # Project 3 메인 파일 (템플릿 기반)
        project3_code = '''#!/usr/bin/env python3
"""
Project 3 - Invariant Project
"""

from Project_Template import Project3Template

if __name__ == "__main__":
    app = Project3Template()
    app.run()
'''
        
        # 임시 파일 생성
        with open("temp_project3.py", "w", encoding="utf-8") as f:
            f.write(project3_code)
        
        try:
            result = self.create_project_exe("Project3", "temp_project3.py", 
                                           additional_files=["Project_Template.py"])
            return result
        finally:
            # 임시 파일 정리
            if os.path.exists("temp_project3.py"):
                os.remove("temp_project3.py")
                
    def create_project4_exe(self):
        """Project 4 EXE 생성 (AI Agent)"""
        print("🔨 Building Project 4 EXE...")
        
        # Project 4는 기존 파일 사용
        main_file = "windows_ai_agent_gui.py"
        
        # 추가 파일들
        additional_files = [
            "config.json",
            "yolov8n.pt"
        ]
        
        return self.create_project_exe("Project4_AI_Agent", main_file, additional_files=additional_files)
        
    def build_all_projects(self):
        """모든 프로젝트 EXE 빌드"""
        print("🚀 Building all Invariant projects...")
        
        results = {}
        
        # 의존성 확인
        if not self.check_dependencies():
            return None
        
        # 각 프로젝트 빌드
        projects = [
            ("Invariant", self.create_invariant_exe),
            ("Project1", self.create_project1_exe),
            ("Project2", self.create_project2_exe),
            ("Project3", self.create_project3_exe),
            ("Project4", self.create_project4_exe)
        ]
        
        for project_name, build_func in projects:
            print(f"\n{'='*50}")
            print(f"Building {project_name}...")
            print(f"{'='*50}")
            
            try:
                result = build_func()
                results[project_name] = result
                
                if result:
                    print(f"✅ {project_name} built successfully: {result}")
                else:
                    print(f"❌ {project_name} build failed")
                    
            except Exception as e:
                print(f"❌ {project_name} build error: {e}")
                results[project_name] = None
        
        # 결과 요약
        print(f"\n{'='*50}")
        print("BUILD SUMMARY")
        print(f"{'='*50}")
        
        success_count = 0
        for project_name, result in results.items():
            status = "✅ SUCCESS" if result else "❌ FAILED"
            print(f"{project_name}: {status}")
            if result:
                success_count += 1
        
        print(f"\nTotal: {success_count}/{len(projects)} projects built successfully")
        
        return results
        
    def create_installer_package(self):
        """설치 패키지 생성"""
        print("📦 Creating installer package...")
        
        # EXE 파일들 수집
        exe_files = list(self.dist_dir.glob("*.exe"))
        
        if not exe_files:
            print("❌ No EXE files found")
            return None
        
        # 설치 패키지 생성
        package_name = "Invariant_Complete_Package.zip"
        
        with zipfile.ZipFile(package_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # EXE 파일들 추가
            for exe_file in exe_files:
                zipf.write(exe_file, exe_file.name)
                print(f"Added: {exe_file.name}")
            
            # 추가 파일들
            additional_files = [
                "README.md",
                "version.json",
                "requirements.txt"
            ]
            
            for file in additional_files:
                if os.path.exists(file):
                    zipf.write(file, file)
                    print(f"Added: {file}")
        
        print(f"✅ Installer package created: {package_name}")
        return package_name
        
    def cleanup(self):
        """빌드 파일 정리"""
        print("🧹 Cleaning up build files...")
        
        # 빌드 디렉토리 정리
        if self.build_dir.exists():
            shutil.rmtree(self.build_dir)
            print("✅ Build directory cleaned")
        
        # 스펙 파일 정리
        if self.spec_dir.exists():
            shutil.rmtree(self.spec_dir)
            print("✅ Spec directory cleaned")

def main():
    """메인 함수"""
    print("🚀 Invariant EXE Builder")
    print("=" * 50)
    
    builder = InvariantEXEBuilder()
    
    try:
        # 모든 프로젝트 빌드
        results = builder.build_all_projects()
        
        if results:
            # 설치 패키지 생성
            package = builder.create_installer_package()
            
            if package:
                print(f"\n🎉 All done! Installer package: {package}")
            else:
                print("\n⚠️ Installer package creation failed")
        else:
            print("\n❌ Build failed")
            
    except KeyboardInterrupt:
        print("\n⚠️ Build interrupted by user")
    except Exception as e:
        print(f"\n❌ Build error: {e}")
    finally:
        # 정리
        builder.cleanup()

if __name__ == "__main__":
    main()
