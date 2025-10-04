#!/usr/bin/env python3
"""
Invariant Dashboard - 실시간 모니터링 대시보드
"""

import sys
import os
import json
import time
import threading
import psutil
import socket
import subprocess
from pathlib import Path
from datetime import datetime
import webbrowser

from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                            QHBoxLayout, QGridLayout, QLabel, QPushButton, 
                            QFrame, QScrollArea, QProgressBar, QTextEdit,
                            QMessageBox, QTabWidget, QSplitter, QGroupBox)
from PyQt5.QtCore import (Qt, QTimer, QThread, pyqtSignal, QPropertyAnimation, 
                         QEasingCurve, QRect, QPoint, QSize, QParallelAnimationGroup,
                         QSequentialAnimationGroup, QVariantAnimation, QRectF)
from PyQt5.QtGui import (QFont, QPalette, QColor, QIcon, QPixmap, QPainter, 
                        QPen, QBrush, QLinearGradient, QRadialGradient, QFontDatabase,
                        QPainterPath)

class SystemMonitor(QThread):
    """시스템 모니터링"""
    
    data_updated = pyqtSignal(dict)
    
    def __init__(self):
        super().__init__()
        self.running = True
        
    def run(self):
        """데이터 수집"""
        while self.running:
            try:
                # CPU 사용률
                cpu_percent = psutil.cpu_percent(interval=0.1)
                cpu_count = psutil.cpu_count()
                
                # 메모리 사용률
                memory = psutil.virtual_memory()
                memory_percent = memory.percent
                memory_used = memory.used / (1024**3)  # GB
                memory_total = memory.total / (1024**3)  # GB
                
                # 디스크 사용률
                disk = psutil.disk_usage('/')
                disk_percent = (disk.used / disk.total) * 100
                disk_used = disk.used / (1024**3)  # GB
                disk_total = disk.total / (1024**3)  # GB
                
                # 네트워크
                network = psutil.net_io_counters()
                network_sent = network.bytes_sent / (1024**2)  # MB
                network_recv = network.bytes_recv / (1024**2)  # MB
                
                # 시스템 정보
                boot_time = datetime.fromtimestamp(psutil.boot_time())
                uptime = datetime.now() - boot_time
                
                # IP 주소
                try:
                    hostname = socket.gethostname()
                    local_ip = socket.gethostbyname(hostname)
                except:
                    local_ip = "Unknown"
                
                # 데이터 패키징
                data = {
                    'cpu_percent': cpu_percent,
                    'cpu_count': cpu_count,
                    'memory_percent': memory_percent,
                    'memory_used': memory_used,
                    'memory_total': memory_total,
                    'disk_percent': disk_percent,
                    'disk_used': disk_used,
                    'disk_total': disk_total,
                    'network_sent': network_sent,
                    'network_recv': network_recv,
                    'uptime': str(uptime).split('.')[0],
                    'local_ip': local_ip,
                    'timestamp': datetime.now().strftime('%H:%M:%S')
                }
                
                self.data_updated.emit(data)
                time.sleep(0.1)  # 100ms 업데이트
                
            except Exception as e:
                print(f"Monitoring error: {e}")
                time.sleep(1)
                
    def stop(self):
        """모니터링 중지"""
        self.running = False

class CircularGauge(QWidget):
    """원형 게이지"""
    
    def __init__(self, title="", max_value=100, parent=None):
        super().__init__(parent)
        self.title = title
        self.max_value = max_value
        self.current_value = 0
        self.target_value = 0
        self.setFixedSize(200, 200)
        
        # 애니메이션 설정
        self.animation = QPropertyAnimation(self, b"current_value")
        self.animation.setDuration(300)
        self.animation.setEasingCurve(QEasingCurve.OutCubic)
        
    def set_value(self, value):
        """값 설정 (애니메이션 포함)"""
        self.target_value = min(max(value, 0), self.max_value)
        self.animation.setStartValue(self.current_value)
        self.animation.setEndValue(self.target_value)
        self.animation.start()
        
    def paintEvent(self, event):
        """그리기 이벤트"""
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)
        
        # 배경 원
        center = QPoint(100, 100)
        radius = 80
        
        # 배경 그라데이션
        bg_gradient = QRadialGradient(center, radius)
        bg_gradient.setColorAt(0, QColor(20, 20, 45, 200))
        bg_gradient.setColorAt(1, QColor(10, 10, 25, 150))
        
        painter.setBrush(QBrush(bg_gradient))
        painter.setPen(QPen(QColor(0, 255, 255, 100), 3))
        painter.drawEllipse(center.x() - radius, center.y() - radius, 
                           radius * 2, radius * 2)
        
        # 진행률 호
        progress_angle = int((self.current_value / self.max_value) * 360)
        
        # 진행률 그라데이션
        progress_gradient = QRadialGradient(center, radius)
        if self.current_value < 50:
            progress_gradient.setColorAt(0, QColor(0, 255, 128, 200))
            progress_gradient.setColorAt(1, QColor(0, 255, 128, 100))
        elif self.current_value < 80:
            progress_gradient.setColorAt(0, QColor(255, 255, 0, 200))
            progress_gradient.setColorAt(1, QColor(255, 255, 0, 100))
        else:
            progress_gradient.setColorAt(0, QColor(255, 64, 64, 200))
            progress_gradient.setColorAt(1, QColor(255, 64, 64, 100))
        
        painter.setBrush(QBrush(progress_gradient))
        painter.setPen(QPen(QColor(255, 255, 255, 150), 4))
        
        # 호 그리기
        path = QPainterPath()
        path.moveTo(center)
        path.arcTo(center.x() - radius, center.y() - radius, 
                  radius * 2, radius * 2, 90, -progress_angle)
        path.lineTo(center)
        painter.drawPath(path)
        
        # 중앙 텍스트
        painter.setPen(QPen(QColor(255, 255, 255, 220), 2))
        painter.setFont(QFont("Segoe UI", 24, QFont.Bold))
        painter.drawText(center.x() - 30, center.y() - 10, 
                        f"{int(self.current_value)}%")
        
        # 제목
        painter.setFont(QFont("Segoe UI", 12))
        painter.drawText(center.x() - 40, center.y() + 30, self.title)

class LinearGauge(QWidget):
    """선형 게이지"""
    
    def __init__(self, title="", max_value=100, parent=None):
        super().__init__(parent)
        self.title = title
        self.max_value = max_value
        self.current_value = 0
        self.target_value = 0
        self.setFixedSize(300, 60)
        
        # 애니메이션 설정
        self.animation = QPropertyAnimation(self, b"current_value")
        self.animation.setDuration(300)
        self.animation.setEasingCurve(QEasingCurve.OutCubic)
        
    def set_value(self, value):
        """값 설정 (애니메이션 포함)"""
        self.target_value = min(max(value, 0), self.max_value)
        self.animation.setStartValue(self.current_value)
        self.animation.setEndValue(self.target_value)
        self.animation.start()
        
    def paintEvent(self, event):
        """그리기 이벤트"""
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)
        
        # 배경
        bg_rect = QRect(10, 20, 280, 20)
        painter.setBrush(QBrush(QColor(20, 20, 45, 200)))
        painter.setPen(QPen(QColor(0, 255, 255, 100), 2))
        painter.drawRoundedRect(bg_rect, 10, 10)
        
        # 진행률
        progress_width = int((self.current_value / self.max_value) * 260)
        progress_rect = QRect(20, 22, progress_width, 16)
        
        # 진행률 그라데이션
        progress_gradient = QLinearGradient(20, 22, 20 + progress_width, 22)
        if self.current_value < 50:
            progress_gradient.setColorAt(0, QColor(0, 255, 128, 200))
            progress_gradient.setColorAt(1, QColor(0, 255, 128, 100))
        elif self.current_value < 80:
            progress_gradient.setColorAt(0, QColor(255, 255, 0, 200))
            progress_gradient.setColorAt(1, QColor(255, 255, 0, 100))
        else:
            progress_gradient.setColorAt(0, QColor(255, 64, 64, 200))
            progress_gradient.setColorAt(1, QColor(255, 64, 64, 100))
        
        painter.setBrush(QBrush(progress_gradient))
        painter.setPen(Qt.NoPen)
        painter.drawRoundedRect(progress_rect, 8, 8)
        
        # 텍스트
        painter.setPen(QPen(QColor(255, 255, 255, 220), 2))
        painter.setFont(QFont("Segoe UI", 10))
        painter.drawText(10, 15, self.title)
        painter.drawText(250, 15, f"{int(self.current_value)}%")

class SystemInfoPanel(QWidget):
    """시스템 정보"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()
        
    def setup_ui(self):
        """UI"""
        layout = QVBoxLayout()
        layout.setSpacing(15)
        layout.setContentsMargins(20, 20, 20, 20)
        
        # 제목
        title_label = QLabel("SYSTEM STATUS")
        title_label.setFont(QFont("Segoe UI", 16, QFont.Bold))
        title_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 255, 200);
                background: transparent;
                padding: 10px;
            }
        """)
        layout.addWidget(title_label)
        
        # 정보 그리드
        info_grid = QGridLayout()
        info_grid.setSpacing(10)
        
        # 시스템 정보 라벨들
        self.info_labels = {}
        info_items = [
            ("IP Address", "local_ip"),
            ("Uptime", "uptime"),
            ("CPU Cores", "cpu_count"),
            ("Memory Total", "memory_total"),
            ("Disk Total", "disk_total"),
            ("Last Update", "timestamp")
        ]
        
        for i, (label, key) in enumerate(info_items):
            # 라벨
            label_widget = QLabel(f"{label}:")
            label_widget.setFont(QFont("Segoe UI", 10))
            label_widget.setStyleSheet("color: rgba(200, 200, 220, 150);")
            
            # 값
            value_widget = QLabel("Loading...")
            value_widget.setFont(QFont("Segoe UI", 10, QFont.Bold))
            value_widget.setStyleSheet("color: rgba(255, 255, 255, 200);")
            
            info_grid.addWidget(label_widget, i, 0)
            info_grid.addWidget(value_widget, i, 1)
            
            self.info_labels[key] = value_widget
            
        layout.addLayout(info_grid)
        layout.addStretch()
        
        self.setLayout(layout)
        
        # 스타일
        self.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(20, 20, 45, 200),
                    stop:1 rgba(25, 25, 55, 200));
                border-radius: 15px;
                border: 1px solid rgba(0, 255, 255, 50);
            }
        """)

class InvariantDashboard(QMainWindow):
    """메인 윈도우"""
    
    def __init__(self):
        super().__init__()
        self.monitor = SystemMonitor()
        self.setup_ui()
        self.setup_monitoring()
        self.setup_animations()
        
    def setup_ui(self):
        """UI"""
        self.setWindowTitle("Invariant Dashboard - Real-time Monitoring")
        self.setMinimumSize(1400, 900)
        self.resize(1600, 1000)
        
        # 중앙 위젯
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # 메인 레이아웃
        main_layout = QHBoxLayout()
        main_layout.setSpacing(20)
        main_layout.setContentsMargins(20, 20, 20, 20)
        
        # 왼쪽 패널 (모니터링)
        self.setup_monitoring_panel(main_layout)
        
        # 오른쪽 패널 (프로젝트 관리)
        self.setup_project_panel(main_layout)
        
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
        
    def setup_monitoring_panel(self, layout):
        """모니터링 패널"""
        # 왼쪽 스플리터
        left_splitter = QSplitter(Qt.Vertical)
        
        # 상단: 원형 게이지들
        gauges_frame = QFrame()
        gauges_frame.setFixedHeight(300)
        gauges_layout = QHBoxLayout()
        gauges_layout.setSpacing(20)
        
        # CPU 게이지
        self.cpu_gauge = CircularGauge("CPU", 100)
        gauges_layout.addWidget(self.cpu_gauge)
        
        # 메모리 게이지
        self.memory_gauge = CircularGauge("Memory", 100)
        gauges_layout.addWidget(self.memory_gauge)
        
        # 디스크 게이지
        self.disk_gauge = CircularGauge("Disk", 100)
        gauges_layout.addWidget(self.disk_gauge)
        
        gauges_frame.setLayout(gauges_layout)
        gauges_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(20, 20, 45, 200),
                    stop:1 rgba(25, 25, 55, 200));
                border-radius: 15px;
                border: 1px solid rgba(0, 255, 255, 50);
            }
        """)
        
        # 중간: 선형 게이지들
        linear_frame = QFrame()
        linear_frame.setFixedHeight(200)
        linear_layout = QVBoxLayout()
        linear_layout.setSpacing(15)
        
        # 네트워크 게이지들
        self.network_sent_gauge = LinearGauge("Network Sent (MB)", 1000)
        self.network_recv_gauge = LinearGauge("Network Received (MB)", 1000)
        
        linear_layout.addWidget(self.network_sent_gauge)
        linear_layout.addWidget(self.network_recv_gauge)
        
        linear_frame.setLayout(linear_layout)
        linear_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(20, 20, 45, 200),
                    stop:1 rgba(25, 25, 55, 200));
                border-radius: 15px;
                border: 1px solid rgba(0, 255, 255, 50);
            }
        """)
        
        # 하단: 시스템 정보
        self.system_info = SystemInfoPanel()
        
        # 스플리터에 추가
        left_splitter.addWidget(gauges_frame)
        left_splitter.addWidget(linear_frame)
        left_splitter.addWidget(self.system_info)
        left_splitter.setSizes([300, 200, 300])
        
        layout.addWidget(left_splitter)
        
    def setup_project_panel(self, layout):
        """프로젝트 패널"""
        # 오른쪽 패널
        project_frame = QFrame()
        project_frame.setFixedWidth(400)
        project_layout = QVBoxLayout()
        project_layout.setSpacing(20)
        
        # 제목
        title_label = QLabel("PROJECT MANAGEMENT")
        title_label.setFont(QFont("Segoe UI", 18, QFont.Bold))
        title_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 255, 200);
                background: transparent;
                padding: 15px;
            }
        """)
        project_layout.addWidget(title_label)
        
        # 프로젝트 리스트
        self.project_list = QScrollArea()
        self.project_list.setWidgetResizable(True)
        self.project_list.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.project_list.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
        self.project_list.setStyleSheet("""
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
        
        # 프로젝트 위젯
        project_widget = QWidget()
        self.project_layout = QVBoxLayout()
        self.project_layout.setSpacing(10)
        
        # 프로젝트 카드들 생성
        self.create_project_cards()
        
        project_widget.setLayout(self.project_layout)
        self.project_list.setWidget(project_widget)
        
        project_layout.addWidget(self.project_list)
        
        # 컨트롤 버튼들
        control_frame = QFrame()
        control_frame.setFixedHeight(100)
        control_layout = QHBoxLayout()
        control_layout.setSpacing(10)
        
        # 버튼들
        buttons = [
            ("DEPLOY", QColor(0, 255, 128)),
            ("UPDATE", QColor(64, 128, 255)),
            ("CONFIGURE", QColor(128, 64, 255)),
            ("STATUS", QColor(0, 255, 255))
        ]
        
        for text, color in buttons:
            btn = self.create_button(text, color)
            control_layout.addWidget(btn)
            
        control_frame.setLayout(control_layout)
        control_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(20, 20, 45, 200),
                    stop:1 rgba(25, 25, 55, 200));
                border-radius: 15px;
                border: 1px solid rgba(0, 255, 255, 50);
            }
        """)
        
        project_layout.addWidget(control_frame)
        
        project_frame.setLayout(project_layout)
        project_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(20, 20, 45, 200),
                    stop:1 rgba(25, 25, 55, 200));
                border-radius: 20px;
                border: 2px solid rgba(0, 255, 255, 100);
            }
        """)
        
        layout.addWidget(project_frame)
        
    def create_project_cards(self):
        """프로젝트 카드"""
        projects = [
            {"name": "Project 1", "status": "Online", "version": "1.2.0"},
            {"name": "Project 2", "status": "Online", "version": "2.1.0"},
            {"name": "Project 3", "status": "Offline", "version": "1.5.0"},
            {"name": "Project 4", "status": "Online", "version": "1.0.0"},
            {"name": "Project 5", "status": "Online", "version": "3.0.0"},
            {"name": "Project 6", "status": "Online", "version": "2.3.0"},
            {"name": "Project 7", "status": "Offline", "version": "1.8.0"},
            {"name": "Project 8", "status": "Online", "version": "2.0.0"}
        ]
        
        for project in projects:
            card = self.create_project_card(project)
            self.project_layout.addWidget(card)
            
    def create_project_card(self, project):
        """프로젝트 카드"""
        card = QFrame()
        card.setFixedHeight(80)
        card.setCursor(Qt.PointingHandCursor)
        
        layout = QHBoxLayout()
        layout.setContentsMargins(15, 10, 15, 10)
        layout.setSpacing(15)
        
        # 아이콘
        icon_label = QLabel("⚡")
        icon_label.setFont(QFont("Segoe UI", 20))
        icon_label.setFixedSize(40, 40)
        icon_label.setAlignment(Qt.AlignCenter)
        icon_label.setStyleSheet("""
            QLabel {
                background: qradialgradient(cx:0.5, cy:0.5, radius:1.0,
                    stop:0 rgba(64, 128, 255, 100),
                    stop:1 rgba(128, 64, 255, 50));
                border-radius: 20px;
                border: 1px solid rgba(0, 255, 255, 100);
            }
        """)
        
        # 정보
        info_layout = QVBoxLayout()
        info_layout.setSpacing(5)
        
        name_label = QLabel(project["name"])
        name_label.setFont(QFont("Segoe UI", 12, QFont.Bold))
        name_label.setStyleSheet("color: rgba(255, 255, 255, 220);")
        
        version_label = QLabel(f"v{project['version']}")
        version_label.setFont(QFont("Segoe UI", 10))
        version_label.setStyleSheet("color: rgba(200, 200, 220, 150);")
        
        info_layout.addWidget(name_label)
        info_layout.addWidget(version_label)
        
        # 상태
        status_color = QColor(0, 255, 128) if project["status"] == "Online" else QColor(255, 64, 64)
        status_label = QLabel(project["status"])
        status_label.setFont(QFont("Segoe UI", 10, QFont.Bold))
        status_label.setStyleSheet(f"""
            QLabel {{
                color: rgba({status_color.red()}, {status_color.green()}, {status_color.blue()}, 200);
                background: rgba({status_color.red()}, {status_color.green()}, {status_color.blue()}, 30);
                border-radius: 10px;
                padding: 5px 10px;
            }}
        """)
        
        layout.addWidget(icon_label)
        layout.addLayout(info_layout)
        layout.addStretch()
        layout.addWidget(status_label)
        
        card.setLayout(layout)
        
        # 카드 스타일
        card.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(30, 30, 65, 200),
                    stop:1 rgba(35, 35, 75, 200));
                border-radius: 10px;
                border: 1px solid rgba(0, 255, 255, 30);
            }
            QFrame:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(40, 40, 85, 220),
                    stop:1 rgba(45, 45, 95, 220));
                border: 1px solid rgba(0, 255, 255, 100);
            }
        """)
        
        return card
        
    def create_button(self, text, color):
        """버튼"""
        btn = QPushButton(text)
        btn.setFixedSize(80, 40)
        btn.setFont(QFont("Segoe UI", 10, QFont.Bold))
        btn.setCursor(Qt.PointingHandCursor)
        
        btn.setStyleSheet(f"""
            QPushButton {{
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba({color.red()}, {color.green()}, {color.blue()}, 50),
                    stop:1 rgba({color.red()}, {color.green()}, {color.blue()}, 30));
                border: 2px solid rgba({color.red()}, {color.green()}, {color.blue()}, 150);
                border-radius: 20px;
                color: rgba(255, 255, 255, 220);
            }}
            QPushButton:hover {{
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba({color.red()}, {color.green()}, {color.blue()}, 100),
                    stop:1 rgba({color.red()}, {color.green()}, {color.blue()}, 70));
                border: 2px solid rgba({color.red()}, {color.green()}, {color.blue()}, 200);
            }}
        """)
        
        btn.clicked.connect(lambda: self.on_button_click(text))
        return btn
        
    def setup_monitoring(self):
        """모니터링"""
        self.monitor.data_updated.connect(self.update_monitoring_data)
        self.monitor.start()
        
    def setup_animations(self):
        """애니메이션"""
        # 윈도우 페이드 인
        self.fade_in = QPropertyAnimation(self, b"windowOpacity")
        self.fade_in.setDuration(1000)
        self.fade_in.setStartValue(0.0)
        self.fade_in.setEndValue(1.0)
        self.fade_in.setEasingCurve(QEasingCurve.OutCubic)
        self.fade_in.start()
        
    def update_monitoring_data(self, data):
        """데이터 업데이트"""
        # 게이지 업데이트
        self.cpu_gauge.set_value(data['cpu_percent'])
        self.memory_gauge.set_value(data['memory_percent'])
        self.disk_gauge.set_value(data['disk_percent'])
        
        # 네트워크 게이지 업데이트 (0-1000MB 범위로 정규화)
        network_sent_percent = min(data['network_sent'] * 10, 1000)
        network_recv_percent = min(data['network_recv'] * 10, 1000)
        self.network_sent_gauge.set_value(network_sent_percent)
        self.network_recv_gauge.set_value(network_recv_percent)
        
        # 시스템 정보 업데이트
        self.system_info.info_labels['local_ip'].setText(data['local_ip'])
        self.system_info.info_labels['uptime'].setText(data['uptime'])
        self.system_info.info_labels['cpu_count'].setText(str(data['cpu_count']))
        self.system_info.info_labels['memory_total'].setText(f"{data['memory_total']:.1f} GB")
        self.system_info.info_labels['disk_total'].setText(f"{data['disk_total']:.1f} GB")
        self.system_info.info_labels['timestamp'].setText(data['timestamp'])
        
    def on_button_click(self, button_text):
        """버튼 클릭"""
        if button_text == "DEPLOY":
            QMessageBox.information(self, "Deploy", "Deploying selected projects...")
        elif button_text == "UPDATE":
            QMessageBox.information(self, "Update", "Checking for updates...")
        elif button_text == "CONFIGURE":
            QMessageBox.information(self, "Configure", "Opening configuration panel...")
        elif button_text == "STATUS":
            QMessageBox.information(self, "Status", "System status: All systems operational")
            
    def closeEvent(self, event):
        """윈도우 종료"""
        self.monitor.stop()
        self.monitor.wait()
        event.accept()

def main():
    """메인"""
    app = QApplication(sys.argv)
    app.setApplicationName("Invariant Dashboard")
    app.setApplicationVersion("2.0.0")
    
    # 어두운 테마 설정
    app.setStyle('Fusion')
    
    # 윈도우 생성 및 표시
    window = InvariantDashboard()
    window.show()
    
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
