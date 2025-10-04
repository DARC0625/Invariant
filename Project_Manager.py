#!/usr/bin/env python3
"""
Project Manager - 프로젝트 관리 유틸리티
프로젝트 추가, 제거, 설정 등의 기능 제공
"""

import os
import sys
import json
import shutil
from pathlib import Path
from datetime import datetime

class ProjectManager:
    def __init__(self):
        self.projects_dir = Path("C:/Projects")
        self.launcher_dir = Path(os.path.dirname(os.path.abspath(__file__)))
        self.config_file = self.launcher_dir / "master_config.json"
        
    def add_project(self, project_id, project_info):
        """새 프로젝트 추가"""
        try:
            # 설정 파일 로드
            config = self.load_config()
            
            # 프로젝트 정보 추가
            if 'projects' not in config:
                config['projects'] = {}
            
            config['projects'][project_id] = {
                **project_info,
                'created_date': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                'active': True
            }
            
            # 설정 파일 저장
            self.save_config(config)
            
            print(f"✅ 프로젝트 '{project_id}' 추가 완료")
            return True
            
        except Exception as e:
            print(f"❌ 프로젝트 추가 실패: {e}")
            return False
            
    def remove_project(self, project_id):
        """프로젝트 제거"""
        try:
            # 설정 파일 로드
            config = self.load_config()
            
            if 'projects' in config and project_id in config['projects']:
                # 비활성화로 변경 (완전 삭제하지 않음)
                config['projects'][project_id]['active'] = False
                config['projects'][project_id]['removed_date'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                
                # 설정 파일 저장
                self.save_config(config)
                
                print(f"✅ 프로젝트 '{project_id}' 비활성화 완료")
                return True
            else:
                print(f"❌ 프로젝트 '{project_id}'를 찾을 수 없습니다")
                return False
                
        except Exception as e:
            print(f"❌ 프로젝트 제거 실패: {e}")
            return False
            
    def update_project(self, project_id, project_info):
        """프로젝트 정보 업데이트"""
        try:
            # 설정 파일 로드
            config = self.load_config()
            
            if 'projects' in config and project_id in config['projects']:
                # 기존 정보와 새 정보 병합
                config['projects'][project_id].update(project_info)
                config['projects'][project_id]['updated_date'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                
                # 설정 파일 저장
                self.save_config(config)
                
                print(f"✅ 프로젝트 '{project_id}' 정보 업데이트 완료")
                return True
            else:
                print(f"❌ 프로젝트 '{project_id}'를 찾을 수 없습니다")
                return False
                
        except Exception as e:
            print(f"❌ 프로젝트 업데이트 실패: {e}")
            return False
            
    def list_projects(self):
        """프로젝트 목록 출력"""
        try:
            config = self.load_config()
            
            if 'projects' not in config or not config['projects']:
                print("등록된 프로젝트가 없습니다.")
                return
            
            print("📋 등록된 프로젝트 목록:")
            print("-" * 80)
            
            for project_id, project_info in config['projects'].items():
                status = "활성" if project_info.get('active', True) else "비활성"
                print(f"ID: {project_id}")
                print(f"  이름: {project_info.get('name', 'N/A')}")
                print(f"  설명: {project_info.get('description', 'N/A')}")
                print(f"  저장소: {project_info.get('repo_name', 'N/A')}")
                print(f"  상태: {status}")
                print(f"  생성일: {project_info.get('created_date', 'N/A')}")
                if 'updated_date' in project_info:
                    print(f"  수정일: {project_info['updated_date']}")
                if 'removed_date' in project_info:
                    print(f"  제거일: {project_info['removed_date']}")
                print("-" * 80)
                
        except Exception as e:
            print(f"❌ 프로젝트 목록 조회 실패: {e}")
            
    def get_active_projects(self):
        """활성 프로젝트 목록 반환"""
        try:
            config = self.load_config()
            
            if 'projects' not in config:
                return {}
                
            return {pid: info for pid, info in config['projects'].items() 
                   if info.get('active', True)}
                   
        except Exception as e:
            print(f"❌ 활성 프로젝트 조회 실패: {e}")
            return {}
            
    def cleanup_project_files(self, project_id):
        """프로젝트 파일 정리"""
        try:
            project_path = self.projects_dir / project_id
            
            if project_path.exists():
                shutil.rmtree(project_path)
                print(f"✅ 프로젝트 '{project_id}' 파일 정리 완료")
                return True
            else:
                print(f"ℹ️ 프로젝트 '{project_id}' 파일이 없습니다")
                return True
                
        except Exception as e:
            print(f"❌ 프로젝트 파일 정리 실패: {e}")
            return False
            
    def load_config(self):
        """설정 파일 로드"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                pass
        
        # 기본 설정 반환
        return {
            'github_owner': 'DARC0625',
            'base_repo_name': 'Project',
            'projects': {}
        }
        
    def save_config(self, config):
        """설정 파일 저장"""
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"❌ 설정 파일 저장 실패: {e}")
            return False
            
    def backup_config(self):
        """설정 파일 백업"""
        try:
            if self.config_file.exists():
                backup_file = self.config_file.with_suffix('.json.backup')
                shutil.copy2(self.config_file, backup_file)
                print(f"✅ 설정 파일 백업 완료: {backup_file}")
                return True
            else:
                print("❌ 백업할 설정 파일이 없습니다")
                return False
        except Exception as e:
            print(f"❌ 설정 파일 백업 실패: {e}")
            return False
            
    def restore_config(self):
        """설정 파일 복원"""
        try:
            backup_file = self.config_file.with_suffix('.json.backup')
            
            if backup_file.exists():
                shutil.copy2(backup_file, self.config_file)
                print(f"✅ 설정 파일 복원 완료")
                return True
            else:
                print("❌ 복원할 백업 파일이 없습니다")
                return False
        except Exception as e:
            print(f"❌ 설정 파일 복원 실패: {e}")
            return False

def main():
    """메인 함수 - CLI 인터페이스"""
    manager = ProjectManager()
    
    print("🚀 Project Manager")
    print("=" * 50)
    
    while True:
        print("\n📋 메뉴:")
        print("1. 프로젝트 목록 보기")
        print("2. 프로젝트 추가")
        print("3. 프로젝트 제거")
        print("4. 프로젝트 업데이트")
        print("5. 설정 백업")
        print("6. 설정 복원")
        print("7. 종료")
        
        try:
            choice = input("\n선택하세요 (1-7): ").strip()
            
            if choice == "1":
                manager.list_projects()
                
            elif choice == "2":
                project_id = input("프로젝트 ID: ").strip()
                name = input("프로젝트 이름: ").strip()
                description = input("프로젝트 설명: ").strip()
                repo_name = input("GitHub 저장소 이름: ").strip()
                main_file = input("실행 파일: ").strip()
                install_script = input("설치 스크립트 (선택사항): ").strip()
                
                project_info = {
                    'name': name,
                    'description': description,
                    'repo_name': repo_name,
                    'main_file': main_file,
                    'install_script': install_script
                }
                
                manager.add_project(project_id, project_info)
                
            elif choice == "3":
                project_id = input("제거할 프로젝트 ID: ").strip()
                if input(f"'{project_id}' 프로젝트를 제거하시겠습니까? (y/N): ").lower() == 'y':
                    manager.remove_project(project_id)
                    
            elif choice == "4":
                project_id = input("업데이트할 프로젝트 ID: ").strip()
                print("새 정보를 입력하세요 (엔터로 건너뛰기):")
                
                project_info = {}
                name = input("프로젝트 이름: ").strip()
                if name:
                    project_info['name'] = name
                    
                description = input("프로젝트 설명: ").strip()
                if description:
                    project_info['description'] = description
                    
                repo_name = input("GitHub 저장소 이름: ").strip()
                if repo_name:
                    project_info['repo_name'] = repo_name
                    
                main_file = input("실행 파일: ").strip()
                if main_file:
                    project_info['main_file'] = main_file
                    
                install_script = input("설치 스크립트: ").strip()
                if install_script:
                    project_info['install_script'] = install_script
                
                if project_info:
                    manager.update_project(project_id, project_info)
                else:
                    print("변경할 정보가 없습니다.")
                    
            elif choice == "5":
                manager.backup_config()
                
            elif choice == "6":
                if input("설정을 백업에서 복원하시겠습니까? (y/N): ").lower() == 'y':
                    manager.restore_config()
                    
            elif choice == "7":
                print("👋 종료합니다.")
                break
                
            else:
                print("❌ 잘못된 선택입니다.")
                
        except KeyboardInterrupt:
            print("\n👋 종료합니다.")
            break
        except Exception as e:
            print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
