#!/usr/bin/env python3
"""
Windows 디버그 스크립트
PyQt5 실행 문제 진단
"""

import sys
import os
import traceback

def test_imports():
    """필수 모듈 import 테스트"""
    print("=== Import Test ===")
    
    try:
        import PyQt5
        print("✅ PyQt5 imported successfully")
        print(f"   PyQt5 version: {PyQt5.Qt.PYQT_VERSION_STR}")
    except Exception as e:
        print(f"❌ PyQt5 import failed: {e}")
        return False
    
    try:
        from PyQt5.QtWidgets import QApplication
        print("✅ QApplication imported successfully")
    except Exception as e:
        print(f"❌ QApplication import failed: {e}")
        return False
    
    try:
        from PyQt5.QtCore import Qt
        print("✅ QtCore imported successfully")
    except Exception as e:
        print(f"❌ QtCore import failed: {e}")
        return False
    
    try:
        from PyQt5.QtGui import QFont
        print("✅ QtGui imported successfully")
    except Exception as e:
        print(f"❌ QtGui import failed: {e}")
        return False
    
    return True

def test_simple_window():
    """간단한 윈도우 테스트"""
    print("\n=== Simple Window Test ===")
    
    try:
        from PyQt5.QtWidgets import QApplication, QWidget, QLabel
        from PyQt5.QtCore import Qt
        
        app = QApplication(sys.argv)
        print("✅ QApplication created")
        
        window = QWidget()
        window.setWindowTitle("Debug Test")
        window.setGeometry(100, 100, 300, 200)
        print("✅ Window created")
        
        label = QLabel("Hello World", window)
        label.setAlignment(Qt.AlignCenter)
        print("✅ Label created")
        
        window.show()
        print("✅ Window shown")
        
        # 3초 후 자동 종료
        from PyQt5.QtCore import QTimer
        timer = QTimer()
        timer.timeout.connect(app.quit)
        timer.start(3000)
        
        print("✅ Starting event loop...")
        app.exec_()
        print("✅ Event loop finished")
        
        return True
        
    except Exception as e:
        print(f"❌ Simple window test failed: {e}")
        traceback.print_exc()
        return False

def test_invariant():
    """Invariant 모듈 테스트"""
    print("\n=== Invariant Module Test ===")
    
    try:
        # 프로젝트 루트를 Python 경로에 추가
        from pathlib import Path
        project_root = Path(__file__).parent
        src_path = project_root / "src"
        
        print(f"Project root: {project_root}")
        print(f"Source path: {src_path}")
        print(f"Source exists: {src_path.exists()}")
        
        if src_path.exists():
            sys.path.insert(0, str(src_path))
            print("✅ Source path added to sys.path")
        else:
            print("❌ Source path does not exist")
            return False
        
        from Invariant_Cyberpunk import main
        print("✅ Invariant_Cyberpunk imported successfully")
        
        # main() 함수는 실제로 실행하지 않고 import만 테스트
        print("✅ main() function available")
        
        return True
        
    except Exception as e:
        print(f"❌ Invariant module test failed: {e}")
        traceback.print_exc()
        return False

def test_exe_file():
    """EXE 파일 존재 및 실행 테스트"""
    print("\n=== EXE File Test ===")
    
    try:
        from pathlib import Path
        exe_path = Path("Invariant.exe")
        
        print(f"EXE path: {exe_path.absolute()}")
        print(f"EXE exists: {exe_path.exists()}")
        
        if exe_path.exists():
            print(f"EXE size: {exe_path.stat().st_size} bytes")
            print("✅ EXE file found")
            
            # EXE 실행 테스트 (실제로는 실행하지 않음)
            print("✅ EXE file is ready for execution")
            return True
        else:
            print("❌ EXE file not found")
            return False
            
    except Exception as e:
        print(f"❌ EXE file test failed: {e}")
        traceback.print_exc()
        return False

def main():
    """메인 디버그 함수"""
    print("Invariant Windows Debug Script")
    print("=" * 40)
    
    # 환경 정보 출력
    print(f"Python version: {sys.version}")
    print(f"Platform: {sys.platform}")
    print(f"Current directory: {os.getcwd()}")
    print(f"Script directory: {os.path.dirname(os.path.abspath(__file__))}")
    
    # Import 테스트
    if not test_imports():
        print("\n❌ Import test failed. Cannot proceed.")
        return False
    
    # EXE 파일 테스트
    if not test_exe_file():
        print("\n❌ EXE file test failed.")
        return False
    
    # Invariant 모듈 테스트
    if not test_invariant():
        print("\n❌ Invariant module test failed.")
        return False
    
    # 간단한 윈도우 테스트
    if not test_simple_window():
        print("\n❌ Simple window test failed.")
        return False
    
    print("\n✅ All tests passed!")
    print("The issue might be with the main application logic.")
    return True

if __name__ == "__main__":
    try:
        success = main()
        if not success:
            input("\nPress Enter to exit...")
            sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nDebug interrupted by user.")
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        traceback.print_exc()
        input("\nPress Enter to exit...")
        sys.exit(1)
