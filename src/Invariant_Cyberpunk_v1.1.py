#!/usr/bin/env python3
"""
Invariant - Cyberpunk UI Master Project Hub
사이버틱 + 미래 군사 무기체계 UI
모든 프로젝트들의 통합 관리 시스템
"""

import sys
import os
import json
import zipfile
import urllib.request
import urllib.error
import subprocess
import shutil
import time
import threading
from pathlib import Path
from datetime import datetime
import webbrowser

from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                            QHBoxLayout, QGridLayout, QLabel, QPushButton, 
                            QFrame, QScrollArea, QProgressBar, QTextEdit,
                            QMessageBox, QSystemTrayIcon, QMenu, QAction)
from PyQt5.QtCore import Qt, QTimer, QThread, pyqtSignal, QPropertyAnimation, QEasingCurve
from PyQt5.QtGui import QFont, QPalette, QColor, QIcon, QPixmap, QPainter, QPen

class CyberpunkStyle:
    """사이버틱 + 미래 군사 무기체계 스타일 정의"""
    
    # 색상 팔레트
    PRIMARY_BG = QColor(10, 10, 10)        # 깊은 검정
    SECONDARY_BG = QColor(26, 26, 26)      # 어두운 회색
    ACCENT_BG = QColor(42, 42, 42)         # 중간 회색
    NEON_GREEN = QColor(0, 255, 65)        # 네온 그린 (시스템 정상)
    NEON_BLUE = QColor(0, 212, 255)        # 네온 블루 (정보)
    NEON_RED = QColor(255, 0, 64)          # 네온 레드 (경고/오류)
    NEON_ORANGE = QColor(255, 136, 0)      # 네온 오렌지 (경고)
    TEXT_WHITE = QColor(255, 255, 255)     # 흰색 텍스트
    TEXT_GRAY = QColor(136, 136, 136)      # 회색 텍스트
    BORDER_COLOR = QColor(0, 255, 65)      # 테두리 색상
    
    # 폰트
    TITLE_FONT = QFont("Consolas", 18, QFont.Bold)
    HEADING_FONT = QFont("Consolas", 14, QFont.Bold)
    NORMAL_FONT = QFont("Consolas", 11)
    SMALL_FONT = QFont("Consolas", 9)
    MONO_FONT = QFont("Courier New", 10)

class ProjectCard(QFrame):
    """프로젝트 카드 위젯"""
    
    def __init__(self, project_data, parent=None):
        super().__init__(parent)
        self.project_data = project_data
        self.setup_ui()
        self.setup_style()
        
    def setup_ui(self):
        """UI 설정"""
        layout = QVBoxLayout()
        layout.setSpacing(10)
        layout.setContentsMargins(15, 15, 15, 15)
        
        # 프로젝트 아이콘
        self.icon_label = QLabel()
        self.icon_label.setFixedSize(64, 64)
        self.icon_label.setAlignment(Qt.AlignCenter)
        self.icon_label.setText(self.get_project_icon())
        self.icon_label.setFont(QFont("Consolas", 24))
        layout.addWidget(self.icon_label)
        
        # 프로젝트 이름
        self.name_label = QLabel(self.project_data.get('name', 'Unknown'))
        self.name_label.setFont(CyberpunkStyle.HEADING_FONT)
        self.name_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.name_label)
        
        # 프로젝트 설명
        self.desc_label = QLabel(self.project_data.get('description', 'No description'))
        self.desc_label.setFont(CyberpunkStyle.SMALL_FONT)
        self.desc_label.setAlignment(Qt.AlignCenter)
        self.desc_label.setWordWrap(True)
        layout.addWidget(self.desc_label)
        
        # 상태 표시
        self.status_label = QLabel(self.get_status_text())
        self.status_label.setFont(CyberpunkStyle.SMALL_FONT)
        self.status_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.status_label)
        
        # 버전 정보
        self.version_label = QLabel(f"v{self.project_data.get('version', '1.0.0')}")
        self.version_label.setFont(CyberpunkStyle.SMALL_FONT)
        self.version_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.version_label)
        
        # 진행률 바
        self.progress_bar = QProgressBar()
        self.progress_bar.setVisible(False)
        layout.addWidget(self.progress_bar)
        
        self.setLayout(layout)
        
    def setup_style(self):
        """스타일 설정"""
        self.setFixedSize(200, 250)
        self.setFrameStyle(QFrame.Box)
        self.setLineWidth(2)
        
        # 기본 스타일
        self.setStyleSheet(f"""
            ProjectCard {{
                background-color: {CyberpunkStyle.SECONDARY_BG.name()};
                border: 2px solid {CyberpunkStyle.BORDER_COLOR.name()};
                border-radius: 10px;
            }}
            ProjectCard:hover {{
                border: 2px solid {CyberpunkStyle.NEON_BLUE.name()};
                background-color: {CyberpunkStyle.ACCENT_BG.name()};
            }}
            QLabel {{
                color: {CyberpunkStyle.TEXT_WHITE.name()};
                background-color: transparent;
            }}
            QProgressBar {{
                border: 1px solid {CyberpunkStyle.BORDER_COLOR.name()};
                border-radius: 5px;
                text-align: center;
                background-color: {CyberpunkStyle.PRIMARY_BG.name()};
            }}
            QProgressBar::chunk {{
                background-color: {CyberpunkStyle.NEON_GREEN.name()};
                border-radius: 4px;
            }}
        """)
        
    def get_project_icon(self):
        """프로젝트 아이콘 반환"""
        icons = {
            'Project 1': '🎮',
            'Project 2': '🎨', 
            'Project 3': '🔧',
            'Project 4': '🤖',
            'Project 5': '📱',
            'Project 6': '🌐',
            'Project 7': '🎵',
            'Project 8': '📊'
        }
        return icons.get(self.project_data.get('name', ''), '📦')
        
    def get_status_text(self):
        """상태 텍스트 반환"""
        status = self.project_data.get('status', 'unknown')
        status_map = {
            'installed': 'ACTIVE',
            'available': 'STANDBY',
            'updating': 'UPDATING',
            'error': 'ERROR'
        }
        return status_map.get(status, 'UNKNOWN')
        
    def update_status(self, new_status):
        """상태 업데이트"""
        self.project_data['status'] = new_status
        self.status_label.setText(self.get_status_text())
        
    def show_progress(self, value):
        """진행률 표시"""
        self.progress_bar.setVisible(True)
        self.progress_bar.setValue(value)
        
    def hide_progress(self):
        """진행률 숨김"""
        self.progress_bar.setVisible(False)

class InvariantCyberpunk(QMainWindow):
    """Invariant 메인 윈도우"""
    
    def __init__(self):
        super().__init__()
        self.setup_window()
        self.setup_ui()
        self.setup_style()
        self.setup_tray()
        self.load_projects()
        
    def setup_window(self):
        """윈도우 설정"""
        self.setWindowTitle("Invariant - Master Project Hub")
        self.setGeometry(100, 100, 1200, 800)
        self.setMinimumSize(1000, 600)
        
        # 윈도우 플래그
        self.setWindowFlags(Qt.Window | Qt.WindowMinimizeButtonHint | 
                           Qt.WindowMaximizeButtonHint | Qt.WindowCloseButtonHint)
        
    def setup_ui(self):
        """UI 설정"""
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        main_layout = QVBoxLayout()
        main_layout.setSpacing(20)
        main_layout.setContentsMargins(20, 20, 20, 20)
        
        # 헤더
        self.create_header(main_layout)
        
        # 프로젝트 그리드
        self.create_project_grid(main_layout)
        
        # 상태 바
        self.create_status_bar(main_layout)
        
        # 컨트롤 패널
        self.create_control_panel(main_layout)
        
        central_widget.setLayout(main_layout)
        
    def create_header(self, parent_layout):
        """헤더 생성"""
        header_frame = QFrame()
        header_frame.setFixedHeight(80)
        header_layout = QHBoxLayout()
        header_layout.setContentsMargins(20, 10, 20, 10)
        
        # 타이틀
        title_label = QLabel("INVARIANT")
        title_label.setFont(CyberpunkStyle.TITLE_FONT)
        title_label.setStyleSheet(f"color: {CyberpunkStyle.NEON_GREEN.name()};")
        header_layout.addWidget(title_label)
        
        header_layout.addStretch()
        
        # 상태 정보
        self.status_info = QLabel("STATUS: ONLINE | USERS: 1 | PROJECTS: 8")
        self.status_info.setFont(CyberpunkStyle.NORMAL_FONT)
        self.status_info.setStyleSheet(f"color: {CyberpunkStyle.TEXT_GRAY.name()};")
        header_layout.addWidget(self.status_info)
        
        header_frame.setLayout(header_layout)
        header_frame.setStyleSheet(f"""
            QFrame {{
                background-color: {CyberpunkStyle.PRIMARY_BG.name()};
                border: 2px solid {CyberpunkStyle.BORDER_COLOR.name()};
                border-radius: 10px;
            }}
        """)
        
        parent_layout.addWidget(header_frame)
        
    def create_project_grid(self, parent_layout):
        """프로젝트 그리드 생성"""
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        scroll_area.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
        
        self.project_widget = QWidget()
        self.project_layout = QGridLayout()
        self.project_layout.setSpacing(20)
        self.project_layout.setContentsMargins(20, 20, 20, 20)
        
        self.project_widget.setLayout(self.project_layout)
        scroll_area.setWidget(self.project_widget)
        
        scroll_area.setStyleSheet(f"""
            QScrollArea {{
                background-color: {CyberpunkStyle.PRIMARY_BG.name()};
                border: 2px solid {CyberpunkStyle.BORDER_COLOR.name()};
                border-radius: 10px;
            }}
            QScrollBar:vertical {{
                background-color: {CyberpunkStyle.SECONDARY_BG.name()};
                width: 12px;
                border-radius: 6px;
            }}
            QScrollBar::handle:vertical {{
                background-color: {CyberpunkStyle.NEON_GREEN.name()};
                border-radius: 6px;
            }}
        """)
        
        parent_layout.addWidget(scroll_area)
        
    def create_status_bar(self, parent_layout):
        """상태 바 생성"""
        status_frame = QFrame()
        status_frame.setFixedHeight(60)
        status_layout = QHBoxLayout()
        status_layout.setContentsMargins(20, 10, 20, 10)
        
        # 시스템 상태
        self.system_status = QLabel("SYSTEM: OPERATIONAL")
        self.system_status.setFont(CyberpunkStyle.NORMAL_FONT)
        self.system_status.setStyleSheet(f"color: {CyberpunkStyle.NEON_GREEN.name()};")
        status_layout.addWidget(self.system_status)
        
        status_layout.addStretch()
        
        # 마지막 업데이트
        self.last_update = QLabel(f"LAST UPDATE: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        self.last_update.setFont(CyberpunkStyle.SMALL_FONT)
        self.last_update.setStyleSheet(f"color: {CyberpunkStyle.TEXT_GRAY.name()};")
        status_layout.addWidget(self.last_update)
        
        status_frame.setLayout(status_layout)
        status_frame.setStyleSheet(f"""
            QFrame {{
                background-color: {CyberpunkStyle.SECONDARY_BG.name()};
                border: 1px solid {CyberpunkStyle.BORDER_COLOR.name()};
                border-radius: 5px;
            }}
        """)
        
        parent_layout.addWidget(status_frame)
        
    def create_control_panel(self, parent_layout):
        """컨트롤 패널 생성"""
        control_frame = QFrame()
        control_frame.setFixedHeight(80)
        control_layout = QHBoxLayout()
        control_layout.setContentsMargins(20, 10, 20, 10)
        
        # 컨트롤 버튼들
        buttons = [
            ("DEPLOY", self.deploy_project),
            ("UPDATE", self.update_projects),
            ("TERMINATE", self.terminate_project),
            ("CONFIGURE", self.configure_system),
            ("STATUS", self.show_status)
        ]
        
        for text, callback in buttons:
            btn = QPushButton(text)
            btn.setFont(CyberpunkStyle.HEADING_FONT)
            btn.setFixedSize(120, 40)
            btn.clicked.connect(callback)
            btn.setStyleSheet(f"""
                QPushButton {{
                    background-color: {CyberpunkStyle.ACCENT_BG.name()};
                    border: 2px solid {CyberpunkStyle.BORDER_COLOR.name()};
                    border-radius: 5px;
                    color: {CyberpunkStyle.TEXT_WHITE.name()};
                }}
                QPushButton:hover {{
                    background-color: {CyberpunkStyle.NEON_GREEN.name()};
                    color: {CyberpunkStyle.PRIMARY_BG.name()};
                }}
                QPushButton:pressed {{
                    background-color: {CyberpunkStyle.NEON_BLUE.name()};
                }}
            """)
            control_layout.addWidget(btn)
            
        control_layout.addStretch()
        
        control_frame.setLayout(control_layout)
        control_frame.setStyleSheet(f"""
            QFrame {{
                background-color: {CyberpunkStyle.PRIMARY_BG.name()};
                border: 2px solid {CyberpunkStyle.BORDER_COLOR.name()};
                border-radius: 10px;
            }}
        """)
        
        parent_layout.addWidget(control_frame)
        
    def setup_style(self):
        """전체 스타일 설정"""
        self.setStyleSheet(f"""
            QMainWindow {{
                background-color: {CyberpunkStyle.PRIMARY_BG.name()};
            }}
            QWidget {{
                background-color: {CyberpunkStyle.PRIMARY_BG.name()};
                color: {CyberpunkStyle.TEXT_WHITE.name()};
            }}
        """)
        
    def setup_tray(self):
        """시스템 트레이 설정"""
        self.tray_icon = QSystemTrayIcon(self)
        self.tray_icon.setIcon(self.style().standardIcon(self.style().SP_ComputerIcon))
        
        tray_menu = QMenu()
        
        show_action = QAction("Show", self)
        show_action.triggered.connect(self.show)
        tray_menu.addAction(show_action)
        
        quit_action = QAction("Quit", self)
        quit_action.triggered.connect(self.close)
        tray_menu.addAction(quit_action)
        
        self.tray_icon.setContextMenu(tray_menu)
        self.tray_icon.show()
        
    def load_projects(self):
        """프로젝트 목록 로드"""
        # 샘플 프로젝트 데이터
        projects = [
            {
                'name': 'Project 1',
                'description': 'Game Development Tools',
                'version': '1.2.0',
                'status': 'installed'
            },
            {
                'name': 'Project 2', 
                'description': 'Design Suite',
                'version': '2.1.0',
                'status': 'available'
            },
            {
                'name': 'Project 3',
                'description': 'System Tools',
                'version': '1.0.0',
                'status': 'installed'
            },
            {
                'name': 'Project 4',
                'description': 'AI Agent (YOLO)',
                'version': '1.0.0',
                'status': 'installed'
            },
            {
                'name': 'Project 5',
                'description': 'Mobile Development',
                'version': '1.5.0',
                'status': 'available'
            },
            {
                'name': 'Project 6',
                'description': 'Web Framework',
                'version': '3.0.0',
                'status': 'installed'
            },
            {
                'name': 'Project 7',
                'description': 'Audio Processing',
                'version': '1.1.0',
                'status': 'available'
            },
            {
                'name': 'Project 8',
                'description': 'Analytics Dashboard',
                'version': '2.2.0',
                'status': 'installed'
            }
        ]
        
        # 프로젝트 카드 생성
        for i, project in enumerate(projects):
            card = ProjectCard(project)
            row = i // 4
            col = i % 4
            self.project_layout.addWidget(card, row, col)
            
    def deploy_project(self):
        """프로젝트 배포"""
        QMessageBox.information(self, "Deploy", "Project deployment initiated...")
        
    def update_projects(self):
        """프로젝트 업데이트"""
        QMessageBox.information(self, "Update", "Checking for updates...")
        
    def terminate_project(self):
        """프로젝트 종료"""
        QMessageBox.information(self, "Terminate", "Project termination initiated...")
        
    def configure_system(self):
        """시스템 설정"""
        QMessageBox.information(self, "Configure", "System configuration panel...")
        
    def show_status(self):
        """상태 표시"""
        QMessageBox.information(self, "Status", "System status: OPERATIONAL")

def main():
    """메인 함수"""
    app = QApplication(sys.argv)
    app.setApplicationName("Invariant")
    app.setApplicationVersion("1.1.0")
    
    # 어두운 테마 설정
    app.setStyle('Fusion')
    
    window = InvariantCyberpunk()
    window.show()
    
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
