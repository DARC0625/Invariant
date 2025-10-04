#!/usr/bin/env python3
"""
Invariant - Cyberpunk UI Master Project Hub
모든 프로젝트들의 통합 관리 시스템
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
import webbrowser

class CyberpunkStyle:
    """사이버틱 스타일 정의"""
    # 색상 팔레트
    PRIMARY_BG = "#0a0a0a"      # 검은 배경
    SECONDARY_BG = "#1a1a1a"    # 어두운 회색
    ACCENT_BG = "#2a2a2a"       # 중간 회색
    NEON_GREEN = "#00ff41"      # 네온 그린
    NEON_BLUE = "#00d4ff"       # 네온 블루
    NEON_PURPLE = "#bf00ff"     # 네온 퍼플
    NEON_RED = "#ff0040"        # 네온 레드
    TEXT_WHITE = "#ffffff"      # 흰색 텍스트
    TEXT_GRAY = "#cccccc"       # 회색 텍스트
    WARNING = "#ffaa00"         # 경고색
    
    # 폰트
    TITLE_FONT = ("Consolas", 16, "bold")
    HEADING_FONT = ("Consolas", 12, "bold")
    NORMAL_FONT = ("Consolas", 10)
    SMALL_FONT = ("Consolas", 8)

class InvariantCyberpunk:
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.setup_styles()
        
        # 설정
        self.github_owner = "DARC0625"
        self.base_repo_name = "Project"
        self.projects_dir = Path("C:/Projects")
        self.launcher_dir = Path(os.path.dirname(os.path.abspath(__file__)))
        self.config_file = self.launcher_dir / "invariant_config.json"
        
        # 프로젝트 정보
        self.projects = {}
        self.current_selected_project = None
        
        self.setup_ui()
        self.load_config()
        self.load_projects()
        
    def setup_window(self):
        """윈도우 설정"""
        self.root.title("INVARIANT v1.0.0 - MASTER PROJECT HUB")
        self.root.geometry("1200x800")
        self.root.resizable(True, True)
        self.root.configure(bg=CyberpunkStyle.PRIMARY_BG)
        
        # 아이콘 설정 (있는 경우)
        try:
            self.root.iconbitmap("icon.ico")
        except:
            pass
            
        # 윈도우를 화면 중앙에 배치
        self.center_window()
        
    def center_window(self):
        """윈도우를 화면 중앙에 배치"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f"{width}x{height}+{x}+{y}")
        
    def setup_styles(self):
        """ttk 스타일 설정"""
        style = ttk.Style()
        
        # 사이버틱 테마 설정
        style.theme_use('clam')
        
        # 프레임 스타일
        style.configure('Cyber.TFrame', 
                       background=CyberpunkStyle.PRIMARY_BG,
                       relief='flat')
        
        style.configure('CyberSecondary.TFrame',
                       background=CyberpunkStyle.SECONDARY_BG,
                       relief='flat')
        
        # 라벨 스타일
        style.configure('CyberTitle.TLabel',
                       background=CyberpunkStyle.PRIMARY_BG,
                       foreground=CyberpunkStyle.NEON_GREEN,
                       font=CyberpunkStyle.TITLE_FONT)
        
        style.configure('CyberHeading.TLabel',
                       background=CyberpunkStyle.PRIMARY_BG,
                       foreground=CyberpunkStyle.NEON_BLUE,
                       font=CyberpunkStyle.HEADING_FONT)
        
        style.configure('CyberNormal.TLabel',
                       background=CyberpunkStyle.PRIMARY_BG,
                       foreground=CyberpunkStyle.TEXT_WHITE,
                       font=CyberpunkStyle.NORMAL_FONT)
        
        style.configure('CyberGray.TLabel',
                       background=CyberpunkStyle.PRIMARY_BG,
                       foreground=CyberpunkStyle.TEXT_GRAY,
                       font=CyberpunkStyle.SMALL_FONT)
        
        # 버튼 스타일
        style.configure('Cyber.TButton',
                       background=CyberpunkStyle.ACCENT_BG,
                       foreground=CyberpunkStyle.TEXT_WHITE,
                       font=CyberpunkStyle.NORMAL_FONT,
                       relief='flat',
                       borderwidth=2)
        
        style.map('Cyber.TButton',
                 background=[('active', CyberpunkStyle.NEON_GREEN),
                           ('pressed', CyberpunkStyle.NEON_BLUE)],
                 foreground=[('active', CyberpunkStyle.PRIMARY_BG)])
        
        # 라디오 버튼 스타일
        style.configure('Cyber.TRadiobutton',
                       background=CyberpunkStyle.PRIMARY_BG,
                       foreground=CyberpunkStyle.TEXT_WHITE,
                       font=CyberpunkStyle.NORMAL_FONT,
                       focuscolor=CyberpunkStyle.NEON_GREEN)
        
        # 프로그레스바 스타일
        style.configure('Cyber.Horizontal.TProgressbar',
                       background=CyberpunkStyle.NEON_GREEN,
                       troughcolor=CyberpunkStyle.SECONDARY_BG,
                       borderwidth=0,
                       lightcolor=CyberpunkStyle.NEON_GREEN,
                       darkcolor=CyberpunkStyle.NEON_GREEN)
        
        # 트리뷰 스타일
        style.configure('Cyber.Treeview',
                       background=CyberpunkStyle.SECONDARY_BG,
                       foreground=CyberpunkStyle.TEXT_WHITE,
                       font=CyberpunkStyle.NORMAL_FONT,
                       fieldbackground=CyberpunkStyle.SECONDARY_BG)
        
        style.configure('Cyber.Treeview.Heading',
                       background=CyberpunkStyle.ACCENT_BG,
                       foreground=CyberpunkStyle.NEON_BLUE,
                       font=CyberpunkStyle.HEADING_FONT)
        
    def setup_ui(self):
        """UI 설정"""
        # 메인 컨테이너
        main_container = ttk.Frame(self.root, style='Cyber.TFrame', padding="20")
        main_container.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 헤더
        self.create_header(main_container)
        
        # 메인 콘텐츠 영역
        content_frame = ttk.Frame(main_container, style='Cyber.TFrame')
        content_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(20, 0))
        
        # 사이드바와 메인 영역
        self.create_sidebar(content_frame)
        self.create_main_area(content_frame)
        
        # 하단 상태바
        self.create_status_bar(main_container)
        
        # 그리드 가중치 설정
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_container.columnconfigure(0, weight=1)
        main_container.rowconfigure(1, weight=1)
        content_frame.columnconfigure(1, weight=1)
        content_frame.rowconfigure(0, weight=1)
        
    def create_header(self, parent):
        """헤더 생성"""
        header_frame = ttk.Frame(parent, style='Cyber.TFrame')
        header_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # 제목
        title_label = ttk.Label(header_frame, text="INVARIANT", style='CyberTitle.TLabel')
        title_label.grid(row=0, column=0, sticky=tk.W)
        
        # 부제목
        subtitle_label = ttk.Label(header_frame, text="MASTER PROJECT HUB", style='CyberHeading.TLabel')
        subtitle_label.grid(row=1, column=0, sticky=tk.W)
        
        # 상태 표시
        status_frame = ttk.Frame(header_frame, style='Cyber.TFrame')
        status_frame.grid(row=0, column=1, rowspan=2, sticky=(tk.E, tk.N))
        
        self.connection_status = ttk.Label(status_frame, text="● ONLINE", style='CyberNormal.TLabel')
        self.connection_status.grid(row=0, column=0, sticky=tk.E)
        
        self.system_time = ttk.Label(status_frame, text="", style='CyberGray.TLabel')
        self.system_time.grid(row=1, column=0, sticky=tk.E)
        
        # 시간 업데이트
        self.update_time()
        
        header_frame.columnconfigure(0, weight=1)
        
    def create_sidebar(self, parent):
        """사이드바 생성"""
        sidebar_frame = ttk.LabelFrame(parent, text="PROJECT MATRIX", style='CyberSecondary.TFrame')
        sidebar_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=(0, 10))
        
        # 프로젝트 트리뷰
        tree_frame = ttk.Frame(sidebar_frame, style='CyberSecondary.TFrame')
        tree_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=10, pady=10)
        
        self.project_tree = ttk.Treeview(tree_frame, columns=("version", "status"), show="tree headings", style='Cyber.Treeview')
        self.project_tree.heading("#0", text="PROJECT")
        self.project_tree.heading("version", text="VERSION")
        self.project_tree.heading("status", text="STATUS")
        self.project_tree.column("#0", width=120)
        self.project_tree.column("version", width=80)
        self.project_tree.column("status", width=80)
        
        # 스크롤바
        tree_scroll = ttk.Scrollbar(tree_frame, orient="vertical", command=self.project_tree.yview)
        self.project_tree.configure(yscrollcommand=tree_scroll.set)
        
        self.project_tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        tree_scroll.grid(row=0, column=1, sticky=(tk.N, tk.S))
        
        # 프로젝트 선택 이벤트
        self.project_tree.bind("<<TreeviewSelect>>", self.on_project_select)
        
        # 사이드바 하단 버튼들
        sidebar_buttons = ttk.Frame(sidebar_frame, style='CyberSecondary.TFrame')
        sidebar_buttons.grid(row=1, column=0, sticky=(tk.W, tk.E), padx=10, pady=(0, 10))
        
        ttk.Button(sidebar_buttons, text="REFRESH", command=self.refresh_projects, style='Cyber.TButton').grid(row=0, column=0, sticky=(tk.W, tk.E), pady=2)
        ttk.Button(sidebar_buttons, text="ADD PROJECT", command=self.add_new_project, style='Cyber.TButton').grid(row=1, column=0, sticky=(tk.W, tk.E), pady=2)
        
        sidebar_buttons.columnconfigure(0, weight=1)
        tree_frame.columnconfigure(0, weight=1)
        tree_frame.rowconfigure(0, weight=1)
        
    def create_main_area(self, parent):
        """메인 영역 생성"""
        main_frame = ttk.Frame(parent, style='Cyber.TFrame')
        main_frame.grid(row=0, column=1, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 프로젝트 정보 패널
        info_frame = ttk.LabelFrame(main_frame, text="PROJECT INFORMATION", style='CyberSecondary.TFrame')
        info_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        
        self.create_project_info(info_frame)
        
        # 제어 패널
        control_frame = ttk.LabelFrame(main_frame, text="CONTROL PANEL", style='CyberSecondary.TFrame')
        control_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        self.create_control_panel(control_frame)
        
        # 시스템 모니터
        monitor_frame = ttk.LabelFrame(main_frame, text="SYSTEM MONITOR", style='CyberSecondary.TFrame')
        monitor_frame.grid(row=2, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        self.create_system_monitor(monitor_frame)
        
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(0, weight=1)
        
    def create_project_info(self, parent):
        """프로젝트 정보 패널"""
        info_content = ttk.Frame(parent, style='CyberSecondary.TFrame')
        info_content.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=10, pady=10)
        
        self.project_name_label = ttk.Label(info_content, text="NO PROJECT SELECTED", style='CyberHeading.TLabel')
        self.project_name_label.grid(row=0, column=0, sticky=tk.W, pady=(0, 5))
        
        self.project_version_label = ttk.Label(info_content, text="", style='CyberNormal.TLabel')
        self.project_version_label.grid(row=1, column=0, sticky=tk.W, pady=(0, 5))
        
        self.project_description_label = ttk.Label(info_content, text="", style='CyberNormal.TLabel', wraplength=500)
        self.project_description_label.grid(row=2, column=0, sticky=tk.W, pady=(0, 10))
        
        # 프로젝트 상태 표시
        status_info = ttk.Frame(info_content, style='CyberSecondary.TFrame')
        status_info.grid(row=3, column=0, sticky=(tk.W, tk.E))
        
        ttk.Label(status_info, text="STATUS:", style='CyberHeading.TLabel').grid(row=0, column=0, sticky=tk.W)
        self.project_status_label = ttk.Label(status_info, text="", style='CyberNormal.TLabel')
        self.project_status_label.grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        ttk.Label(status_info, text="LAST UPDATE:", style='CyberHeading.TLabel').grid(row=1, column=0, sticky=tk.W, pady=(5, 0))
        self.project_update_label = ttk.Label(status_info, text="", style='CyberNormal.TLabel')
        self.project_update_label.grid(row=1, column=1, sticky=tk.W, padx=(10, 0), pady=(5, 0))
        
        parent.columnconfigure(0, weight=1)
        parent.rowconfigure(0, weight=1)
        
    def create_control_panel(self, parent):
        """제어 패널"""
        control_content = ttk.Frame(parent, style='CyberSecondary.TFrame')
        control_content.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=10, pady=10)
        
        # 버전 타입 선택
        version_frame = ttk.Frame(control_content, style='CyberSecondary.TFrame')
        version_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(version_frame, text="VERSION TYPE:", style='CyberHeading.TLabel').grid(row=0, column=0, sticky=tk.W)
        
        self.version_var = tk.StringVar(value="stable")
        version_radio_frame = ttk.Frame(version_frame, style='CyberSecondary.TFrame')
        version_radio_frame.grid(row=0, column=1, sticky=tk.W, padx=(20, 0))
        
        ttk.Radiobutton(version_radio_frame, text="STABLE", variable=self.version_var, 
                       value="stable", command=self.on_version_change, style='Cyber.TRadiobutton').grid(row=0, column=0, padx=(0, 10))
        ttk.Radiobutton(version_radio_frame, text="BETA", variable=self.version_var, 
                       value="beta", command=self.on_version_change, style='Cyber.TRadiobutton').grid(row=0, column=1)
        
        # 제어 버튼들
        button_frame = ttk.Frame(control_content, style='CyberSecondary.TFrame')
        button_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E))
        
        self.update_button = ttk.Button(button_frame, text="CHECK UPDATE", 
                                       command=self.check_updates, state="disabled", style='Cyber.TButton')
        self.update_button.grid(row=0, column=0, padx=(0, 5), pady=2)
        
        self.download_button = ttk.Button(button_frame, text="DOWNLOAD", 
                                         command=self.download_project, state="disabled", style='Cyber.TButton')
        self.download_button.grid(row=0, column=1, padx=(0, 5), pady=2)
        
        self.launch_button = ttk.Button(button_frame, text="LAUNCH", 
                                       command=self.launch_project, state="disabled", style='Cyber.TButton')
        self.launch_button.grid(row=0, column=2, padx=(0, 5), pady=2)
        
        self.uninstall_button = ttk.Button(button_frame, text="UNINSTALL", 
                                          command=self.uninstall_project, state="disabled", style='Cyber.TButton')
        self.uninstall_button.grid(row=0, column=3, pady=2)
        
        # 전체 제어 버튼들
        global_frame = ttk.Frame(control_content, style='CyberSecondary.TFrame')
        global_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))
        
        ttk.Button(global_frame, text="UPDATE ALL", command=self.check_all_updates, style='Cyber.TButton').grid(row=0, column=0, padx=(0, 5), pady=2)
        ttk.Button(global_frame, text="SETTINGS", command=self.show_settings, style='Cyber.TButton').grid(row=0, column=1, padx=(0, 5), pady=2)
        ttk.Button(global_frame, text="GITHUB", command=self.open_github, style='Cyber.TButton').grid(row=0, column=2, pady=2)
        
        control_content.columnconfigure(0, weight=1)
        
    def create_system_monitor(self, parent):
        """시스템 모니터"""
        monitor_content = ttk.Frame(parent, style='CyberSecondary.TFrame')
        monitor_content.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=10, pady=10)
        
        # 진행 상황
        progress_frame = ttk.Frame(monitor_content, style='CyberSecondary.TFrame')
        progress_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(progress_frame, text="SYSTEM STATUS:", style='CyberHeading.TLabel').grid(row=0, column=0, sticky=tk.W)
        
        self.progress = ttk.Progressbar(progress_frame, mode='indeterminate', style='Cyber.Horizontal.TProgressbar')
        self.progress.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(5, 0))
        
        # 상태 메시지
        self.status_label = ttk.Label(monitor_content, text="SYSTEM READY", style='CyberNormal.TLabel')
        self.status_label.grid(row=1, column=0, sticky=tk.W)
        
        # 로그 영역
        log_frame = ttk.Frame(monitor_content, style='CyberSecondary.TFrame')
        log_frame.grid(row=2, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(10, 0))
        
        ttk.Label(log_frame, text="SYSTEM LOG:", style='CyberHeading.TLabel').grid(row=0, column=0, sticky=tk.W)
        
        # 로그 텍스트 위젯
        self.log_text = tk.Text(log_frame, height=8, bg=CyberpunkStyle.SECONDARY_BG, 
                               fg=CyberpunkStyle.TEXT_WHITE, font=CyberpunkStyle.SMALL_FONT,
                               insertbackground=CyberpunkStyle.NEON_GREEN, selectbackground=CyberpunkStyle.ACCENT_BG)
        self.log_text.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(5, 0))
        
        log_scroll = ttk.Scrollbar(log_frame, orient="vertical", command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=log_scroll.set)
        log_scroll.grid(row=1, column=1, sticky=(tk.N, tk.S))
        
        monitor_content.columnconfigure(0, weight=1)
        monitor_content.rowconfigure(2, weight=1)
        progress_frame.columnconfigure(0, weight=1)
        log_frame.columnconfigure(0, weight=1)
        log_frame.rowconfigure(1, weight=1)
        
    def create_status_bar(self, parent):
        """하단 상태바"""
        status_bar = ttk.Frame(parent, style='Cyber.TFrame')
        status_bar.grid(row=2, column=0, sticky=(tk.W, tk.E), pady=(10, 0))
        
        self.status_info = ttk.Label(status_bar, text="INVARIANT v1.0.0 - MASTER PROJECT HUB", style='CyberGray.TLabel')
        self.status_info.grid(row=0, column=0, sticky=tk.W)
        
        self.cpu_info = ttk.Label(status_bar, text="CPU: N/A", style='CyberGray.TLabel')
        self.cpu_info.grid(row=0, column=1, sticky=tk.E)
        
        status_bar.columnconfigure(0, weight=1)
        
    def update_time(self):
        """시간 업데이트"""
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.system_time.config(text=f"TIME: {current_time}")
        self.root.after(1000, self.update_time)
        
    def log_message(self, message, level="INFO"):
        """로그 메시지 추가"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        color_map = {
            "INFO": CyberpunkStyle.TEXT_WHITE,
            "WARNING": CyberpunkStyle.WARNING,
            "ERROR": CyberpunkStyle.NEON_RED,
            "SUCCESS": CyberpunkStyle.NEON_GREEN
        }
        
        self.log_text.insert(tk.END, f"[{timestamp}] {level}: {message}\n")
        self.log_text.see(tk.END)
        
        # 최대 100줄 유지
        lines = self.log_text.get("1.0", tk.END).split('\n')
        if len(lines) > 100:
            self.log_text.delete("1.0", f"{len(lines)-100}.0")
            
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
                    status = "INSTALLED"
                else:
                    version = "Unknown"
                    status = "PARTIAL"
            else:
                version = "-"
                status = "NOT INSTALLED"
            
            # 트리뷰에 추가
            self.project_tree.insert("", "end", project_id, 
                                   text=project_info["name"],
                                   values=(version, status))
        
        self.log_message(f"Loaded {len(self.default_projects)} projects", "SUCCESS")
        
    def on_project_select(self, event):
        """프로젝트 선택 이벤트"""
        selection = self.project_tree.selection()
        if selection:
            project_id = selection[0]
            self.current_selected_project = project_id
            self.update_project_info(project_id)
            self.update_button_states()
            self.log_message(f"Selected project: {project_id}", "INFO")
            
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
                        self.project_version_label.config(text=f"VERSION: {version}")
                        self.project_update_label.config(text=install_date)
                        self.project_status_label.config(text="INSTALLED")
                    except:
                        self.project_version_label.config(text="VERSION: Unknown")
                        self.project_status_label.config(text="ERROR")
                else:
                    self.project_version_label.config(text="VERSION: Unknown")
                    self.project_status_label.config(text="PARTIAL")
            else:
                self.project_version_label.config(text="NOT INSTALLED")
                self.project_status_label.config(text="NOT INSTALLED")
                self.project_update_label.config(text="N/A")
            
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
            
    def on_version_change(self):
        """버전 타입 변경"""
        self.selected_version_type = self.version_var.get()
        self.log_message(f"Version type changed to: {self.selected_version_type}", "INFO")
        
    def check_updates(self):
        """선택된 프로젝트 업데이트 확인"""
        if not self.current_selected_project:
            return
            
        def check_thread():
            self.progress.start()
            self.status_label.config(text="CHECKING FOR UPDATES...")
            self.update_button.config(state="disabled")
            self.log_message(f"Checking updates for {self.current_selected_project}", "INFO")
            
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
                        self.root.after(0, lambda: self.status_label.config(text=f"UPDATE AVAILABLE: {current_version} → {latest_version}"))
                        self.root.after(0, lambda: self.log_message(f"Update available: {current_version} → {latest_version}", "WARNING"))
                    else:
                        self.root.after(0, lambda: self.status_label.config(text="LATEST VERSION INSTALLED"))
                        self.root.after(0, lambda: self.log_message(f"Latest version installed", "SUCCESS"))
                else:
                    self.root.after(0, lambda: self.status_label.config(text="NO RELEASES FOUND"))
                    self.root.after(0, lambda: self.log_message("No releases found", "WARNING"))
                    
            except Exception as e:
                self.root.after(0, lambda: self.status_label.config(text=f"UPDATE CHECK FAILED: {str(e)}"))
                self.root.after(0, lambda: self.log_message(f"Update check failed: {str(e)}", "ERROR"))
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
                self.status_label.config(text="DOWNLOADING...")
                self.download_button.config(state="disabled")
                self.log_message(f"Starting download for {self.current_selected_project}", "INFO")
                
                project_info = self.default_projects[self.current_selected_project]
                repo_name = project_info["repo_name"]
                
                # GitHub API로 릴리즈 정보 가져오기
                api_url = f"https://api.github.com/repos/{self.github_owner}/{repo_name}/releases"
                
                with urllib.request.urlopen(api_url, timeout=10) as response:
                    releases = json.loads(response.read().decode())
                
                if not releases:
                    raise Exception("No releases found")
                
                latest_release = releases[0]
                
                # ZIP 파일 찾기
                zip_asset = None
                for asset in latest_release['assets']:
                    if asset['name'].endswith('.zip'):
                        zip_asset = asset
                        break
                
                if not zip_asset:
                    raise Exception("ZIP file not found")
                
                # 다운로드
                self.root.after(0, lambda: self.status_label.config(text="DOWNLOADING FILES..."))
                self.root.after(0, lambda: self.log_message("Downloading files...", "INFO"))
                download_url = zip_asset['browser_download_url']
                
                # 임시 디렉토리에 다운로드
                temp_dir = self.launcher_dir / "temp"
                temp_dir.mkdir(exist_ok=True)
                zip_path = temp_dir / f"{self.current_selected_project}.zip"
                
                with urllib.request.urlopen(download_url, timeout=30) as response:
                    with open(zip_path, 'wb') as f:
                        f.write(response.read())
                
                # 설치
                self.root.after(0, lambda: self.status_label.config(text="INSTALLING..."))
                self.root.after(0, lambda: self.log_message("Installing project...", "INFO"))
                self.install_project(zip_path, latest_release['tag_name'].lstrip('v'))
                
                # 정리
                shutil.rmtree(temp_dir, ignore_errors=True)
                
                self.root.after(0, lambda: self.status_label.config(text="INSTALLATION COMPLETE"))
                self.root.after(0, lambda: self.log_message(f"Installation complete for {self.current_selected_project}", "SUCCESS"))
                self.root.after(0, self.load_projects)
                self.root.after(0, self.update_project_info(self.current_selected_project))
                
            except Exception as e:
                self.root.after(0, lambda: self.status_label.config(text=f"INSTALLATION FAILED: {str(e)}"))
                self.root.after(0, lambda: self.log_message(f"Installation failed: {str(e)}", "ERROR"))
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
                self.status_label.config(text="LAUNCHING APPLICATION...")
                self.log_message(f"Launching {self.current_selected_project}", "INFO")
                subprocess.Popen([sys.executable, str(app_path)], 
                               cwd=str(project_path))
                self.log_message(f"Application launched successfully", "SUCCESS")
            else:
                messagebox.showerror("ERROR", f"Application file not found: {main_file}")
                self.log_message(f"Application file not found: {main_file}", "ERROR")
        except Exception as e:
            messagebox.showerror("ERROR", f"Application launch failed: {str(e)}")
            self.log_message(f"Application launch failed: {str(e)}", "ERROR")
            
    def uninstall_project(self):
        """프로젝트 제거"""
        if not self.current_selected_project:
            return
            
        if messagebox.askyesno("CONFIRM", f"Uninstall {self.default_projects[self.current_selected_project]['name']}?"):
            try:
                project_path = self.projects_dir / self.current_selected_project
                if project_path.exists():
                    shutil.rmtree(project_path)
                    self.status_label.config(text="UNINSTALLATION COMPLETE")
                    self.log_message(f"Uninstalled {self.current_selected_project}", "SUCCESS")
                    self.load_projects()
                    self.update_project_info(self.current_selected_project)
                else:
                    self.status_label.config(text="PROJECT NOT INSTALLED")
                    self.log_message(f"Project not installed: {self.current_selected_project}", "WARNING")
            except Exception as e:
                messagebox.showerror("ERROR", f"Uninstallation failed: {str(e)}")
                self.log_message(f"Uninstallation failed: {str(e)}", "ERROR")
                
    def check_all_updates(self):
        """모든 프로젝트 업데이트 확인"""
        self.log_message("Checking updates for all projects", "INFO")
        self.status_label.config(text="CHECKING ALL PROJECTS...")
        # 구현 예정
        
    def add_new_project(self):
        """새 프로젝트 추가"""
        self.log_message("Add new project feature coming soon", "INFO")
        messagebox.showinfo("INFO", "Add new project feature is under development")
        
    def show_settings(self):
        """설정 다이얼로그"""
        settings_window = tk.Toplevel(self.root)
        settings_window.title("INVARIANT SETTINGS")
        settings_window.geometry("500x300")
        settings_window.resizable(False, False)
        settings_window.configure(bg=CyberpunkStyle.PRIMARY_BG)
        
        # GitHub 사용자명 입력
        ttk.Label(settings_window, text="GitHub Username:", style='CyberHeading.TLabel').grid(row=0, column=0, sticky=tk.W, padx=10, pady=10)
        username_var = tk.StringVar(value=self.github_owner)
        username_entry = ttk.Entry(settings_window, textvariable=username_var, width=30)
        username_entry.grid(row=0, column=1, padx=10, pady=10)
        
        # 저장소 기본 이름 입력
        ttk.Label(settings_window, text="Base Repository Name:", style='CyberHeading.TLabel').grid(row=1, column=0, sticky=tk.W, padx=10, pady=10)
        repo_var = tk.StringVar(value=self.base_repo_name)
        repo_entry = ttk.Entry(settings_window, textvariable=repo_var, width=30)
        repo_entry.grid(row=1, column=1, padx=10, pady=10)
        
        def save_settings():
            self.github_owner = username_var.get()
            self.base_repo_name = repo_var.get()
            self.save_config()
            settings_window.destroy()
            messagebox.showinfo("SETTINGS SAVED", "Settings have been saved successfully")
            self.log_message("Settings saved", "SUCCESS")
        
        ttk.Button(settings_window, text="SAVE", command=save_settings, style='Cyber.TButton').grid(row=2, column=1, pady=20)
        
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
        self.log_message("Projects refreshed", "SUCCESS")
        
    def open_github(self):
        """GitHub 열기"""
        github_url = f"https://github.com/{self.github_owner}"
        webbrowser.open(github_url)
        self.log_message(f"Opened GitHub: {github_url}", "INFO")
            
    def run(self):
        """런처 실행"""
        self.log_message("INVARIANT initialized successfully", "SUCCESS")
        self.root.mainloop()

if __name__ == "__main__":
    app = InvariantCyberpunk()
    app.run()
