#!/usr/bin/env python3
"""
Fix dei percorsi dei file Swift nel progetto Xcode
"""
import re

# Mapping dei file ai loro percorsi relativi (con prefisso MyNoleggioApp/)
FILE_PATHS = {
    'APIClient.swift': 'MyNoleggioApp/Networking/APIClient.swift',
    'ServerConfig.swift': 'MyNoleggioApp/Networking/ServerConfig.swift',
    'AppSession.swift': 'MyNoleggioApp/Session/AppSession.swift',
    'HeartbeatManager.swift': 'MyNoleggioApp/Session/HeartbeatManager.swift',
    'BiometricHelper.swift': 'MyNoleggioApp/Security/BiometricHelper.swift',
    'SecureStorageManager.swift': 'MyNoleggioApp/Security/SecureStorageManager.swift',
    'NotificationHelper.swift': 'MyNoleggioApp/Notifications/NotificationHelper.swift',
    'AuthModels.swift': 'MyNoleggioApp/Models/AuthModels.swift',
    'DomainModels.swift': 'MyNoleggioApp/Models/DomainModels.swift',
    'LoginView.swift': 'MyNoleggioApp/Features/Login/LoginView.swift',
    'LoginViewModel.swift': 'MyNoleggioApp/Features/Login/LoginViewModel.swift',
    'PinEntryView.swift': 'MyNoleggioApp/Features/Login/PinEntryView.swift',
    'PinSetupView.swift': 'MyNoleggioApp/Features/Login/PinSetupView.swift',
    'ClientsListView.swift': 'MyNoleggioApp/Features/Clients/ClientsListView.swift',
    'ClientsViewModel.swift': 'MyNoleggioApp/Features/Clients/ClientsViewModel.swift',
    'ClientDetailView.swift': 'MyNoleggioApp/Features/Clients/ClientDetailView.swift',
    'ClientDetailViewModel.swift': 'MyNoleggioApp/Features/Clients/ClientDetailViewModel.swift',
    'RentalsListView.swift': 'MyNoleggioApp/Features/Rentals/RentalsListView.swift',
    'RentalsViewModel.swift': 'MyNoleggioApp/Features/Rentals/RentalsViewModel.swift',
    'RentalDetailView.swift': 'MyNoleggioApp/Features/Rentals/RentalDetailView.swift',
    'RentalDetailViewModel.swift': 'MyNoleggioApp/Features/Rentals/RentalDetailViewModel.swift',
    'BarcodeScannerView.swift': 'MyNoleggioApp/Features/BarcodeScanner/BarcodeScannerView.swift',
    'ServerSetupView.swift': 'MyNoleggioApp/Features/ServerSetup/ServerSetupView.swift',
}

def main():
    proj_path = "MyNoleggioApp.xcodeproj/project.pbxproj"
    
    print("🔧 Fixing file paths in project.pbxproj...")
    
    with open(proj_path, 'r') as f:
        content = f.read()
    
    fixed_count = 0
    
    # Fix PBXFileReference entries
    for filename, new_filepath in FILE_PATHS.items():
        # Cerca il pattern esistente con path parziale (senza MyNoleggioApp/)
        old_filepath = new_filepath.replace('MyNoleggioApp/', '')
        
        # Pattern con path parziale
        old_pattern = f'path = {old_filepath};'
        new_pattern = f'path = {new_filepath};'
        
        if old_pattern in content:
            content = content.replace(old_pattern, new_pattern)
            fixed_count += 1
            print(f"  ✓ Fixed: {old_filepath} → {new_filepath}")
    
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
