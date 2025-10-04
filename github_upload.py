#!/usr/bin/env python3
"""
GitHub 자동 업로드 스크립트
저장소 생성부터 릴리즈까지 자동화
"""

import os
import json
import base64
import requests
from pathlib import Path

class GitHubUploader:
    def __init__(self, username, token=None):
        self.username = username
        self.token = token
        self.repo_name = "Invariant"
        self.api_base = "https://api.github.com"
        self.headers = {
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "Invariant-AutoUploader"
        }
        
        if token:
            self.headers["Authorization"] = f"token {token}"
    
    def create_repository(self):
        """GitHub 저장소 생성"""
        print(f"🔧 GitHub 저장소 '{self.repo_name}' 생성 중...")
        
        repo_data = {
            "name": self.repo_name,
            "description": "Master Project Hub - 모든 프로젝트들의 통합 관리 시스템",
            "private": False,
            "auto_init": False,
            "gitignore_template": "Python",
            "license_template": "mit"
        }
        
        try:
            response = requests.post(
                f"{self.api_base}/user/repos",
                headers=self.headers,
                json=repo_data
            )
            
            if response.status_code == 201:
                print("✅ 저장소 생성 완료")
                return True
            elif response.status_code == 422:
                print("ℹ️ 저장소가 이미 존재합니다")
                return True
            else:
                print(f"❌ 저장소 생성 실패: {response.status_code}")
                print(f"응답: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ 저장소 생성 오류: {e}")
            return False
    
    def upload_file(self, file_path, content, message="Upload file"):
        """파일 업로드"""
        try:
            # 파일 내용을 base64로 인코딩
            if isinstance(content, str):
                content_bytes = content.encode('utf-8')
            else:
                content_bytes = content
            
            encoded_content = base64.b64encode(content_bytes).decode('utf-8')
            
            # GitHub API로 파일 업로드
            upload_data = {
                "message": message,
                "content": encoded_content,
                "branch": "main"
            }
            
            response = requests.put(
                f"{self.api_base}/repos/{self.username}/{self.repo_name}/contents/{file_path}",
                headers=self.headers,
                json=upload_data
            )
            
            if response.status_code in [200, 201]:
                print(f"✅ {file_path} 업로드 완료")
                return True
            else:
                print(f"❌ {file_path} 업로드 실패: {response.status_code}")
                print(f"응답: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ {file_path} 업로드 오류: {e}")
            return False
    
    def upload_all_files(self):
        """모든 파일 업로드"""
        print("📤 모든 파일 업로드 중...")
        
        # 업로드할 파일 목록
        files_to_upload = [
            "Master_Launcher.py",
            "Project_Manager.py", 
            "README.md",
            "requirements.txt",
            "install.py",
            "start_invariant.bat",
            "create_release.py",
            "version.json",
            ".gitignore"
        ]
        
        success_count = 0
        
        for file_name in files_to_upload:
            if os.path.exists(file_name):
                try:
                    with open(file_name, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    if self.upload_file(file_name, content, f"Add {file_name}"):
                        success_count += 1
                        
                except Exception as e:
                    print(f"❌ {file_name} 읽기 실패: {e}")
            else:
                print(f"⚠️ {file_name} 파일을 찾을 수 없습니다")
        
        print(f"📊 업로드 완료: {success_count}/{len(files_to_upload)} 파일")
        return success_count == len(files_to_upload)
    
    def create_release(self, version, zip_file_path):
        """릴리즈 생성"""
        print(f"🎯 릴리즈 v{version} 생성 중...")
        
        # 릴리즈 데이터
        release_data = {
            "tag_name": f"v{version}",
            "target_commitish": "main",
            "name": f"Invariant v{version}",
            "body": f"""# Invariant v{version}

## 🚀 Master Project Hub

모든 프로젝트들을 통합 관리하는 메인 허브 시스템

### 주요 기능
- 통합 프로젝트 관리
- GitHub 기반 자동 업데이트  
- 버전 관리 (안정화/베타)
- 원클릭 실행 및 설치
- GUI 인터페이스

### 설치 방법
1. `Invariant_v{version}.zip` 다운로드
2. 압축 해제
3. `python Master_Launcher.py` 실행

### 요구사항
- Python 3.7+
- tkinter
- Windows 10/11""",
            "draft": False,
            "prerelease": False
        }
        
        try:
            # 릴리즈 생성
            response = requests.post(
                f"{self.api_base}/repos/{self.username}/{self.repo_name}/releases",
                headers=self.headers,
                json=release_data
            )
            
            if response.status_code == 201:
                release_info = response.json()
                release_id = release_info["id"]
                print("✅ 릴리즈 생성 완료")
                
                # ZIP 파일 업로드
                if os.path.exists(zip_file_path):
                    return self.upload_release_asset(release_id, zip_file_path)
                else:
                    print(f"⚠️ ZIP 파일을 찾을 수 없습니다: {zip_file_path}")
                    return True
                    
            else:
                print(f"❌ 릴리즈 생성 실패: {response.status_code}")
                print(f"응답: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ 릴리즈 생성 오류: {e}")
            return False
    
    def upload_release_asset(self, release_id, zip_file_path):
        """릴리즈 에셋 업로드"""
        print(f"📦 릴리즈 에셋 업로드 중: {zip_file_path}")
        
        try:
            with open(zip_file_path, 'rb') as f:
                zip_content = f.read()
            
            # 릴리즈 에셋 업로드
            response = requests.post(
                f"{self.api_base}/repos/{self.username}/{self.repo_name}/releases/{release_id}/assets",
                headers={
                    **self.headers,
                    "Content-Type": "application/zip"
                },
                data=zip_content,
                params={"name": os.path.basename(zip_file_path)}
            )
            
            if response.status_code == 201:
                print("✅ 릴리즈 에셋 업로드 완료")
                return True
            else:
                print(f"❌ 릴리즈 에셋 업로드 실패: {response.status_code}")
                print(f"응답: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ 릴리즈 에셋 업로드 오류: {e}")
            return False
    
    def get_repository_url(self):
        """저장소 URL 반환"""
        return f"https://github.com/{self.username}/{self.repo_name}"

def main():
    """메인 함수"""
    print("🚀 Invariant GitHub 자동 업로드")
    print("=" * 50)
    
    # GitHub 사용자명
    username = "DARC0625"
    
    # GitHub 토큰 입력 (선택사항)
    token = input("GitHub Personal Access Token (선택사항, 엔터로 건너뛰기): ").strip()
    if not token:
        token = None
        print("⚠️ 토큰 없이 진행합니다. 공개 저장소만 가능합니다.")
    
    uploader = GitHubUploader(username, token)
    
    try:
        # 1. 저장소 생성
        if not uploader.create_repository():
            print("❌ 저장소 생성 실패로 중단")
            return
        
        # 2. 파일 업로드
        if not uploader.upload_all_files():
            print("❌ 파일 업로드 실패")
            return
        
        # 3. 릴리즈 생성
        version = "1.0.0"
        zip_file = f"Invariant_v{version}.zip"
        
        if not uploader.create_release(version, zip_file):
            print("❌ 릴리즈 생성 실패")
            return
        
        print("\n✅ 모든 작업 완료!")
        print(f"🌐 저장소 URL: {uploader.get_repository_url()}")
        print(f"📦 릴리즈: {uploader.get_repository_url()}/releases/tag/v{version}")
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
