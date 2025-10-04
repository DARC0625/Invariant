#!/usr/bin/env python3
"""
Project Template - Invariant 통합 프로젝트 템플릿
모든 프로젝트들이 사용할 표준 템플릿
"""

import os
import sys
import json
import tkinter as tk
from tkinter import ttk, messagebox
import threading
from pathlib import Path
from datetime import datetime

class InvariantStyle:
    """Invariant 통일 스타일"""
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

class InvariantProjectTemplate:
    """Invariant 프로젝트 템플릿 기본 클래스"""
    
    def __init__(self, project_name, project_version="1.0.0"):
        self.project_name = project_name
        self.project_version = project_version
        self.root = tk.Tk()
        self.setup_window()
        self.setup_styles()
        self.setup_ui()
        
    def setup_window(self):
        """윈도우 설정"""
        self.root.title(f"{self.project_name} v{self.project_version} - INVARIANT PROJECT")
        self.root.geometry("800x600")
        self.root.resizable(True, True)
        self.root.configure(bg=InvariantStyle.PRIMARY_BG)
        
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
        style.theme_use('clam')
        
        # 프레임 스타일
        style.configure('Invariant.TFrame', 
                       background=InvariantStyle.PRIMARY_BG,
                       relief='flat')
        
        style.configure('InvariantSecondary.TFrame',
                       background=InvariantStyle.SECONDARY_BG,
                       relief='flat')
        
        # 라벨 스타일
        style.configure('InvariantTitle.TLabel',
                       background=InvariantStyle.PRIMARY_BG,
                       foreground=InvariantStyle.NEON_GREEN,
                       font=InvariantStyle.TITLE_FONT)
        
        style.configure('InvariantHeading.TLabel',
                       background=InvariantStyle.PRIMARY_BG,
                       foreground=InvariantStyle.NEON_BLUE,
                       font=InvariantStyle.HEADING_FONT)
        
        style.configure('InvariantNormal.TLabel',
                       background=InvariantStyle.PRIMARY_BG,
                       foreground=InvariantStyle.TEXT_WHITE,
                       font=InvariantStyle.NORMAL_FONT)
        
        # 버튼 스타일
        style.configure('Invariant.TButton',
                       background=InvariantStyle.ACCENT_BG,
                       foreground=InvariantStyle.TEXT_WHITE,
                       font=InvariantStyle.NORMAL_FONT,
                       relief='flat',
                       borderwidth=2)
        
        style.map('Invariant.TButton',
                 background=[('active', InvariantStyle.NEON_GREEN),
                           ('pressed', InvariantStyle.NEON_BLUE)],
                 foreground=[('active', InvariantStyle.PRIMARY_BG)])
        
        # 프로그레스바 스타일
        style.configure('Invariant.Horizontal.TProgressbar',
                       background=InvariantStyle.NEON_GREEN,
                       troughcolor=InvariantStyle.SECONDARY_BG,
                       borderwidth=0,
                       lightcolor=InvariantStyle.NEON_GREEN,
                       darkcolor=InvariantStyle.NEON_GREEN)
        
    def setup_ui(self):
        """기본 UI 설정 - 하위 클래스에서 오버라이드"""
        # 메인 컨테이너
        main_container = ttk.Frame(self.root, style='Invariant.TFrame', padding="20")
        main_container.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 헤더
        self.create_header(main_container)
        
        # 메인 콘텐츠 (하위 클래스에서 구현)
        self.create_main_content(main_container)
        
        # 하단 상태바
        self.create_status_bar(main_container)
        
        # 그리드 가중치 설정
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_container.columnconfigure(0, weight=1)
        main_container.rowconfigure(1, weight=1)
        
    def create_header(self, parent):
        """헤더 생성"""
        header_frame = ttk.Frame(parent, style='Invariant.TFrame')
        header_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=(0, 20))
        
        # 제목
        title_label = ttk.Label(header_frame, text=self.project_name, style='InvariantTitle.TLabel')
        title_label.grid(row=0, column=0, sticky=tk.W)
        
        # 부제목
        subtitle_label = ttk.Label(header_frame, text=f"v{self.project_version} - INVARIANT PROJECT", style='InvariantHeading.TLabel')
        subtitle_label.grid(row=1, column=0, sticky=tk.W)
        
        # 상태 표시
        status_frame = ttk.Frame(header_frame, style='Invariant.TFrame')
        status_frame.grid(row=0, column=1, rowspan=2, sticky=(tk.E, tk.N))
        
        self.connection_status = ttk.Label(status_frame, text="● ONLINE", style='InvariantNormal.TLabel')
        self.connection_status.grid(row=0, column=0, sticky=tk.E)
        
        self.system_time = ttk.Label(status_frame, text="", style='InvariantNormal.TLabel')
        self.system_time.grid(row=1, column=0, sticky=tk.E)
        
        # 시간 업데이트
        self.update_time()
        
        header_frame.columnconfigure(0, weight=1)
        
    def create_main_content(self, parent):
        """메인 콘텐츠 - 하위 클래스에서 구현"""
        content_frame = ttk.Frame(parent, style='Invariant.TFrame')
        content_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 기본 메시지
        message_label = ttk.Label(content_frame, text="PROJECT CONTENT AREA", style='InvariantHeading.TLabel')
        message_label.grid(row=0, column=0, pady=50)
        
    def create_status_bar(self, parent):
        """하단 상태바"""
        status_bar = ttk.Frame(parent, style='Invariant.TFrame')
        status_bar.grid(row=2, column=0, sticky=(tk.W, tk.E), pady=(20, 0))
        
        self.status_info = ttk.Label(status_bar, text=f"{self.project_name} v{self.project_version} - READY", style='InvariantNormal.TLabel')
        self.status_info.grid(row=0, column=0, sticky=tk.W)
        
        self.cpu_info = ttk.Label(status_bar, text="INVARIANT PROJECT", style='InvariantNormal.TLabel')
        self.cpu_info.grid(row=0, column=1, sticky=tk.E)
        
        status_bar.columnconfigure(0, weight=1)
        
    def update_time(self):
        """시간 업데이트"""
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.system_time.config(text=f"TIME: {current_time}")
        self.root.after(1000, self.update_time)
        
    def log_message(self, message, level="INFO"):
        """로그 메시지 - 하위 클래스에서 구현"""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {level}: {message}")
        
    def run(self):
        """애플리케이션 실행"""
        self.log_message(f"{self.project_name} initialized successfully", "SUCCESS")
        self.root.mainloop()

class Project1Template(InvariantProjectTemplate):
    """Project 1 템플릿"""
    
    def __init__(self):
        super().__init__("PROJECT 1", "1.0.0")
        
    def create_main_content(self, parent):
        """Project 1 메인 콘텐츠"""
        content_frame = ttk.Frame(parent, style='Invariant.TFrame')
        content_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 프로젝트 1 전용 콘텐츠
        info_frame = ttk.LabelFrame(content_frame, text="PROJECT 1 INFORMATION", style='InvariantSecondary.TFrame')
        info_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=20, pady=20)
        
        ttk.Label(info_frame, text="This is Project 1", style='InvariantHeading.TLabel').grid(row=0, column=0, pady=20)
        ttk.Label(info_frame, text="First project in the Invariant ecosystem", style='InvariantNormal.TLabel').grid(row=1, column=0, pady=10)
        
        # 버튼들
        button_frame = ttk.Frame(content_frame, style='Invariant.TFrame')
        button_frame.grid(row=1, column=0, pady=20)
        
        ttk.Button(button_frame, text="START PROJECT 1", command=self.start_project, style='Invariant.TButton').grid(row=0, column=0, padx=10)
        ttk.Button(button_frame, text="CONFIGURE", command=self.configure_project, style='Invariant.TButton').grid(row=0, column=1, padx=10)
        
        content_frame.columnconfigure(0, weight=1)
        content_frame.rowconfigure(0, weight=1)
        
    def start_project(self):
        """프로젝트 1 시작"""
        self.log_message("Project 1 started", "SUCCESS")
        messagebox.showinfo("PROJECT 1", "Project 1 has been started successfully!")
        
    def configure_project(self):
        """프로젝트 1 설정"""
        self.log_message("Project 1 configuration opened", "INFO")
        messagebox.showinfo("CONFIGURATION", "Project 1 configuration panel")

class Project2Template(InvariantProjectTemplate):
    """Project 2 템플릿"""
    
    def __init__(self):
        super().__init__("PROJECT 2", "1.0.0")
        
    def create_main_content(self, parent):
        """Project 2 메인 콘텐츠"""
        content_frame = ttk.Frame(parent, style='Invariant.TFrame')
        content_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 프로젝트 2 전용 콘텐츠
        info_frame = ttk.LabelFrame(content_frame, text="PROJECT 2 INFORMATION", style='InvariantSecondary.TFrame')
        info_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=20, pady=20)
        
        ttk.Label(info_frame, text="This is Project 2", style='InvariantHeading.TLabel').grid(row=0, column=0, pady=20)
        ttk.Label(info_frame, text="Second project in the Invariant ecosystem", style='InvariantNormal.TLabel').grid(row=1, column=0, pady=10)
        
        # 버튼들
        button_frame = ttk.Frame(content_frame, style='Invariant.TFrame')
        button_frame.grid(row=1, column=0, pady=20)
        
        ttk.Button(button_frame, text="START PROJECT 2", command=self.start_project, style='Invariant.TButton').grid(row=0, column=0, padx=10)
        ttk.Button(button_frame, text="CONFIGURE", command=self.configure_project, style='Invariant.TButton').grid(row=0, column=1, padx=10)
        
        content_frame.columnconfigure(0, weight=1)
        content_frame.rowconfigure(0, weight=1)
        
    def start_project(self):
        """프로젝트 2 시작"""
        self.log_message("Project 2 started", "SUCCESS")
        messagebox.showinfo("PROJECT 2", "Project 2 has been started successfully!")
        
    def configure_project(self):
        """프로젝트 2 설정"""
        self.log_message("Project 2 configuration opened", "INFO")
        messagebox.showinfo("CONFIGURATION", "Project 2 configuration panel")

class Project3Template(InvariantProjectTemplate):
    """Project 3 템플릿"""
    
    def __init__(self):
        super().__init__("PROJECT 3", "1.0.0")
        
    def create_main_content(self, parent):
        """Project 3 메인 콘텐츠"""
        content_frame = ttk.Frame(parent, style='Invariant.TFrame')
        content_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 프로젝트 3 전용 콘텐츠
        info_frame = ttk.LabelFrame(content_frame, text="PROJECT 3 INFORMATION", style='InvariantSecondary.TFrame')
        info_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=20, pady=20)
        
        ttk.Label(info_frame, text="This is Project 3", style='InvariantHeading.TLabel').grid(row=0, column=0, pady=20)
        ttk.Label(info_frame, text="Third project in the Invariant ecosystem", style='InvariantNormal.TLabel').grid(row=1, column=0, pady=10)
        
        # 버튼들
        button_frame = ttk.Frame(content_frame, style='Invariant.TFrame')
        button_frame.grid(row=1, column=0, pady=20)
        
        ttk.Button(button_frame, text="START PROJECT 3", command=self.start_project, style='Invariant.TButton').grid(row=0, column=0, padx=10)
        ttk.Button(button_frame, text="CONFIGURE", command=self.configure_project, style='Invariant.TButton').grid(row=0, column=1, padx=10)
        
        content_frame.columnconfigure(0, weight=1)
        content_frame.rowconfigure(0, weight=1)
        
    def start_project(self):
        """프로젝트 3 시작"""
        self.log_message("Project 3 started", "SUCCESS")
        messagebox.showinfo("PROJECT 3", "Project 3 has been started successfully!")
        
    def configure_project(self):
        """프로젝트 3 설정"""
        self.log_message("Project 3 configuration opened", "INFO")
        messagebox.showinfo("CONFIGURATION", "Project 3 configuration panel")

# 사용 예시
if __name__ == "__main__":
    # 프로젝트 선택
    import sys
    if len(sys.argv) > 1:
        project_type = sys.argv[1]
        if project_type == "1":
            app = Project1Template()
        elif project_type == "2":
            app = Project2Template()
        elif project_type == "3":
            app = Project3Template()
        else:
            app = InvariantProjectTemplate("UNKNOWN PROJECT")
    else:
        app = InvariantProjectTemplate("DEFAULT PROJECT")
    
    app.run()
