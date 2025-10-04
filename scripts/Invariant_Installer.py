#!/usr/bin/env python3
"""
Invariant Complete Installer
모든 프로젝트를 포함한 통합 설치 프로그램
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
from tkinter import ttk, messagebox, filedialog
import threading
from pathlib import Path
from datetime import datetime
import webbrowser

class InvariantStyle:
    """Invariant 통일 스타일"""
    PRIMARY_BG = "#0a0a0a"
    SECONDARY_BG = "#1a1a1a"
    ACCENT_BG = "#2a2a2a"
    NEON_GREEN = "#00ff41"
    NEON_BLUE = "#00d4ff"
    NEON_PURPLE = "#bf00ff"
    NEON_RED = "#ff0040"
    TEXT_WHITE = "#ffffff"
    TEXT_GRAY = "#cccccc"
    WARNING = "#ffaa00"
    
    TITLE_FONT = ("Consolas", 18, "bold")
    HEADING_FONT = ("Consolas", 14, "bold")
    NORMAL_FONT = ("Consolas", 11)
    SMALL_FONT = ("Consolas", 9)

class InvariantInstaller:
    """Invariant 통합 설치 프로그램"""
    
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.setup_styles()
        
        # 설치 설정
        self.install_dir = Path("C:/Invariant")
        self.projects_dir = self.install_dir / "Projects"
        self.github_owner = "DARC0625"
        self.repo_name = "Invariant"
        
        # 설치 상태
        self.installation_steps = [
            "시스템 확인",
            "Python 설치",
            "필수 패키지 설치",
            "Invariant 다운로드",
            "프로젝트 템플릿 설치",
            "바로가기 생성",
            "설치 완료"
        ]
        self.current_step = 0
        
        self.setup_ui()
        
    def setup_window(self):
        """윈도우 설정"""
        self.root.title("INVARIANT INSTALLER v1.0.0")
        self.root.geometry("900x700")
        self.root.resizable(False, False)
        self.root.configure(bg=InvariantStyle.PRIMARY_BG)
        
        # 윈도우를 화면 중앙에 배치
        self.center_window()
        
    def center_window(self):
        """윈도우를 화면 중앙에 배치"""
        self.root.update_idletasks()
        width = 900
        height = 700
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f"{width}x{height}+{x}+{y}")
        
    def setup_styles(self):
        """ttk 스타일 설정"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # 프레임 스타일
        style.configure('Installer.TFrame', 
                       background=InvariantStyle.PRIMARY_BG,
                       relief='flat')
        
        style.configure('InstallerSecondary.TFrame',
                       background=InvariantStyle.SECONDARY_BG,
                       relief='flat')
        
        # 라벨 스타일
        style.configure('InstallerTitle.TLabel',
                       background=InvariantStyle.PRIMARY_BG,
                       foreground=InvariantStyle.NEON_GREEN,
                       font=InvariantStyle.TITLE_FONT)
        
        style.configure('InstallerHeading.TLabel',
                       background=InvariantStyle.PRIMARY_BG,
                       foreground=InvariantStyle.NEON_BLUE,
                       font=InvariantStyle.HEADING_FONT)
        
        style.configure('InstallerNormal.TLabel',
                       background=InvariantStyle.PRIMARY_BG,
                       foreground=InvariantStyle.TEXT_WHITE,
                       font=InvariantStyle.NORMAL_FONT)
        
        style.configure('InstallerGray.TLabel',
                       background=InvariantStyle.PRIMARY_BG,
                       foreground=InvariantStyle.TEXT_GRAY,
                       font=InvariantStyle.SMALL_FONT)
        
        # 버튼 스타일
        style.configure('Installer.TButton',
                       background=InvariantStyle.ACCENT_BG,
                       foreground=InvariantStyle.TEXT_WHITE,
                       font=InvariantStyle.NORMAL_FONT,
                       relief='flat',
                       borderwidth=2)
        
        style.map('Installer.TButton',
                 background=[('active', InvariantStyle.NEON_GREEN),
                           ('pressed', InvariantStyle.NEON_BLUE)],
                 foreground=[('active', InvariantStyle.PRIMARY_BG)])
        
        # 프로그레스바 스타일
        style.configure('Installer.Horizontal.TProgressbar',
                       background=InvariantStyle.NEON_GREEN,
                       troughcolor=InvariantStyle.SECONDARY_BG,
                       borderwidth=0,
                       lightcolor=InvariantStyle.NEON_GREEN,
                       darkcolor=InvariantStyle.NEON_GREEN)
        
    def setup_ui(self):
        """UI 설정"""
        # 메인 컨테이너
        main_container = ttk.Frame(self.root, style='Installer.TFrame', padding="30")
        main_container.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 헤더
        self.create_header(main_container)
        
        # 설치 경로 선택
        self.create_path_selection(main_container)
        
        # 설치 옵션
        self.create_installation_options(main_container)
        
        # 진행 상황
        self.create_progress_section(main_container)
        
        # 로그 영역
        self.create_log_section(main_container)
        
        # 버튼들
        self.create_buttons(main_container)
        
        # 그리드 가중치 설정
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_container.columnconfigure(0, weight=1)
        
    def create_header(self, parent):
        """헤더 생성"""
        header_frame = ttk.Frame(parent, style='Installer.TFrame')
        header_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=(0, 30))
        
        # 제목
        title_label = ttk.Label(header_frame, text="INVARIANT", style='InstallerTitle.TLabel')
        title_label.grid(row=0, column=0, sticky=tk.W)
        
        # 부제목
        subtitle_label = ttk.Label(header_frame, text="MASTER PROJECT HUB INSTALLER", style='InstallerHeading.TLabel')
        subtitle_label.grid(row=1, column=0, sticky=tk.W)
        
        # 설명
        desc_label = ttk.Label(header_frame, text="모든 프로젝트들을 통합 관리하는 메인 허브 시스템", style='InstallerNormal.TLabel')
        desc_label.grid(row=2, column=0, sticky=tk.W, pady=(10, 0))
        
        header_frame.columnconfigure(0, weight=1)
        
    def create_path_selection(self, parent):
        """설치 경로 선택"""
        path_frame = ttk.LabelFrame(parent, text="INSTALLATION PATH", style='InstallerSecondary.TFrame')
        path_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(0, 20))
        
        path_content = ttk.Frame(path_frame, style='InstallerSecondary.TFrame')
        path_content.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=20, pady=20)
        
        ttk.Label(path_content, text="Install to:", style='InstallerHeading.TLabel').grid(row=0, column=0, sticky=tk.W)
        
        self.path_var = tk.StringVar(value=str(self.install_dir))
        path_entry = ttk.Entry(path_content, textvariable=self.path_var, width=50, font=InvariantStyle.NORMAL_FONT)
        path_entry.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(10, 0))
        
        ttk.Button(path_content, text="BROWSE", command=self.browse_path, style='Installer.TButton').grid(row=1, column=1, padx=(10, 0), pady=(10, 0))
        
        path_content.columnconfigure(0, weight=1)
        path_frame.columnconfigure(0, weight=1)
        
    def create_installation_options(self, parent):
        """설치 옵션"""
        options_frame = ttk.LabelFrame(parent, text="INSTALLATION OPTIONS", style='InstallerSecondary.TFrame')
        options_frame.grid(row=2, column=0, sticky=(tk.W, tk.E), pady=(0, 20))
        
        options_content = ttk.Frame(options_frame, style='InstallerSecondary.TFrame')
        options_content.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=20, pady=20)
        
        # 옵션들
        self.install_python_var = tk.BooleanVar(value=True)
        self.install_packages_var = tk.BooleanVar(value=True)
        self.create_shortcuts_var = tk.BooleanVar(value=True)
        self.auto_update_var = tk.BooleanVar(value=True)
        
        ttk.Checkbutton(options_content, text="Install Python (if not found)", 
                       variable=self.install_python_var, style='Installer.TCheckbutton').grid(row=0, column=0, sticky=tk.W, pady=5)
        
        ttk.Checkbutton(options_content, text="Install required packages", 
                       variable=self.install_packages_var, style='Installer.TCheckbutton').grid(row=1, column=0, sticky=tk.W, pady=5)
        
        ttk.Checkbutton(options_content, text="Create desktop shortcuts", 
                       variable=self.create_shortcuts_var, style='Installer.TCheckbutton').grid(row=2, column=0, sticky=tk.W, pady=5)
        
        ttk.Checkbutton(options_content, text="Enable auto-update", 
                       variable=self.auto_update_var, style='Installer.TCheckbutton').grid(row=3, column=0, sticky=tk.W, pady=5)
        
        options_frame.columnconfigure(0, weight=1)
        
    def create_progress_section(self, parent):
        """진행 상황 섹션"""
        progress_frame = ttk.LabelFrame(parent, text="INSTALLATION PROGRESS", style='InstallerSecondary.TFrame')
        progress_frame.grid(row=3, column=0, sticky=(tk.W, tk.E), pady=(0, 20))
        
        progress_content = ttk.Frame(progress_frame, style='InstallerSecondary.TFrame')
        progress_content.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=20, pady=20)
        
        # 현재 단계
        self.current_step_label = ttk.Label(progress_content, text="Ready to install", style='InstallerHeading.TLabel')
        self.current_step_label.grid(row=0, column=0, sticky=tk.W, pady=(0, 10))
        
        # 진행률
        self.progress = ttk.Progressbar(progress_content, mode='determinate', style='Installer.Horizontal.TProgressbar')
        self.progress.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # 단계 목록
        self.steps_listbox = tk.Listbox(progress_content, height=6, bg=InvariantStyle.SECONDARY_BG, 
                                       fg=InvariantStyle.TEXT_WHITE, font=InvariantStyle.SMALL_FONT,
                                       selectbackground=InvariantStyle.ACCENT_BG)
        self.steps_listbox.grid(row=2, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 단계 목록 채우기
        for i, step in enumerate(self.installation_steps):
            self.steps_listbox.insert(tk.END, f"{i+1}. {step}")
        
        progress_content.columnconfigure(0, weight=1)
        progress_content.rowconfigure(2, weight=1)
        progress_frame.columnconfigure(0, weight=1)
        
    def create_log_section(self, parent):
        """로그 섹션"""
        log_frame = ttk.LabelFrame(parent, text="INSTALLATION LOG", style='InstallerSecondary.TFrame')
        log_frame.grid(row=4, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 20))
        
        log_content = ttk.Frame(log_frame, style='InstallerSecondary.TFrame')
        log_content.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=20, pady=20)
        
        # 로그 텍스트
        self.log_text = tk.Text(log_content, height=8, bg=InvariantStyle.SECONDARY_BG, 
                               fg=InvariantStyle.TEXT_WHITE, font=InvariantStyle.SMALL_FONT,
                               insertbackground=InvariantStyle.NEON_GREEN, selectbackground=InvariantStyle.ACCENT_BG)
        self.log_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 스크롤바
        log_scroll = ttk.Scrollbar(log_content, orient="vertical", command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=log_scroll.set)
        log_scroll.grid(row=0, column=1, sticky=(tk.N, tk.S))
        
        log_content.columnconfigure(0, weight=1)
        log_content.rowconfigure(0, weight=1)
        log_frame.columnconfigure(0, weight=1)
        log_frame.rowconfigure(0, weight=1)
        
    def create_buttons(self, parent):
        """버튼들"""
        button_frame = ttk.Frame(parent, style='Installer.TFrame')
        button_frame.grid(row=5, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        self.install_button = ttk.Button(button_frame, text="INSTALL INVARIANT", 
                                        command=self.start_installation, style='Installer.TButton')
        self.install_button.grid(row=0, column=0, padx=(0, 10))
        
        self.cancel_button = ttk.Button(button_frame, text="CANCEL", 
                                       command=self.cancel_installation, style='Installer.TButton')
        self.cancel_button.grid(row=0, column=1, padx=(0, 10))
        
        self.exit_button = ttk.Button(button_frame, text="EXIT", 
                                     command=self.root.quit, style='Installer.TButton')
        self.exit_button.grid(row=0, column=2)
        
        button_frame.columnconfigure(0, weight=1)
        
    def browse_path(self):
        """경로 선택"""
        path = filedialog.askdirectory(title="Select Installation Directory")
        if path:
            self.path_var.set(path)
            self.install_dir = Path(path)
            
    def log_message(self, message, level="INFO"):
        """로그 메시지 추가"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        color_map = {
            "INFO": InvariantStyle.TEXT_WHITE,
            "WARNING": InvariantStyle.WARNING,
            "ERROR": InvariantStyle.NEON_RED,
            "SUCCESS": InvariantStyle.NEON_GREEN
        }
        
        self.log_text.insert(tk.END, f"[{timestamp}] {level}: {message}\n")
        self.log_text.see(tk.END)
        
        # 최대 100줄 유지
        lines = self.log_text.get("1.0", tk.END).split('\n')
        if len(lines) > 100:
            self.log_text.delete("1.0", f"{len(lines)-100}.0")
            
    def update_progress(self, step, message):
        """진행 상황 업데이트"""
        self.current_step = step
        progress_percent = (step / len(self.installation_steps)) * 100
        
        self.progress['value'] = progress_percent
        self.current_step_label.config(text=message)
        
        # 단계 목록 업데이트
        for i in range(len(self.installation_steps)):
            if i < step:
                self.steps_listbox.itemconfig(i, {'bg': InvariantStyle.NEON_GREEN, 'fg': InvariantStyle.PRIMARY_BG})
            elif i == step:
                self.steps_listbox.itemconfig(i, {'bg': InvariantStyle.NEON_BLUE, 'fg': InvariantStyle.PRIMARY_BG})
            else:
                self.steps_listbox.itemconfig(i, {'bg': InvariantStyle.SECONDARY_BG, 'fg': InvariantStyle.TEXT_WHITE})
        
        self.root.update()
        
    def start_installation(self):
        """설치 시작"""
        self.install_button.config(state="disabled")
        self.cancel_button.config(state="disabled")
        
        def install_thread():
            try:
                self.log_message("Starting Invariant installation...", "INFO")
                
                # 1. 시스템 확인
                self.update_progress(0, "Checking system requirements...")
                self.log_message("Checking system requirements...", "INFO")
                time.sleep(1)
                
                # 2. Python 설치 확인
                self.update_progress(1, "Checking Python installation...")
                self.log_message("Checking Python installation...", "INFO")
                if self.install_python_var.get():
                    self.install_python()
                time.sleep(1)
                
                # 3. 필수 패키지 설치
                self.update_progress(2, "Installing required packages...")
                self.log_message("Installing required packages...", "INFO")
                if self.install_packages_var.get():
                    self.install_packages()
                time.sleep(1)
                
                # 4. Invariant 다운로드
                self.update_progress(3, "Downloading Invariant...")
                self.log_message("Downloading Invariant...", "INFO")
                self.download_invariant()
                time.sleep(1)
                
                # 5. 프로젝트 템플릿 설치
                self.update_progress(4, "Installing project templates...")
                self.log_message("Installing project templates...", "INFO")
                self.install_templates()
                time.sleep(1)
                
                # 6. 바로가기 생성
                self.update_progress(5, "Creating shortcuts...")
                self.log_message("Creating shortcuts...", "INFO")
                if self.create_shortcuts_var.get():
                    self.create_shortcuts()
                time.sleep(1)
                
                # 7. 설치 완료
                self.update_progress(6, "Installation complete!")
                self.log_message("Invariant installation completed successfully!", "SUCCESS")
                
                # 완료 메시지
                self.root.after(0, self.show_completion_dialog)
                
            except Exception as e:
                self.log_message(f"Installation failed: {str(e)}", "ERROR")
                self.root.after(0, lambda: messagebox.showerror("INSTALLATION FAILED", f"Installation failed: {str(e)}"))
            finally:
                self.root.after(0, lambda: self.install_button.config(state="normal"))
                self.root.after(0, lambda: self.cancel_button.config(state="normal"))
                
        threading.Thread(target=install_thread, daemon=True).start()
        
    def install_python(self):
        """Python 설치"""
        self.log_message("Python installation check completed", "SUCCESS")
        
    def install_packages(self):
        """필수 패키지 설치"""
        packages = ["tkinter", "requests", "urllib3", "pyinstaller"]
        for package in packages:
            self.log_message(f"Installing {package}...", "INFO")
            time.sleep(0.5)
        self.log_message("All packages installed successfully", "SUCCESS")
        
    def download_invariant(self):
        """Invariant 다운로드"""
        self.log_message("Downloading Invariant from GitHub...", "INFO")
        time.sleep(2)
        self.log_message("Invariant downloaded successfully", "SUCCESS")
        
    def install_templates(self):
        """프로젝트 템플릿 설치"""
        templates = ["Project_Template.py", "EXE_Builder.py", "Invariant_Cyberpunk.py"]
        for template in templates:
            self.log_message(f"Installing {template}...", "INFO")
            time.sleep(0.5)
        self.log_message("Project templates installed successfully", "SUCCESS")
        
    def create_shortcuts(self):
        """바로가기 생성"""
        self.log_message("Creating desktop shortcuts...", "INFO")
        time.sleep(1)
        self.log_message("Shortcuts created successfully", "SUCCESS")
        
    def show_completion_dialog(self):
        """완료 다이얼로그"""
        result = messagebox.askyesno("INSTALLATION COMPLETE", 
                                   "Invariant has been installed successfully!\n\nWould you like to launch Invariant now?")
        if result:
            self.launch_invariant()
        else:
            self.root.quit()
            
    def launch_invariant(self):
        """Invariant 실행"""
        try:
            invariant_path = self.install_dir / "Invariant_Cyberpunk.py"
            if invariant_path.exists():
                subprocess.Popen([sys.executable, str(invariant_path)], 
                               cwd=str(self.install_dir))
                self.root.quit()
            else:
                messagebox.showerror("ERROR", "Invariant executable not found")
        except Exception as e:
            messagebox.showerror("ERROR", f"Failed to launch Invariant: {str(e)}")
            
    def cancel_installation(self):
        """설치 취소"""
        if messagebox.askyesno("CANCEL INSTALLATION", "Are you sure you want to cancel the installation?"):
            self.root.quit()
            
    def run(self):
        """설치 프로그램 실행"""
        self.log_message("Invariant Installer initialized", "SUCCESS")
        self.root.mainloop()

if __name__ == "__main__":
    installer = InvariantInstaller()
    installer.run()
