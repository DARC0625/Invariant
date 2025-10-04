#!/usr/bin/env python3
"""
Invariant Premium - 상용 소프트웨어 수준의 미래적 UI
웰컴 애니메이션, 고급 시각 효과, 프리미엄 디자인
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
import math
from pathlib import Path
from datetime import datetime
import webbrowser

from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                            QHBoxLayout, QGridLayout, QLabel, QPushButton, 
                            QFrame, QScrollArea, QProgressBar, QTextEdit,
                            QMessageBox, QSystemTrayIcon, QMenu, QAction,
                            QGraphicsDropShadowEffect, QGraphicsOpacityEffect)
from PyQt5.QtCore import (Qt, QTimer, QThread, pyqtSignal, QPropertyAnimation, 
                         QEasingCurve, QRect, QPoint, QSize, QParallelAnimationGroup,
                         QSequentialAnimationGroup, QVariantAnimation)
from PyQt5.QtGui import (QFont, QPalette, QColor, QIcon, QPixmap, QPainter, 
                        QPen, QBrush, QLinearGradient, QRadialGradient, QFontDatabase)

class PremiumStyle:
    """프리미엄 미래적 스타일 정의"""
    
    # 고급 색상 팔레트
    PRIMARY_BG = QColor(5, 5, 15)           # 깊은 우주 블루
    SECONDARY_BG = QColor(15, 15, 35)       # 어두운 네이비
    ACCENT_BG = QColor(25, 25, 55)          # 중간 블루
    CARD_BG = QColor(20, 20, 45)            # 카드 배경
    
    # 네온 색상 (고급)
    NEON_CYAN = QColor(0, 255, 255)         # 시안
    NEON_GREEN = QColor(0, 255, 128)        # 그린
    NEON_BLUE = QColor(64, 128, 255)        # 블루
    NEON_PURPLE = QColor(128, 64, 255)      # 퍼플
    NEON_ORANGE = QColor(255, 128, 0)       # 오렌지
    NEON_RED = QColor(255, 64, 64)          # 레드
    
    # 텍스트 색상
    TEXT_PRIMARY = QColor(255, 255, 255)    # 주 텍스트
    TEXT_SECONDARY = QColor(200, 200, 220)  # 보조 텍스트
    TEXT_MUTED = QColor(150, 150, 170)      # 흐린 텍스트
    
    # 그라데이션
    GRADIENT_START = QColor(0, 100, 200)
    GRADIENT_END = QColor(100, 0, 200)
    
    # 폰트
    TITLE_FONT = QFont("Segoe UI", 24, QFont.Bold)
    HEADING_FONT = QFont("Segoe UI", 16, QFont.Bold)
    NORMAL_FONT = QFont("Segoe UI", 12)
    SMALL_FONT = QFont("Segoe UI", 10)
    MONO_FONT = QFont("Consolas", 11)

class WelcomeScreen(QWidget):
    """웰컴 애니메이션 화면"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()
        self.setup_animations()
        
    def setup_ui(self):
        """UI 설정"""
        self.setFixedSize(800, 600)
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint)
        
        # 중앙 레이아웃
        layout = QVBoxLayout()
        layout.setAlignment(Qt.AlignCenter)
        layout.setSpacing(30)
        
        # 로고 영역
        self.logo_container = QFrame()
        self.logo_container.setFixedSize(200, 200)
        self.logo_container.setStyleSheet("""
            QFrame {
                background: qradialgradient(cx:0.5, cy:0.5, radius:1.0,
                    stop:0 rgba(0, 255, 255, 100),
                    stop:0.5 rgba(64, 128, 255, 50),
                    stop:1 rgba(128, 64, 255, 0));
                border-radius: 100px;
                border: 2px solid rgba(0, 255, 255, 150);
            }
        """)
        
        self.logo_label = QLabel("INVARIANT")
        self.logo_label.setFont(PremiumStyle.TITLE_FONT)
        self.logo_label.setAlignment(Qt.AlignCenter)
        self.logo_label.setStyleSheet("""
            QLabel {
                color: rgba(255, 255, 255, 200);
                background: transparent;
            }
        """)
        
        logo_layout = QVBoxLayout()
        logo_layout.addWidget(self.logo_label)
        self.logo_container.setLayout(logo_layout)
        
        # 제목
        self.title_label = QLabel("MASTER PROJECT HUB")
        self.title_label.setFont(PremiumStyle.HEADING_FONT)
        self.title_label.setAlignment(Qt.AlignCenter)
        self.title_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 255, 180);
                background: transparent;
                letter-spacing: 3px;
            }
        """)
        
        # 부팅 메시지
        self.boot_label = QLabel("INITIALIZING SYSTEM...")
        self.boot_label.setFont(PremiumStyle.NORMAL_FONT)
        self.boot_label.setAlignment(Qt.AlignCenter)
        self.boot_label.setStyleSheet("""
            QLabel {
                color: rgba(200, 200, 220, 150);
                background: transparent;
            }
        """)
        
        # 진행률 바
        self.progress_bar = QProgressBar()
        self.progress_bar.setFixedSize(300, 8)
        self.progress_bar.setStyleSheet("""
            QProgressBar {
                border: 1px solid rgba(0, 255, 255, 100);
                border-radius: 4px;
                background: rgba(20, 20, 45, 200);
                text-align: center;
            }
            QProgressBar::chunk {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                    stop:0 rgba(0, 255, 255, 200),
                    stop:1 rgba(64, 128, 255, 200));
                border-radius: 3px;
            }
        """)
        
        # 레이아웃 구성
        layout.addWidget(self.logo_container)
        layout.addWidget(self.title_label)
        layout.addWidget(self.boot_label)
        layout.addWidget(self.progress_bar)
        
        self.setLayout(layout)
        
        # 배경 설정
        self.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(5, 5, 15, 255),
                    stop:0.5 rgba(15, 15, 35, 255),
                    stop:1 rgba(25, 25, 55, 255));
            }
        """)
        
    def setup_animations(self):
        """애니메이션 설정"""
        # 로고 회전 애니메이션
        self.logo_rotation = QPropertyAnimation(self.logo_container, b"rotation")
        self.logo_rotation.setDuration(3000)
        self.logo_rotation.setStartValue(0)
        self.logo_rotation.setEndValue(360)
        self.logo_rotation.setLoopCount(-1)
        self.logo_rotation.setEasingCurve(QEasingCurve.Linear)
        
        # 로고 크기 애니메이션
        self.logo_scale = QPropertyAnimation(self.logo_container, b"scale")
        self.logo_scale.setDuration(2000)
        self.logo_scale.setStartValue(0.8)
        self.logo_scale.setEndValue(1.2)
        self.logo_scale.setLoopCount(-1)
        self.logo_scale.setEasingCurve(QEasingCurve.InOutSine)
        
        # 페이드 인 애니메이션
        self.fade_in = QPropertyAnimation(self, b"windowOpacity")
        self.fade_in.setDuration(1000)
        self.fade_in.setStartValue(0.0)
        self.fade_in.setEndValue(1.0)
        self.fade_in.setEasingCurve(QEasingCurve.OutCubic)
        
        # 진행률 애니메이션
        self.progress_animation = QPropertyAnimation(self.progress_bar, b"value")
        self.progress_animation.setDuration(5000)
        self.progress_animation.setStartValue(0)
        self.progress_animation.setEndValue(100)
        self.progress_animation.setEasingCurve(QEasingCurve.OutQuart)
        
        # 부팅 메시지 변경
        self.boot_messages = [
            "INITIALIZING SYSTEM...",
            "LOADING CORE MODULES...",
            "ESTABLISHING CONNECTIONS...",
            "PREPARING INTERFACE...",
            "SYSTEM READY"
        ]
        self.current_message = 0
        
        self.message_timer = QTimer()
        self.message_timer.timeout.connect(self.update_boot_message)
        self.message_timer.start(1000)
        
    def start_animations(self):
        """애니메이션 시작"""
        self.fade_in.start()
        self.logo_rotation.start()
        self.logo_scale.start()
        self.progress_animation.start()
        self.message_timer.start()
        
    def update_boot_message(self):
        """부팅 메시지 업데이트"""
        if self.current_message < len(self.boot_messages):
            self.boot_label.setText(self.boot_messages[self.current_message])
            self.current_message += 1
        else:
            self.message_timer.stop()

class PremiumProjectCard(QFrame):
    """프리미엄 프로젝트 카드"""
    
    def __init__(self, project_data, parent=None):
        super().__init__(parent)
        self.project_data = project_data
        self.setup_ui()
        self.setup_effects()
        self.setup_animations()
        
    def setup_ui(self):
        """UI 설정"""
        self.setFixedSize(280, 320)
        self.setCursor(Qt.PointingHandCursor)
        
        # 메인 레이아웃
        layout = QVBoxLayout()
        layout.setSpacing(15)
        layout.setContentsMargins(20, 20, 20, 20)
        
        # 아이콘 영역
        self.icon_frame = QFrame()
        self.icon_frame.setFixedSize(80, 80)
        self.icon_frame.setStyleSheet("""
            QFrame {
                background: qradialgradient(cx:0.5, cy:0.5, radius:1.0,
                    stop:0 rgba(64, 128, 255, 100),
                    stop:1 rgba(128, 64, 255, 50));
                border-radius: 40px;
                border: 2px solid rgba(0, 255, 255, 100);
            }
        """)
        
        self.icon_label = QLabel(self.get_project_icon())
        self.icon_label.setFont(QFont("Segoe UI", 32))
        self.icon_label.setAlignment(Qt.AlignCenter)
        self.icon_label.setStyleSheet("color: rgba(255, 255, 255, 200);")
        
        icon_layout = QVBoxLayout()
        icon_layout.addWidget(self.icon_label)
        self.icon_frame.setLayout(icon_layout)
        
        # 프로젝트 정보
        self.name_label = QLabel(self.project_data.get('name', 'Unknown'))
        self.name_label.setFont(PremiumStyle.HEADING_FONT)
        self.name_label.setAlignment(Qt.AlignCenter)
        self.name_label.setStyleSheet("""
            QLabel {
                color: rgba(255, 255, 255, 220);
                background: transparent;
            }
        """)
        
        self.desc_label = QLabel(self.project_data.get('description', 'No description'))
        self.desc_label.setFont(PremiumStyle.SMALL_FONT)
        self.desc_label.setAlignment(Qt.AlignCenter)
        self.desc_label.setWordWrap(True)
        self.desc_label.setStyleSheet("""
            QLabel {
                color: rgba(200, 200, 220, 180);
                background: transparent;
            }
        """)
        
        # 상태 표시
        self.status_frame = QFrame()
        self.status_frame.setFixedHeight(30)
        self.status_frame.setStyleSheet("""
            QFrame {
                background: rgba(0, 255, 128, 50);
                border-radius: 15px;
                border: 1px solid rgba(0, 255, 128, 100);
            }
        """)
        
        self.status_label = QLabel("ONLINE")
        self.status_label.setFont(PremiumStyle.SMALL_FONT)
        self.status_label.setAlignment(Qt.AlignCenter)
        self.status_label.setStyleSheet("color: rgba(0, 255, 128, 200);")
        
        status_layout = QVBoxLayout()
        status_layout.addWidget(self.status_label)
        self.status_frame.setLayout(status_layout)
        
        # 버전 정보
        self.version_label = QLabel(f"v{self.project_data.get('version', '1.0.0')}")
        self.version_label.setFont(PremiumStyle.SMALL_FONT)
        self.version_label.setAlignment(Qt.AlignCenter)
        self.version_label.setStyleSheet("""
            QLabel {
                color: rgba(150, 150, 170, 150);
                background: transparent;
            }
        """)
        
        # 레이아웃 구성
        layout.addWidget(self.icon_frame)
        layout.addWidget(self.name_label)
        layout.addWidget(self.desc_label)
        layout.addWidget(self.status_frame)
        layout.addWidget(self.version_label)
        
        self.setLayout(layout)
        
        # 카드 스타일
        self.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(20, 20, 45, 200),
                    stop:1 rgba(25, 25, 55, 200));
                border-radius: 15px;
                border: 1px solid rgba(0, 255, 255, 50);
            }
            QFrame:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(30, 30, 65, 220),
                    stop:1 rgba(35, 35, 75, 220));
                border: 2px solid rgba(0, 255, 255, 150);
            }
        """)
        
    def setup_effects(self):
        """시각 효과 설정"""
        # 그림자 효과
        shadow = QGraphicsDropShadowEffect()
        shadow.setBlurRadius(20)
        shadow.setColor(QColor(0, 255, 255, 100))
        shadow.setOffset(0, 5)
        self.setGraphicsEffect(shadow)
        
    def setup_animations(self):
        """애니메이션 설정"""
        # 호버 애니메이션
        self.hover_animation = QPropertyAnimation(self, b"geometry")
        self.hover_animation.setDuration(200)
        self.hover_animation.setEasingCurve(QEasingCurve.OutCubic)
        
    def get_project_icon(self):
        """프로젝트 아이콘 반환"""
        icons = {
            "Project 1": "⚡",
            "Project 2": "🔮",
            "Project 3": "🚀",
            "Project 4": "🤖",
            "Project 5": "💎",
            "Project 6": "🌟",
            "Project 7": "🔥",
            "Project 8": "⚡"
        }
        return icons.get(self.project_data.get('name', 'Project 1'), "⚡")
    
    def enterEvent(self, event):
        """마우스 진입 이벤트"""
        self.hover_animation.setStartValue(self.geometry())
        self.hover_animation.setEndValue(QRect(self.x()-5, self.y()-5, 
                                              self.width()+10, self.height()+10))
        self.hover_animation.start()
        super().enterEvent(event)
        
    def leaveEvent(self, event):
        """마우스 이탈 이벤트"""
        self.hover_animation.setStartValue(self.geometry())
        self.hover_animation.setEndValue(QRect(self.x()+5, self.y()+5, 
                                              self.width()-10, self.height()-10))
        self.hover_animation.start()
        super().leaveEvent(event)

class InvariantPremium(QMainWindow):
    """프리미엄 Invariant 메인 윈도우"""
    
    def __init__(self):
        super().__init__()
        self.welcome_screen = None
        self.setup_ui()
        self.setup_animations()
        self.show_welcome_screen()
        
    def setup_ui(self):
        """UI 설정"""
        self.setWindowTitle("Invariant Premium - Master Project Hub")
        self.setMinimumSize(1200, 800)
        self.resize(1400, 900)
        
        # 중앙 위젯
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # 메인 레이아웃
        main_layout = QVBoxLayout()
        main_layout.setSpacing(20)
        main_layout.setContentsMargins(30, 30, 30, 30)
        
        # 헤더 영역
        self.setup_header(main_layout)
        
        # 프로젝트 그리드 영역
        self.setup_project_grid(main_layout)
        
        # 컨트롤 패널
        self.setup_control_panel(main_layout)
        
        central_widget.setLayout(main_layout)
        
        # 윈도우 스타일
        self.setStyleSheet("""
            QMainWindow {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(5, 5, 15, 255),
                    stop:0.5 rgba(15, 15, 35, 255),
                    stop:1 rgba(25, 25, 55, 255));
            }
        """)
        
    def setup_header(self, layout):
        """헤더 설정"""
        header_frame = QFrame()
        header_frame.setFixedHeight(120)
        header_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                    stop:0 rgba(0, 100, 200, 100),
                    stop:1 rgba(100, 0, 200, 100));
                border-radius: 20px;
                border: 2px solid rgba(0, 255, 255, 100);
            }
        """)
        
        header_layout = QHBoxLayout()
        header_layout.setContentsMargins(30, 20, 30, 20)
        
        # 로고 및 제목
        title_layout = QVBoxLayout()
        
        self.title_label = QLabel("INVARIANT")
        self.title_label.setFont(QFont("Segoe UI", 32, QFont.Bold))
        self.title_label.setStyleSheet("""
            QLabel {
                color: rgba(255, 255, 255, 250);
                background: transparent;
                letter-spacing: 5px;
            }
        """)
        
        self.subtitle_label = QLabel("MASTER PROJECT HUB")
        self.subtitle_label.setFont(PremiumStyle.HEADING_FONT)
        self.subtitle_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 255, 200);
                background: transparent;
                letter-spacing: 2px;
            }
        """)
        
        title_layout.addWidget(self.title_label)
        title_layout.addWidget(self.subtitle_label)
        
        # 상태 정보
        status_layout = QVBoxLayout()
        status_layout.setAlignment(Qt.AlignRight)
        
        self.status_label = QLabel("SYSTEM STATUS: OPERATIONAL")
        self.status_label.setFont(PremiumStyle.NORMAL_FONT)
        self.status_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 128, 200);
                background: transparent;
            }
        """)
        
        self.version_label = QLabel("v2.0.0 PREMIUM")
        self.version_label.setFont(PremiumStyle.SMALL_FONT)
        self.version_label.setStyleSheet("""
            QLabel {
                color: rgba(200, 200, 220, 150);
                background: transparent;
            }
        """)
        
        status_layout.addWidget(self.status_label)
        status_layout.addWidget(self.version_label)
        
        header_layout.addLayout(title_layout)
        header_layout.addStretch()
        header_layout.addLayout(status_layout)
        
        header_frame.setLayout(header_layout)
        layout.addWidget(header_frame)
        
    def setup_project_grid(self, layout):
        """프로젝트 그리드 설정"""
        # 스크롤 영역
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        scroll_area.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
        scroll_area.setStyleSheet("""
            QScrollArea {
                background: transparent;
                border: none;
            }
            QScrollBar:vertical {
                background: rgba(20, 20, 45, 200);
                width: 12px;
                border-radius: 6px;
            }
            QScrollBar::handle:vertical {
                background: rgba(0, 255, 255, 150);
                border-radius: 6px;
                min-height: 20px;
            }
            QScrollBar::handle:vertical:hover {
                background: rgba(0, 255, 255, 200);
            }
        """)
        
        # 그리드 위젯
        grid_widget = QWidget()
        self.grid_layout = QGridLayout()
        self.grid_layout.setSpacing(20)
        self.grid_layout.setContentsMargins(20, 20, 20, 20)
        
        # 프로젝트 카드 생성
        self.create_project_cards()
        
        grid_widget.setLayout(self.grid_layout)
        scroll_area.setWidget(grid_widget)
        
        layout.addWidget(scroll_area)
        
    def create_project_cards(self):
        """프로젝트 카드 생성"""
        projects = [
            {"name": "Project 1", "description": "AI-Powered Automation System", "version": "1.2.0"},
            {"name": "Project 2", "description": "Advanced Data Analytics Platform", "version": "2.1.0"},
            {"name": "Project 3", "description": "Real-time Communication Hub", "version": "1.5.0"},
            {"name": "Project 4", "description": "Intelligent UI Agent System", "version": "1.0.0"},
            {"name": "Project 5", "description": "Blockchain Integration Suite", "version": "3.0.0"},
            {"name": "Project 6", "description": "Machine Learning Framework", "version": "2.3.0"},
            {"name": "Project 7", "description": "Cloud Infrastructure Manager", "version": "1.8.0"},
            {"name": "Project 8", "description": "Security & Monitoring System", "version": "2.0.0"}
        ]
        
        for i, project in enumerate(projects):
            card = PremiumProjectCard(project)
            row = i // 4
            col = i % 4
            self.grid_layout.addWidget(card, row, col)
            
    def setup_control_panel(self, layout):
        """컨트롤 패널 설정"""
        control_frame = QFrame()
        control_frame.setFixedHeight(80)
        control_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                    stop:0 rgba(20, 20, 45, 200),
                    stop:1 rgba(25, 25, 55, 200));
                border-radius: 15px;
                border: 1px solid rgba(0, 255, 255, 50);
            }
        """)
        
        control_layout = QHBoxLayout()
        control_layout.setContentsMargins(30, 15, 30, 15)
        control_layout.setSpacing(20)
        
        # 컨트롤 버튼들
        buttons = [
            ("DEPLOY", PremiumStyle.NEON_GREEN),
            ("UPDATE", PremiumStyle.NEON_BLUE),
            ("CONFIGURE", PremiumStyle.NEON_PURPLE),
            ("STATUS", PremiumStyle.NEON_CYAN),
            ("TERMINATE", PremiumStyle.NEON_RED)
        ]
        
        for text, color in buttons:
            btn = self.create_premium_button(text, color)
            control_layout.addWidget(btn)
            
        control_layout.addStretch()
        
        control_frame.setLayout(control_layout)
        layout.addWidget(control_frame)
        
    def create_premium_button(self, text, color):
        """프리미엄 버튼 생성"""
        btn = QPushButton(text)
        btn.setFixedSize(120, 50)
        btn.setFont(PremiumStyle.NORMAL_FONT)
        btn.setCursor(Qt.PointingHandCursor)
        
        # 버튼 스타일
        btn.setStyleSheet(f"""
            QPushButton {{
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba({color.red()}, {color.green()}, {color.blue()}, 50),
                    stop:1 rgba({color.red()}, {color.green()}, {color.blue()}, 30));
                border: 2px solid rgba({color.red()}, {color.green()}, {color.blue()}, 150);
                border-radius: 25px;
                color: rgba(255, 255, 255, 220);
                font-weight: bold;
            }}
            QPushButton:hover {{
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba({color.red()}, {color.green()}, {color.blue()}, 100),
                    stop:1 rgba({color.red()}, {color.green()}, {color.blue()}, 70));
                border: 2px solid rgba({color.red()}, {color.green()}, {color.blue()}, 200);
            }}
            QPushButton:pressed {{
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba({color.red()}, {color.green()}, {color.blue()}, 150),
                    stop:1 rgba({color.red()}, {color.green()}, {color.blue()}, 100));
            }}
        """)
        
        # 그림자 효과
        shadow = QGraphicsDropShadowEffect()
        shadow.setBlurRadius(15)
        shadow.setColor(color)
        shadow.setOffset(0, 3)
        btn.setGraphicsEffect(shadow)
        
        # 클릭 이벤트 연결
        btn.clicked.connect(lambda: self.on_button_click(text))
        
        return btn
        
    def setup_animations(self):
        """애니메이션 설정"""
        # 윈도우 페이드 인
        self.fade_in = QPropertyAnimation(self, b"windowOpacity")
        self.fade_in.setDuration(1500)
        self.fade_in.setStartValue(0.0)
        self.fade_in.setEndValue(1.0)
        self.fade_in.setEasingCurve(QEasingCurve.OutCubic)
        
        # 카드 등장 애니메이션
        self.card_animations = []
        
    def show_welcome_screen(self):
        """웰컴 화면 표시"""
        self.welcome_screen = WelcomeScreen()
        self.welcome_screen.show()
        self.welcome_screen.start_animations()
        
        # 5초 후 메인 윈도우 표시
        QTimer.singleShot(5000, self.show_main_window)
        
    def show_main_window(self):
        """메인 윈도우 표시"""
        if self.welcome_screen:
            self.welcome_screen.close()
            self.welcome_screen = None
            
        self.show()
        self.fade_in.start()
        
        # 카드 등장 애니메이션
        self.animate_cards()
        
    def animate_cards(self):
        """카드 등장 애니메이션"""
        for i in range(self.grid_layout.count()):
            widget = self.grid_layout.itemAt(i).widget()
            if isinstance(widget, PremiumProjectCard):
                # 지연된 등장 애니메이션
                QTimer.singleShot(i * 100, lambda w=widget: self.animate_card(w))
                
    def animate_card(self, card):
        """개별 카드 애니메이션"""
        # 초기 상태 (투명하고 작게)
        card.setWindowOpacity(0.0)
        card.setGeometry(card.x(), card.y() + 50, card.width(), card.height())
        
        # 페이드 인 및 위치 애니메이션
        fade_anim = QPropertyAnimation(card, b"windowOpacity")
        fade_anim.setDuration(800)
        fade_anim.setStartValue(0.0)
        fade_anim.setEndValue(1.0)
        fade_anim.setEasingCurve(QEasingCurve.OutCubic)
        
        pos_anim = QPropertyAnimation(card, b"geometry")
        pos_anim.setDuration(800)
        pos_anim.setStartValue(QRect(card.x(), card.y() + 50, card.width(), card.height()))
        pos_anim.setEndValue(QRect(card.x(), card.y(), card.width(), card.height()))
        pos_anim.setEasingCurve(QEasingCurve.OutBack)
        
        # 병렬 실행
        group = QParallelAnimationGroup()
        group.addAnimation(fade_anim)
        group.addAnimation(pos_anim)
        group.start()
        
    def on_button_click(self, button_text):
        """버튼 클릭 이벤트"""
        if button_text == "DEPLOY":
            QMessageBox.information(self, "Deploy", "Deploying selected projects...")
        elif button_text == "UPDATE":
            QMessageBox.information(self, "Update", "Checking for updates...")
        elif button_text == "CONFIGURE":
            QMessageBox.information(self, "Configure", "Opening configuration panel...")
        elif button_text == "STATUS":
            QMessageBox.information(self, "Status", "System status: All systems operational")
        elif button_text == "TERMINATE":
            self.close()

def main():
    """메인 함수"""
    app = QApplication(sys.argv)
    app.setApplicationName("Invariant Premium")
    app.setApplicationVersion("2.0.0")
    
    # 어두운 테마 설정
    app.setStyle('Fusion')
    
    # 윈도우 생성 및 표시
    window = InvariantPremium()
    
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
