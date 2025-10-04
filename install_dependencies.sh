#!/bin/bash
# Invariant 의존성 설치 스크립트

echo "🚀 Installing Invariant dependencies..."

# pip3 설치
echo "📦 Installing pip3..."
sudo apt update
sudo apt install -y python3-pip

# PyInstaller 설치
echo "🔧 Installing PyInstaller..."
pip3 install pyinstaller

# 기타 필수 패키지들
echo "📚 Installing required packages..."
pip3 install requests urllib3 pillow numpy opencv-python ultralytics psutil mss pyautogui

echo "✅ All dependencies installed successfully!"
echo "🎯 Ready to build Invariant EXE!"
