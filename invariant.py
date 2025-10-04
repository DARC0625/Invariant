#!/usr/bin/env python3
"""
Invariant - Main Launcher
Master Project Hub
"""

import sys
import os
from pathlib import Path

# 프로젝트 루트를 Python 경로에 추가
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root / "src"))

try:
    from Invariant_Cyberpunk import InvariantCyberpunk
    
    if __name__ == "__main__":
        app = InvariantCyberpunk()
        app.run()
        
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Please ensure all dependencies are installed:")
    print("pip install -r requirements.txt")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)
