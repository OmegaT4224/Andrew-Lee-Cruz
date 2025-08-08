"""
GitHub Agent for AxiomDevCore
Handles GitHub automation including file writes, commits, pushes
"""

import os
import json
import subprocess
import tempfile
from typing import Dict, Any, List, Optional
from pathlib import Path

from .reflect_logger import ReflectLogger

class GitHubAgent:
    """GitHub automation agent for AxiomDevCore"""
    
    def __init__(self, repo_path: str = ".", log_dir: str = "./logs"):
        self.repo_path = Path(repo_path)
        self.reflect_logger = ReflectLogger(log_dir)
        self.contact = "allcatch37@gmail.com"
        
    def setup_git_config(self):
        """Configure Git with AxiomDevCore identity"""
        try:
            subprocess.run([
                "git", "config", "user.name", "AxiomDevCore Agent"
            ], cwd=self.repo_path, check=True)
            
            subprocess.run([
                "git", "config", "user.email", self.contact
            ], cwd=self.repo_path, check=True)
            
            self.reflect_logger.log_github_operation("setup_git_config", {
                "success": True,
                "user_email": self.contact
            })
            
        except subprocess.CalledProcessError as e:
            self.reflect_logger.log_github_operation("setup_git_config", {
                "success": False,
                "error": str(e)
            })
            raise
            
    def write_file(self, file_path: str, content: str, create_dirs: bool = True):
        """Write content to file, creating directories if needed"""
        target_path = self.repo_path / file_path
        
        if create_dirs:
            target_path.parent.mkdir(parents=True, exist_ok=True)
            
        with open(target_path, 'w') as f:
            f.write(content)
            
        self.reflect_logger.log_github_operation("write_file", {
            "file_path": file_path,
            "content_length": len(content),
            "success": True
        })
        
    def commit_changes(self, message: str, files: Optional[List[str]] = None):
        """Commit changes to Git"""
        try:
            # Add files
            if files:
                for file_path in files:
                    subprocess.run([
                        "git", "add", file_path
                    ], cwd=self.repo_path, check=True)
            else:
                subprocess.run([
                    "git", "add", "."
                ], cwd=self.repo_path, check=True)
                
            # Commit
            subprocess.run([
                "git", "commit", "-m", message
            ], cwd=self.repo_path, check=True)
            
            self.reflect_logger.log_github_operation("commit_changes", {
                "message": message,
                "files": files or ["all"],
                "success": True
            })
            
        except subprocess.CalledProcessError as e:
            self.reflect_logger.log_github_operation("commit_changes", {
                "message": message,
                "error": str(e),
                "success": False
            })
            raise
            
    def push_changes(self, branch: str = "main"):
        """Push changes to GitHub"""
        try:
            subprocess.run([
                "git", "push", "origin", branch
            ], cwd=self.repo_path, check=True)
            
            self.reflect_logger.log_github_operation("push_changes", {
                "branch": branch,
                "success": True
            })
            
        except subprocess.CalledProcessError as e:
            self.reflect_logger.log_github_operation("push_changes", {
                "branch": branch,
                "error": str(e),
                "success": False
            })
            raise
            
    def create_branch(self, branch_name: str):
        """Create and checkout new branch"""
        try:
            subprocess.run([
                "git", "checkout", "-b", branch_name
            ], cwd=self.repo_path, check=True)
            
            self.reflect_logger.log_github_operation("create_branch", {
                "branch_name": branch_name,
                "success": True
            })
            
        except subprocess.CalledProcessError as e:
            self.reflect_logger.log_github_operation("create_branch", {
                "branch_name": branch_name,
                "error": str(e),
                "success": False
            })
            raise
            
    def get_repo_status(self) -> Dict[str, Any]:
        """Get current repository status"""
        try:
            # Get current branch
            branch_result = subprocess.run([
                "git", "branch", "--show-current"
            ], cwd=self.repo_path, capture_output=True, text=True, check=True)
            
            current_branch = branch_result.stdout.strip()
            
            # Get status
            status_result = subprocess.run([
                "git", "status", "--porcelain"
            ], cwd=self.repo_path, capture_output=True, text=True, check=True)
            
            status_lines = status_result.stdout.strip().split('\n') if status_result.stdout.strip() else []
            
            status = {
                "current_branch": current_branch,
                "modified_files": [line[3:] for line in status_lines if line.startswith(' M')],
                "new_files": [line[3:] for line in status_lines if line.startswith('??')],
                "staged_files": [line[3:] for line in status_lines if line.startswith('A ')],
                "clean": len(status_lines) == 0
            }
            
            self.reflect_logger.log_github_operation("get_repo_status", {
                "status": status,
                "success": True
            })
            
            return status
            
        except subprocess.CalledProcessError as e:
            self.reflect_logger.log_github_operation("get_repo_status", {
                "error": str(e),
                "success": False
            })
            raise
            
    def quantum_compile_integration(self, violet_state: Dict[str, Any]):
        """Integrate quantum compilation results into GitHub workflow"""
        try:
            # Create quantum results file
            quantum_file = f"quantum_results_{violet_state.get('violet_sequence_id', 'unknown')}.json"
            self.write_file(quantum_file, json.dumps(violet_state, indent=2))
            
            # Commit quantum results
            commit_msg = f"Add quantum compilation results: {violet_state.get('violet_sequence_id')}"
            self.commit_changes(commit_msg, [quantum_file])
            
            self.reflect_logger.log_github_operation("quantum_compile_integration", {
                "violet_sequence_id": violet_state.get('violet_sequence_id'),
                "quantum_file": quantum_file,
                "success": True
            })
            
            return {
                "quantum_file": quantum_file,
                "committed": True,
                "success": True
            }
            
        except Exception as e:
            self.reflect_logger.log_github_operation("quantum_compile_integration", {
                "error": str(e),
                "success": False
            })
            raise