#!/usr/bin/env python3
"""
Setup script for Plant Disease Detection System
Run this script to install dependencies and verify setup
"""

import subprocess
import sys
import os
from pathlib import Path

def install_requirements():
    """Install required packages from requirements.txt"""
    print("Installing required packages...")
    try:
        subprocess.run([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'], 
                      check=True, capture_output=True, text=True)
        print("✓ All packages installed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Package installation failed: {e}")
        print(f"Error output: {e.stderr}")
        return False

def verify_installation():
    """Verify that all required packages are installed"""
    print("\nVerifying installation...")
    required_packages = [
        'tensorflow', 'numpy', 'pandas', 'matplotlib', 
        'seaborn', 'sklearn', 'cv2', 'PIL'
    ]
    
    missing = []
    for package in required_packages:
        try:
            if package == 'cv2':
                import cv2
            elif package == 'PIL':
                from PIL import Image
            elif package == 'sklearn':
                import sklearn
            else:
                __import__(package)
            print(f"✓ {package}")
        except ImportError:
            print(f"✗ {package}")
            missing.append(package)
    
    if missing:
        print(f"\nMissing packages: {missing}")
        return False
    else:
        print("\n✓ All packages verified!")
        return True

def check_dataset():
    """Check if dataset directory exists"""
    print("\nChecking dataset...")
    dataset_path = Path("final_dataset")
    if dataset_path.exists():
        train_path = dataset_path / "train"
        val_path = dataset_path / "val"
        test_path = dataset_path / "test"
        
        if train_path.exists() and val_path.exists():
            print("✓ Dataset structure looks good!")
            return True
        else:
            print("⚠️  Dataset folder exists but missing train/val subfolders")
            return False
    else:
        print("⚠️  Dataset folder 'final_dataset' not found")
        print("Please ensure your dataset is in the correct location")
        return False

def main():
    print("=== Plant Disease Detection System Setup ===")
    print(f"Python version: {sys.version}")
    
    # Install requirements
    if not install_requirements():
        print("Setup failed during package installation")
        return False
    
    # Verify installation
    if not verify_installation():
        print("Setup failed during verification")
        return False
    
    # Check dataset
    dataset_ok = check_dataset()
    
    print("\n" + "="*50)
    if dataset_ok:
        print("✓ Setup completed successfully!")
        print("You can now run the Jupyter notebook.")
    else:
        print("⚠️  Setup completed with warnings")
        print("Please check the dataset structure before running the notebook.")
    
    return True

if __name__ == "__main__":
    main()
