#!/usr/bin/env python3
"""
Invariant Command - 군사 지휘 시스템 스타일 대시보드
3D 시각화, 실시간 모니터링, 고급 UI
"""

import sys
import os
import json
import time
import threading
import psutil
import socket
import subprocess
import math
from pathlib import Path
from datetime import datetime
import webbrowser

from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                            QHBoxLayout, QGridLayout, QLabel, QPushButton, 
                            QFrame, QScrollArea, QProgressBar, QTextEdit,
                            QMessageBox, QTabWidget, QSplitter, QGroupBox,
                            QGraphicsView, QGraphicsScene, QGraphicsItem)
from PyQt5.QtCore import (Qt, QTimer, QThread, pyqtSignal, QPropertyAnimation, 
                         QEasingCurve, QRect, QPoint, QSize, QParallelAnimationGroup,
                         QSequentialAnimationGroup, QVariantAnimation, QRectF,
                         QObject, QPointF)
from PyQt5.QtGui import (QFont, QPalette, QColor, QIcon, QPixmap, QPainter, 
                        QPen, QBrush, QLinearGradient, QRadialGradient, QFontDatabase,
                        QPainterPath, QTransform, QPolygonF)

class SystemMonitor(QThread):
    """시스템 모니터링"""
    
    data_updated = pyqtSignal(dict)
    
    def __init__(self):
        super().__init__()
        self.running = True
        self.last_network = None
        
    def run(self):
        """데이터 수집"""
        while self.running:
            try:
                # CPU 사용률
                cpu_percent = psutil.cpu_percent(interval=0.1)
                cpu_count = psutil.cpu_count()
                cpu_freq = psutil.cpu_freq()
                cpu_freq_current = cpu_freq.current if cpu_freq else 0
                
                # 메모리 사용률
                memory = psutil.virtual_memory()
                memory_percent = memory.percent
                memory_used = memory.used / (1024**3)
                memory_total = memory.total / (1024**3)
                
                # 디스크 사용률
                disk = psutil.disk_usage('/')
                disk_percent = (disk.used / disk.total) * 100
                disk_used = disk.used / (1024**3)
                disk_total = disk.total / (1024**3)
                
                # 네트워크 (속도 계산)
                network = psutil.net_io_counters()
                if self.last_network:
                    time_diff = 0.1  # 100ms
                    bytes_sent_diff = network.bytes_sent - self.last_network.bytes_sent
                    bytes_recv_diff = network.bytes_recv - self.last_network.bytes_recv
                    
                    network_sent_speed = (bytes_sent_diff / time_diff) / (1024**2)  # MB/s
                    network_recv_speed = (bytes_recv_diff / time_diff) / (1024**2)  # MB/s
                else:
                    network_sent_speed = 0
                    network_recv_speed = 0
                
                self.last_network = network
                
                # 시스템 정보
                boot_time = datetime.fromtimestamp(psutil.boot_time())
                uptime = datetime.now() - boot_time
                
                # IP 주소
                try:
                    hostname = socket.gethostname()
                    local_ip = socket.gethostbyname(hostname)
                except:
                    local_ip = "Unknown"
                
                # 프로세스 수
                process_count = len(psutil.pids())
                
                # 데이터 패키징
                data = {
                    'cpu_percent': cpu_percent,
                    'cpu_count': cpu_count,
                    'cpu_freq': cpu_freq_current,
                    'memory_percent': memory_percent,
                    'memory_used': memory_used,
                    'memory_total': memory_total,
                    'disk_percent': disk_percent,
                    'disk_used': disk_used,
                    'disk_total': disk_total,
                    'network_sent_speed': network_sent_speed,
                    'network_recv_speed': network_recv_speed,
                    'process_count': process_count,
                    'uptime': str(uptime).split('.')[0],
                    'local_ip': local_ip,
                    'timestamp': datetime.now().strftime('%H:%M:%S')
                }
                
                self.data_updated.emit(data)
                time.sleep(0.1)
                
            except Exception as e:
                print(f"Monitoring error: {e}")
                time.sleep(1)
                
    def stop(self):
        """모니터링 중지"""
        self.running = False

class AdvancedGauge(QWidget):
    """고급 게이지"""
    
    def __init__(self, title="", max_value=100, unit="%", parent=None):
        super().__init__(parent)
        self.title = title
        self.max_value = max_value
        self.unit = unit
        self.current_value = 0
        self.target_value = 0
        self.setFixedSize(200, 200)
        
        # 애니메이션
        self.animation = QPropertyAnimation(self, b"current_value")
        self.animation.setDuration(500)
        self.animation.setEasingCurve(QEasingCurve.OutCubic)
        
    def set_value(self, value):
        """값 설정"""
        self.target_value = min(max(value, 0), self.max_value)
        self.animation.setStartValue(self.current_value)
        self.animation.setEndValue(self.target_value)
        self.animation.start()
        
    def paintEvent(self, event):
        """그리기"""
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)
        
        center = QPoint(100, 100)
        radius = 80
        
        # 배경 원
        bg_gradient = QRadialGradient(center, radius)
        bg_gradient.setColorAt(0, QColor(10, 20, 30, 200))
        bg_gradient.setColorAt(1, QColor(5, 10, 15, 150))
        
        painter.setBrush(QBrush(bg_gradient))
        painter.setPen(QPen(QColor(0, 255, 100, 100), 2))
        painter.drawEllipse(center.x() - radius, center.y() - radius, 
                           radius * 2, radius * 2)
        
        # 진행률 호
        progress_angle = int((self.current_value / self.max_value) * 270)  # 270도
        
        # 진행률 그라데이션
        progress_gradient = QRadialGradient(center, radius)
        if self.current_value < 30:
            progress_gradient.setColorAt(0, QColor(0, 255, 100, 200))
            progress_gradient.setColorAt(1, QColor(0, 255, 100, 100))
        elif self.current_value < 70:
            progress_gradient.setColorAt(0, QColor(255, 255, 0, 200))
            progress_gradient.setColorAt(1, QColor(255, 255, 0, 100))
        else:
            progress_gradient.setColorAt(0, QColor(255, 50, 50, 200))
            progress_gradient.setColorAt(1, QColor(255, 50, 50, 100))
        
        painter.setBrush(QBrush(progress_gradient))
        painter.setPen(QPen(QColor(255, 255, 255, 200), 3))
        
        # 호 그리기 (시작 각도 225도)
        path = QPainterPath()
        path.moveTo(center)
        path.arcTo(center.x() - radius, center.y() - radius, 
                  radius * 2, radius * 2, 225, -progress_angle)
        path.lineTo(center)
        painter.drawPath(path)
        
        # 중앙 텍스트
        painter.setPen(QPen(QColor(255, 255, 255, 250), 2))
        painter.setFont(QFont("Consolas", 20, QFont.Bold))
        painter.drawText(center.x() - 40, center.y() - 5, 
                        f"{int(self.current_value)}{self.unit}")
        
        # 제목
        painter.setFont(QFont("Consolas", 10))
        painter.setPen(QPen(QColor(0, 255, 100, 200), 1))
        painter.drawText(center.x() - 50, center.y() + 30, self.title)

class SystemStatusPanel(QWidget):
    """시스템 상태 패널"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()
        
    def setup_ui(self):
        """UI"""
        layout = QVBoxLayout()
        layout.setSpacing(10)
        layout.setContentsMargins(15, 15, 15, 15)
        
        # 제목
        title_label = QLabel("SYSTEM STATUS")
        title_label.setFont(QFont("Consolas", 12, QFont.Bold))
        title_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 100, 200);
                background: transparent;
                padding: 5px;
            }
        """)
        layout.addWidget(title_label)
        
        # 상태 그리드
        self.status_grid = QGridLayout()
        self.status_grid.setSpacing(8)
        
        # 상태 라벨들
        self.status_labels = {}
        status_items = [
            ("IP", "local_ip"),
            ("Uptime", "uptime"),
            ("CPU Cores", "cpu_count"),
            ("Processes", "process_count"),
            ("Memory", "memory_total"),
            ("Disk", "disk_total")
        ]
        
        for i, (label, key) in enumerate(status_items):
            # 라벨
            label_widget = QLabel(f"{label}:")
            label_widget.setFont(QFont("Consolas", 9))
            label_widget.setStyleSheet("color: rgba(150, 150, 150, 200);")
            
            # 값
            value_widget = QLabel("--")
            value_widget.setFont(QFont("Consolas", 9, QFont.Bold))
            value_widget.setStyleSheet("color: rgba(255, 255, 255, 220);")
            
            self.status_grid.addWidget(label_widget, i, 0)
            self.status_grid.addWidget(value_widget, i, 1)
            
            self.status_labels[key] = value_widget
            
        layout.addLayout(self.status_grid)
        layout.addStretch()
        
        self.setLayout(layout)
        
        # 스타일
        self.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(10, 20, 30, 200),
                    stop:1 rgba(5, 10, 15, 200));
                border-radius: 10px;
                border: 1px solid rgba(0, 255, 100, 50);
            }
        """)

class ProjectCard(QWidget):
    """프로젝트 카드"""
    
    def __init__(self, project_data, parent=None):
        super().__init__(parent)
        self.project_data = project_data
        self.setup_ui()
        
    def setup_ui(self):
        """UI"""
        self.setFixedSize(300, 100)
        self.setCursor(Qt.PointingHandCursor)
        
        layout = QHBoxLayout()
        layout.setContentsMargins(15, 10, 15, 10)
        layout.setSpacing(15)
        
        # 아이콘
        icon_label = QLabel("⚡")
        icon_label.setFont(QFont("Segoe UI", 24))
        icon_label.setFixedSize(50, 50)
        icon_label.setAlignment(Qt.AlignCenter)
        icon_label.setStyleSheet("""
            QLabel {
                background: qradialgradient(cx:0.5, cy:0.5, radius:1.0,
                    stop:0 rgba(0, 255, 100, 100),
                    stop:1 rgba(0, 255, 100, 30));
                border-radius: 25px;
                border: 2px solid rgba(0, 255, 100, 150);
            }
        """)
        
        # 정보
        info_layout = QVBoxLayout()
        info_layout.setSpacing(5)
        
        name_label = QLabel(self.project_data["name"])
        name_label.setFont(QFont("Consolas", 12, QFont.Bold))
        name_label.setStyleSheet("color: rgba(255, 255, 255, 250);")
        
        version_label = QLabel(f"v{self.project_data['version']}")
        version_label.setFont(QFont("Consolas", 10))
        version_label.setStyleSheet("color: rgba(150, 150, 150, 200);")
        
        info_layout.addWidget(name_label)
        info_layout.addWidget(version_label)
        
        # 상태
        status_color = QColor(0, 255, 100) if self.project_data["status"] == "Online" else QColor(255, 50, 50)
        status_label = QLabel(self.project_data["status"])
        status_label.setFont(QFont("Consolas", 10, QFont.Bold))
        status_label.setStyleSheet(f"""
            QLabel {{
                color: rgba({status_color.red()}, {status_color.green()}, {status_color.blue()}, 250);
                background: rgba({status_color.red()}, {status_color.green()}, {status_color.blue()}, 30);
                border-radius: 8px;
                padding: 5px 10px;
                border: 1px solid rgba({status_color.red()}, {status_color.green()}, {status_color.blue()}, 100);
            }}
        """)
        
        layout.addWidget(icon_label)
        layout.addLayout(info_layout)
        layout.addStretch()
        layout.addWidget(status_label)
        
        self.setLayout(layout)
        
        # 카드 스타일
        self.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(20, 30, 40, 200),
                    stop:1 rgba(10, 15, 20, 200));
                border-radius: 10px;
                border: 1px solid rgba(0, 255, 100, 30);
            }
            QWidget:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(30, 40, 50, 220),
                    stop:1 rgba(20, 25, 30, 220));
                border: 2px solid rgba(0, 255, 100, 100);
            }
        """)

class InvariantCommand(QMainWindow):
    """메인 윈도우"""
    
    def __init__(self):
        super().__init__()
        self.monitor = SystemMonitor()
        self.setup_ui()
        self.setup_monitoring()
        self.setup_animations()
        
    def setup_ui(self):
        """UI"""
        self.setWindowTitle("Invariant Command - Military Control System")
        self.setMinimumSize(1600, 1000)
        self.resize(1800, 1200)
        
        # 중앙 위젯
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # 메인 레이아웃
        main_layout = QHBoxLayout()
        main_layout.setSpacing(20)
        main_layout.setContentsMargins(20, 20, 20, 20)
        
        # 왼쪽 패널 (모니터링)
        self.setup_monitoring_panel(main_layout)
        
        # 중앙 패널 (3D 시각화)
        self.setup_visualization_panel(main_layout)
        
        # 오른쪽 패널 (프로젝트 관리)
        self.setup_project_panel(main_layout)
        
        central_widget.setLayout(main_layout)
        
        # 윈도우 스타일
        self.setStyleSheet("""
            QMainWindow {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(5, 10, 15, 255),
                    stop:0.5 rgba(10, 20, 30, 255),
                    stop:1 rgba(15, 30, 45, 255));
            }
        """)
        
    def setup_monitoring_panel(self, layout):
        """모니터링 패널"""
        # 왼쪽 패널
        left_panel = QFrame()
        left_panel.setFixedWidth(400)
        left_layout = QVBoxLayout()
        left_layout.setSpacing(20)
        
        # 제목
        title_label = QLabel("SYSTEM MONITORING")
        title_label.setFont(QFont("Consolas", 16, QFont.Bold))
        title_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 100, 250);
                background: transparent;
                padding: 15px;
            }
        """)
        left_layout.addWidget(title_label)
        
        # 게이지들
        gauges_frame = QFrame()
        gauges_layout = QGridLayout()
        gauges_layout.setSpacing(15)
        
        # CPU 게이지
        self.cpu_gauge = AdvancedGauge("CPU", 100, "%")
        gauges_layout.addWidget(self.cpu_gauge, 0, 0)
        
        # 메모리 게이지
        self.memory_gauge = AdvancedGauge("MEMORY", 100, "%")
        gauges_layout.addWidget(self.memory_gauge, 0, 1)
        
        # 디스크 게이지
        self.disk_gauge = AdvancedGauge("DISK", 100, "%")
        gauges_layout.addWidget(self.disk_gauge, 1, 0)
        
        # 네트워크 게이지
        self.network_gauge = AdvancedGauge("NETWORK", 100, "MB/s")
        gauges_layout.addWidget(self.network_gauge, 1, 1)
        
        gauges_frame.setLayout(gauges_layout)
        gauges_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(10, 20, 30, 200),
                    stop:1 rgba(5, 10, 15, 200));
                border-radius: 15px;
                border: 2px solid rgba(0, 255, 100, 100);
            }
        """)
        
        left_layout.addWidget(gauges_frame)
        
        # 시스템 상태
        self.system_status = SystemStatusPanel()
        left_layout.addWidget(self.system_status)
        
        left_panel.setLayout(left_layout)
        left_panel.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(10, 20, 30, 200),
                    stop:1 rgba(5, 10, 15, 200));
                border-radius: 20px;
                border: 2px solid rgba(0, 255, 100, 100);
            }
        """)
        
        layout.addWidget(left_panel)
        
    def setup_visualization_panel(self, layout):
        """시각화 패널"""
        # 중앙 패널
        center_panel = QFrame()
        center_layout = QVBoxLayout()
        center_layout.setSpacing(20)
        
        # 제목
        title_label = QLabel("COMMAND CENTER")
        title_label.setFont(QFont("Consolas", 18, QFont.Bold))
        title_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 100, 250);
                background: transparent;
                padding: 15px;
            }
        """)
        center_layout.addWidget(title_label)
        
        # 3D 시각화 영역
        self.visualization_area = QFrame()
        self.visualization_area.setFixedHeight(600)
        self.visualization_area.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(5, 15, 25, 200),
                    stop:1 rgba(10, 25, 40, 200));
                border-radius: 15px;
                border: 2px solid rgba(0, 255, 100, 100);
            }
        """)
        
        # 3D 시각화 위젯
        self.visualization_widget = QWidget()
        self.visualization_widget.setParent(self.visualization_area)
        self.visualization_widget.setGeometry(20, 20, 560, 560)
        
        center_layout.addWidget(self.visualization_area)
        
        # 컨트롤 버튼들
        control_frame = QFrame()
        control_frame.setFixedHeight(80)
        control_layout = QHBoxLayout()
        control_layout.setSpacing(15)
        
        # 버튼들
        buttons = [
            ("DEPLOY", QColor(0, 255, 100)),
            ("UPDATE", QColor(0, 200, 255)),
            ("CONFIGURE", QColor(255, 150, 0)),
            ("STATUS", QColor(255, 255, 255)),
            ("TERMINATE", QColor(255, 50, 50))
        ]
        
        for text, color in buttons:
            btn = self.create_command_button(text, color)
            control_layout.addWidget(btn)
            
        control_frame.setLayout(control_layout)
        control_frame.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(10, 20, 30, 200),
                    stop:1 rgba(5, 10, 15, 200));
                border-radius: 15px;
                border: 2px solid rgba(0, 255, 100, 100);
            }
        """)
        
        center_layout.addWidget(control_frame)
        
        center_panel.setLayout(center_layout)
        center_panel.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(10, 20, 30, 200),
                    stop:1 rgba(5, 10, 15, 200));
                border-radius: 20px;
                border: 2px solid rgba(0, 255, 100, 100);
            }
        """)
        
        layout.addWidget(center_panel)
        
    def setup_project_panel(self, layout):
        """프로젝트 패널"""
        # 오른쪽 패널
        right_panel = QFrame()
        right_panel.setFixedWidth(400)
        right_layout = QVBoxLayout()
        right_layout.setSpacing(20)
        
        # 제목
        title_label = QLabel("PROJECT ASSETS")
        title_label.setFont(QFont("Consolas", 16, QFont.Bold))
        title_label.setStyleSheet("""
            QLabel {
                color: rgba(0, 255, 100, 250);
                background: transparent;
                padding: 15px;
            }
        """)
        right_layout.addWidget(title_label)
        
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
                background: rgba(10, 20, 30, 200);
                width: 12px;
                border-radius: 6px;
            }
            QScrollBar::handle:vertical {
                background: rgba(0, 255, 100, 150);
                border-radius: 6px;
                min-height: 20px;
            }
            QScrollBar::handle:vertical:hover {
                background: rgba(0, 255, 100, 200);
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
        
        right_layout.addWidget(self.project_list)
        
        right_panel.setLayout(right_layout)
        right_panel.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba(10, 20, 30, 200),
                    stop:1 rgba(5, 10, 15, 200));
                border-radius: 20px;
                border: 2px solid rgba(0, 255, 100, 100);
            }
        """)
        
        layout.addWidget(right_panel)
        
    def create_project_cards(self):
        """프로젝트 카드"""
        projects = [
            {"name": "Project Alpha", "status": "Online", "version": "1.2.0"},
            {"name": "Project Beta", "status": "Online", "version": "2.1.0"},
            {"name": "Project Gamma", "status": "Offline", "version": "1.5.0"},
            {"name": "Project Delta", "status": "Online", "version": "1.0.0"},
            {"name": "Project Epsilon", "status": "Online", "version": "3.0.0"},
            {"name": "Project Zeta", "status": "Online", "version": "2.3.0"},
            {"name": "Project Eta", "status": "Offline", "version": "1.8.0"},
            {"name": "Project Theta", "status": "Online", "version": "2.0.0"}
        ]
        
        for project in projects:
            card = ProjectCard(project)
            self.project_layout.addWidget(card)
            
    def create_command_button(self, text, color):
        """커맨드 버튼"""
        btn = QPushButton(text)
        btn.setFixedSize(100, 50)
        btn.setFont(QFont("Consolas", 10, QFont.Bold))
        btn.setCursor(Qt.PointingHandCursor)
        
        btn.setStyleSheet(f"""
            QPushButton {{
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba({color.red()}, {color.green()}, {color.blue()}, 50),
                    stop:1 rgba({color.red()}, {color.green()}, {color.blue()}, 30));
                border: 2px solid rgba({color.red()}, {color.green()}, {color.blue()}, 150);
                border-radius: 25px;
                color: rgba(255, 255, 255, 250);
            }}
            QPushButton:hover {{
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 rgba({color.red()}, {color.green()}, {color.blue()}, 100),
                    stop:1 rgba({color.red()}, {color.green()}, {color.blue()}, 70));
                border: 2px solid rgba({color.red()}, {color.green()}, {color.blue()}, 200);
            }}
        """)
        
        btn.clicked.connect(lambda: self.on_command_click(text))
        return btn
        
    def setup_monitoring(self):
        """모니터링"""
        self.monitor.data_updated.connect(self.update_monitoring_data)
        self.monitor.start()
        
    def setup_animations(self):
        """애니메이션"""
        # 윈도우 페이드 인
        self.fade_in = QPropertyAnimation(self, b"windowOpacity")
        self.fade_in.setDuration(1500)
        self.fade_in.setStartValue(0.0)
        self.fade_in.setEndValue(1.0)
        self.fade_in.setEasingCurve(QEasingCurve.OutCubic)
        self.fade_in.start()
        
        # 3D 시각화 애니메이션
        self.visualization_timer = QTimer()
        self.visualization_timer.timeout.connect(self.update_visualization)
        self.visualization_timer.start(50)  # 20 FPS
        
    def update_visualization(self):
        """3D 시각화 업데이트"""
        self.visualization_widget.update()
        
    def update_monitoring_data(self, data):
        """데이터 업데이트"""
        # 게이지 업데이트
        self.cpu_gauge.set_value(data['cpu_percent'])
        self.memory_gauge.set_value(data['memory_percent'])
        self.disk_gauge.set_value(data['disk_percent'])
        
        # 네트워크 속도 (0-100MB/s 범위로 정규화)
        network_speed = min(data['network_sent_speed'] + data['network_recv_speed'], 100)
        self.network_gauge.set_value(network_speed)
        
        # 시스템 정보 업데이트
        self.system_status.status_labels['local_ip'].setText(data['local_ip'])
        self.system_status.status_labels['uptime'].setText(data['uptime'])
        self.system_status.status_labels['cpu_count'].setText(str(data['cpu_count']))
        self.system_status.status_labels['process_count'].setText(str(data['process_count']))
        self.system_status.status_labels['memory_total'].setText(f"{data['memory_total']:.1f} GB")
        self.system_status.status_labels['disk_total'].setText(f"{data['disk_total']:.1f} GB")
        
    def on_command_click(self, command):
        """커맨드 클릭"""
        if command == "DEPLOY":
            QMessageBox.information(self, "Deploy", "Deploying selected assets...")
        elif command == "UPDATE":
            QMessageBox.information(self, "Update", "Checking for updates...")
        elif command == "CONFIGURE":
            QMessageBox.information(self, "Configure", "Opening configuration panel...")
        elif command == "STATUS":
            QMessageBox.information(self, "Status", "System status: All systems operational")
        elif command == "TERMINATE":
            self.close()
            
    def closeEvent(self, event):
        """윈도우 종료"""
        self.monitor.stop()
        self.monitor.wait()
        event.accept()

def main():
    """메인"""
    app = QApplication(sys.argv)
    app.setApplicationName("Invariant Command")
    app.setApplicationVersion("3.0.0")
    
    # 어두운 테마 설정
    app.setStyle('Fusion')
    
    # 윈도우 생성 및 표시
    window = InvariantCommand()
    window.show()
    
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
