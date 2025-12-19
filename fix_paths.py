#!/usr/bin/env python3
"""
Fix dei percorsi dei file Swift nel progetto Xcode
"""
import re

# Mapping dei file ai loro percorsi relativi
FILE_PATHS = {
    'APIClient.swift': 'Networking/APIClient.swift',
    'ServerConfig.swift': 'Networking/ServerConfig.swift',
    'AppSession.swift': 'Session/AppSession.swift',
    'HeartbeatManager.swift': 'Session/HeartbeatManager.swift',
    'BiometricHelper.swift': 'Security/BiometricHelper.swift',
    'SecureStorageManager.swift': 'Security/SecureStorageManager.swift',
    'NotificationHelper.swift': 'Notifications/NotificationHelper.swift',
    'AuthModels.swift': 'Models/AuthModels.swift',
    'DomainModels.swift': 'Models/DomainModels.swift',
    'LoginView.swift': 'Features/Login/LoginView.swift',
    'LoginViewModel.swift': 'Features/Login/LoginViewModel.swift',
    'PinEntryView.swift': 'Features/Login/PinEntryView.swift',
    'PinSetupView.swift': 'Features/Login/PinSetupView.swift',
    'ClientsListView.swift': 'Features/Clients/ClientsListView.swift',
    'ClientsViewModel.swift': 'Features/Clients/ClientsViewModel.swift',
    'ClientDetailView.swift': 'Features/Clients/ClientDetailView.swift',
    'ClientDetailViewModel.swift': 'Features/Clients/ClientDetailViewModel.swift',
    'RentalsListView.swift': 'Features/Rentals/RentalsListView.swift',
    'RentalsViewModel.swift': 'Features/Rentals/RentalsViewModel.swift',
    'RentalDetailView.swift': 'Features/Rentals/RentalDetailView.swift',
    'RentalDetailViewModel.swift': 'Features/Rentals/RentalDetailViewModel.swift',
    'BarcodeScannerView.swift': 'Features/BarcodeScanner/BarcodeScannerView.swift',
    'ServerSetupView.swift': 'Features/ServerSetup/ServerSetupView.swift',
}

def main():
    proj_path = "MyNoleggioApp.xcodeproj/project.pbxproj"
    
    print("🔧 Fixing file paths in project.pbxproj...")
    
    with open(proj_path, 'r') as f:
        content = f.read()
    
    fixed_count = 0
    
    # Fix PBXFileReference entries
    for filename, filepath in FILE_PATHS.items():
        # Pattern: filename senza path → filename con path
        old_pattern = f'/* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};'
        new_pattern = f'/* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filepath}; sourceTree = "<group>"; }};'
        
        if old_pattern in content:
            content = content.replace(old_pattern, new_pattern)
            fixed_count += 1
            print(f"  ✓ Fixed: {filename} → {filepath}")
    
    # Backup
    backup_path = proj_path + ".backup2"
    with open(backup_path, 'w') as f:
        f.write(content)
    
    # Save
    with open(proj_path, 'w') as f:
        f.write(content)
    
    print(f"\n✅ Fixed {fixed_count} file paths")
    print(f"💾 Backup saved: {backup_path}")

if __name__ == "__main__":
    main()
