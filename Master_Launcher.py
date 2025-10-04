#!/usr/bin/env python3
"""
Master Project Launcher
프로젝트 0 - 모든 프로젝트들의 통합 관리 시스템
"""

import os
import sys
import json
import zipfile
import urllib.request
import urllib.error
import subprocess
import shutil
import time
import tkinter as tk
from tkinter import ttk, messagebox
import threading
from pathlib import Path
from datetime import datetime

class MasterProjectLauncher:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Invariant - Master Project Hub")
        self.root.geometry("800x600")
        self.root.resizable(True, True)
        
        # 설정
        self.github_owner = "DARC0625"
        self.base_repo_name = "Project"
        self.projects_dir = Path("C:/Projects")
        self.launcher_dir = Path(os.path.dirname(os.path.abspath(__file__)))
        self.config_file = self.launcher_dir / "master_config.json"
        
        # 프로젝트 정보
        self.projects = {}
        self.current_selected_project = None
        
        self.setup_ui()
        self.load_config()
        self.load_projects()
        
    def setup_ui(self):
        """UI 설정"""
        # 메인 프레임
        main_frame = ttk.Frame(self.root, padding="20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 제목
        title_label = ttk.Label(main_frame, text="🚀 Invariant - Master Project Hub", 
                               font=("Arial", 18, "bold"))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))
        
        # 왼쪽 프레임 - 프로젝트 목록
        left_frame = ttk.LabelFrame(main_frame, text="프로젝트 목록", padding="10")
        left_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=(0, 10))
        
        # 프로젝트 트리뷰
        self.project_tree = ttk.Treeview(left_frame, columns=("version", "status"), show="tree headings")
        self.project_tree.heading("#0", text="프로젝트")
        self.project_tree.heading("version", text="버전")
        self.project_tree.heading("status", text="상태")
        self.project_tree.column("#0", width=150)
        self.project_tree.column("version", width=80)
        self.project_tree.column("status", width=100)
        
        # 스크롤바
        tree_scroll = ttk.Scrollbar(left_frame, orient="vertical", command=self.project_tree.yview)
        self.project_tree.configure(yscrollcommand=tree_scroll.set)
        
        self.project_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        tree_scroll.grid(row=0, column=1, sticky=(tk.N, tk.S))
        
        # 프로젝트 선택 이벤트
        self.project_tree.bind("<<TreeviewSelect>>", self.on_project_select)
        
        # 오른쪽 프레임 - 프로젝트 정보 및 제어
        right_frame = ttk.LabelFrame(main_frame, text="프로젝트 정보", padding="10")
        right_frame.grid(row=1, column=1, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 프로젝트 정보 표시
        self.project_info_frame = ttk.Frame(right_frame)
        self.project_info_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        self.project_name_label = ttk.Label(self.project_info_frame, text="프로젝트를 선택하세요", 
                                          font=("Arial", 12, "bold"))
        self.project_name_label.grid(row=0, column=0, sticky=tk.W)
        
        self.project_version_label = ttk.Label(self.project_info_frame, text="")
        self.project_version_label.grid(row=1, column=0, sticky=tk.W)
        
        self.project_description_label = ttk.Label(self.project_info_frame, text="", wraplength=400)
        self.project_description_label.grid(row=2, column=0, sticky=tk.W, pady=(5, 0))
        
        # 버튼 프레임
        button_frame = ttk.Frame(right_frame)
        button_frame.grid(row=1, column=0, columnspan=2, pady=10)
        
        # 프로젝트 제어 버튼들
        self.update_button = ttk.Button(button_frame, text="업데이트 확인", 
                                       command=self.check_updates, state="disabled")
        self.update_button.grid(row=0, column=0, padx=(0, 10))
        
        self.download_button = ttk.Button(button_frame, text="다운로드/설치", 
                                         command=self.download_project, state="disabled")
        self.download_button.grid(row=0, column=1, padx=(0, 10))
        
        self.launch_button = ttk.Button(button_frame, text="실행", 
                                       command=self.launch_project, state="disabled")
        self.launch_button.grid(row=0, column=2, padx=(0, 10))
        
        self.uninstall_button = ttk.Button(button_frame, text="제거", 
                                          command=self.uninstall_project, state="disabled")
        self.uninstall_button.grid(row=0, column=3)
        
        # 진행 상황
        self.progress = ttk.Progressbar(right_frame, mode='indeterminate')
        self.progress.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))
        
        # 상태 라벨
        self.status_label = ttk.Label(right_frame, text="준비됨")
        self.status_label.grid(row=3, column=0, columnspan=2, pady=(10, 0))
        
        # 하단 프레임 - 전체 제어
        bottom_frame = ttk.LabelFrame(main_frame, text="전체 제어", padding="10")
        bottom_frame.grid(row=2, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))
        
        # 전체 제어 버튼들
        ttk.Button(bottom_frame, text="모든 프로젝트 업데이트 확인", 
                  command=self.check_all_updates).grid(row=0, column=0, padx=(0, 10))
        ttk.Button(bottom_frame, text="새 프로젝트 추가", 
                  command=self.add_new_project).grid(row=0, column=1, padx=(0, 10))
        ttk.Button(bottom_frame, text="설정", 
                  command=self.show_settings).grid(row=0, column=2, padx=(0, 10))
        ttk.Button(bottom_frame, text="프로젝트 새로고침", 
                  command=self.refresh_projects).grid(row=0, column=3)
        
        # 그리드 가중치 설정
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(1, weight=1)
        left_frame.columnconfigure(0, weight=1)
        left_frame.rowconfigure(0, weight=1)
        right_frame.columnconfigure(0, weight=1)
        
    def load_config(self):
        """설정 로드"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                    self.github_owner = config.get('github_owner', 'DARC0625')
                    self.base_repo_name = config.get('base_repo_name', 'Project')
            except:
                pass
        
        # 기본 프로젝트 설정
        self.default_projects = {
            "Project1": {
                "name": "Project 1",
                "description": "첫 번째 프로젝트",
                "repo_name": "Project1",
                "main_file": "main.py",
                "install_script": "install.py"
            },
            "Project2": {
                "name": "Project 2", 
                "description": "두 번째 프로젝트",
                "repo_name": "Project2",
                "main_file": "app.py",
                "install_script": "setup.py"
            },
            "Project3": {
                "name": "Project 3",
                "description": "세 번째 프로젝트", 
                "repo_name": "Project3",
                "main_file": "start.py",
                "install_script": "install.py"
            },
            "Project4": {
                "name": "Project 4 - AI Agent",
                "description": "Android 에뮬레이터 AI 에이전트",
                "repo_name": "Project4_AI_Agent",
                "main_file": "windows_ai_agent_gui.py",
                "install_script": "install_complete.bat"
            }
        }
        
    def load_projects(self):
        """프로젝트 목록 로드"""
        # 트리뷰 초기화
        for item in self.project_tree.get_children():
            self.project_tree.delete(item)
        
        for project_id, project_info in self.default_projects.items():
            # 설치 상태 확인
            install_path = self.projects_dir / project_id
            if install_path.exists():
                version_file = install_path / "version.json"
                if version_file.exists():
                    try:
                        with open(version_file, 'r', encoding='utf-8') as f:
                            version_info = json.load(f)
                            version = version_info.get('version', 'Unknown')
                    except:
                        version = "Unknown"
                    status = "설치됨"
                else:
                    version = "Unknown"
                    status = "부분 설치"
            else:
                version = "-"
                status = "미설치"
            
            # 트리뷰에 추가
            self.project_tree.insert("", "end", project_id, 
                                   text=project_info["name"],
                                   values=(version, status))
        
    def on_project_select(self, event):
        """프로젝트 선택 이벤트"""
        selection = self.project_tree.selection()
        if selection:
            project_id = selection[0]
            self.current_selected_project = project_id
            self.update_project_info(project_id)
            self.update_button_states()
            
    def update_project_info(self, project_id):
        """프로젝트 정보 업데이트"""
        if project_id in self.default_projects:
            project_info = self.default_projects[project_id]
            
            self.project_name_label.config(text=project_info["name"])
            
            # 버전 정보
            install_path = self.projects_dir / project_id
            if install_path.exists():
                version_file = install_path / "version.json"
                if version_file.exists():
                    try:
                        with open(version_file, 'r', encoding='utf-8') as f:
                            version_info = json.load(f)
                            version = version_info.get('version', 'Unknown')
                            install_date = version_info.get('install_date', 'Unknown')
                        self.project_version_label.config(text=f"버전: {version} (설치일: {install_date})")
                    except:
                        self.project_version_label.config(text="버전: Unknown")
                else:
                    self.project_version_label.config(text="버전: Unknown")
            else:
                self.project_version_label.config(text="설치되지 않음")
            
            self.project_description_label.config(text=project_info["description"])
            
    def update_button_states(self):
        """버튼 상태 업데이트"""
        if self.current_selected_project:
            self.update_button.config(state="normal")
            self.download_button.config(state="normal")
            self.launch_button.config(state="normal")
            self.uninstall_button.config(state="normal")
        else:
            self.update_button.config(state="disabled")
            self.download_button.config(state="disabled")
            self.launch_button.config(state="disabled")
            self.uninstall_button.config(state="disabled")
            
    def check_updates(self):
        """선택된 프로젝트 업데이트 확인"""
        if not self.current_selected_project:
            return
            
        def check_thread():
            self.progress.start()
            self.status_label.config(text="업데이트 확인 중...")
            self.update_button.config(state="disabled")
            
            try:
                project_info = self.default_projects[self.current_selected_project]
                repo_name = project_info["repo_name"]
                
                # GitHub API로 릴리즈 정보 가져오기
                api_url = f"https://api.github.com/repos/{self.github_owner}/{repo_name}/releases"
                
                with urllib.request.urlopen(api_url, timeout=10) as response:
                    releases = json.loads(response.read().decode())
                
                if releases:
                    latest_release = releases[0]
                    latest_version = latest_release['tag_name'].lstrip('v')
                    
                    # 현재 설치된 버전과 비교
                    install_path = self.projects_dir / self.current_selected_project
                    current_version = "0.0.0"
                    if install_path.exists():
                        version_file = install_path / "version.json"
                        if version_file.exists():
                            try:
                                with open(version_file, 'r', encoding='utf-8') as f:
                                    version_info = json.load(f)
                                    current_version = version_info.get('version', '0.0.0')
                            except:
                                pass
                    
                    if latest_version != current_version:
                        self.root.after(0, lambda: self.status_label.config(
                            text=f"업데이트 가능: {current_version} → {latest_version}"))
                    else:
                        self.root.after(0, lambda: self.status_label.config(text="최신 버전입니다"))
                else:
                    self.root.after(0, lambda: self.status_label.config(text="릴리즈를 찾을 수 없습니다"))
                    
            except Exception as e:
                self.root.after(0, lambda: self.status_label.config(text=f"업데이트 확인 실패: {str(e)}"))
            finally:
                self.root.after(0, self.progress.stop)
                self.root.after(0, lambda: self.update_button.config(state="normal"))
                
        threading.Thread(target=check_thread, daemon=True).start()
        
    def download_project(self):
        """프로젝트 다운로드 및 설치"""
        if not self.current_selected_project:
            return
            
        def download_thread():
            try:
                self.progress.start()
                self.status_label.config(text="다운로드 중...")
                self.download_button.config(state="disabled")
                
                project_info = self.default_projects[self.current_selected_project]
                repo_name = project_info["repo_name"]
                
                # GitHub API로 릴리즈 정보 가져오기
                api_url = f"https://api.github.com/repos/{self.github_owner}/{repo_name}/releases"
                
                with urllib.request.urlopen(api_url, timeout=10) as response:
                    releases = json.loads(response.read().decode())
                
                if not releases:
                    raise Exception("릴리즈를 찾을 수 없습니다")
                
                latest_release = releases[0]
                
                # ZIP 파일 찾기
                zip_asset = None
                for asset in latest_release['assets']:
                    if asset['name'].endswith('.zip'):
                        zip_asset = asset
                        break
                
                if not zip_asset:
                    raise Exception("ZIP 파일을 찾을 수 없습니다")
                
                # 다운로드
                self.root.after(0, lambda: self.status_label.config(text="파일 다운로드 중..."))
                download_url = zip_asset['browser_download_url']
                
                # 임시 디렉토리에 다운로드
                temp_dir = self.launcher_dir / "temp"
                temp_dir.mkdir(exist_ok=True)
                zip_path = temp_dir / f"{self.current_selected_project}.zip"
                
                with urllib.request.urlopen(download_url, timeout=30) as response:
                    with open(zip_path, 'wb') as f:
                        f.write(response.read())
                
                # 설치
                self.root.after(0, lambda: self.status_label.config(text="설치 중..."))
                self.install_project(zip_path, latest_release['tag_name'].lstrip('v'))
                
                # 정리
                shutil.rmtree(temp_dir, ignore_errors=True)
                
                self.root.after(0, lambda: self.status_label.config(text="설치 완료"))
                self.root.after(0, self.load_projects)
                self.root.after(0, self.update_project_info(self.current_selected_project))
                
            except Exception as e:
                self.root.after(0, lambda: self.status_label.config(text=f"설치 실패: {str(e)}"))
            finally:
                self.root.after(0, self.progress.stop)
                self.root.after(0, lambda: self.download_button.config(state="normal"))
                
        threading.Thread(target=download_thread, daemon=True).start()
        
    def install_project(self, zip_path, version):
        """프로젝트 설치"""
        project_path = self.projects_dir / self.current_selected_project
        project_path.mkdir(parents=True, exist_ok=True)
        
        # ZIP 파일 압축 해제
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(project_path)
        
        # 버전 정보 저장
        version_info = {
            'version': version,
            'install_date': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            'project_id': self.current_selected_project
        }
        
        with open(project_path / "version.json", 'w', encoding='utf-8') as f:
            json.dump(version_info, f, indent=2, ensure_ascii=False)
            
    def launch_project(self):
        """프로젝트 실행"""
        if not self.current_selected_project:
            return
            
        try:
            project_info = self.default_projects[self.current_selected_project]
            project_path = self.projects_dir / self.current_selected_project
            main_file = project_info["main_file"]
            
            app_path = project_path / main_file
            if app_path.exists():
                self.status_label.config(text="애플리케이션 실행 중...")
                subprocess.Popen([sys.executable, str(app_path)], 
                               cwd=str(project_path))
            else:
                messagebox.showerror("오류", f"실행 파일을 찾을 수 없습니다: {main_file}")
        except Exception as e:
            messagebox.showerror("오류", f"애플리케이션 실행 실패: {str(e)}")
            
    def uninstall_project(self):
        """프로젝트 제거"""
        if not self.current_selected_project:
            return
            
        if messagebox.askyesno("확인", f"{self.default_projects[self.current_selected_project]['name']}을(를) 제거하시겠습니까?"):
            try:
                project_path = self.projects_dir / self.current_selected_project
                if project_path.exists():
                    shutil.rmtree(project_path)
                    self.status_label.config(text="프로젝트 제거 완료")
                    self.load_projects()
                    self.update_project_info(self.current_selected_project)
                else:
                    self.status_label.config(text="프로젝트가 설치되지 않았습니다")
            except Exception as e:
                messagebox.showerror("오류", f"프로젝트 제거 실패: {str(e)}")
                
    def check_all_updates(self):
        """모든 프로젝트 업데이트 확인"""
        self.status_label.config(text="모든 프로젝트 업데이트 확인 중...")
        # 구현 예정
        
    def add_new_project(self):
        """새 프로젝트 추가"""
        # 구현 예정
        messagebox.showinfo("정보", "새 프로젝트 추가 기능은 개발 중입니다")
        
    def show_settings(self):
        """설정 다이얼로그"""
        settings_window = tk.Toplevel(self.root)
        settings_window.title("설정")
        settings_window.geometry("400x200")
        settings_window.resizable(False, False)
        
        # GitHub 사용자명 입력
        ttk.Label(settings_window, text="GitHub 사용자명:").grid(row=0, column=0, sticky=tk.W, padx=10, pady=10)
        username_var = tk.StringVar(value=self.github_owner)
        username_entry = ttk.Entry(settings_window, textvariable=username_var, width=30)
        username_entry.grid(row=0, column=1, padx=10, pady=10)
        
        # 저장소 기본 이름 입력
        ttk.Label(settings_window, text="기본 저장소 이름:").grid(row=1, column=0, sticky=tk.W, padx=10, pady=10)
        repo_var = tk.StringVar(value=self.base_repo_name)
        repo_entry = ttk.Entry(settings_window, textvariable=repo_var, width=30)
        repo_entry.grid(row=1, column=1, padx=10, pady=10)
        
        def save_settings():
            self.github_owner = username_var.get()
            self.base_repo_name = repo_var.get()
            self.save_config()
            settings_window.destroy()
            messagebox.showinfo("설정 저장", "설정이 저장되었습니다.")
        
        ttk.Button(settings_window, text="저장", command=save_settings).grid(row=2, column=1, pady=20)
        
    def save_config(self):
        """설정 저장"""
        config = {
            'github_owner': self.github_owner,
            'base_repo_name': self.base_repo_name
        }
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
        except:
            pass
            
    def refresh_projects(self):
        """프로젝트 목록 새로고침"""
        self.load_projects()
        self.status_label.config(text="프로젝트 목록 새로고침 완료")
            
    def run(self):
        """런처 실행"""
        self.root.mainloop()

if __name__ == "__main__":
    launcher = MasterProjectLauncher()
    launcher.run()
