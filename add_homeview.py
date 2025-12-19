#!/usr/bin/env python3
"""
Aggiunge HomeView.swift al progetto Xcode
"""
import re

def main():
    proj_path = "MyNoleggioApp.xcodeproj/project.pbxproj"
    
    print("📝 Aggiungendo HomeView.swift al progetto...")
    
    with open(proj_path, 'r') as f:
        content = f.read()
    
    # Trova l'ultimo ID usato e genera uno nuovo
    file_id = "A10000999999"
    build_id = "A10000999998"
    
    # 1. Aggiungi PBXBuildFile
    build_file_entry = f"\t\t{build_id} /* HomeView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* HomeView.swift */; }};"
    
    # Trova la sezione PBXBuildFile e aggiungi
    pbx_build_section = re.search(r'(\/\* Begin PBXBuildFile section \*\/\n)', content)
    if pbx_build_section:
        insert_pos = pbx_build_section.end()
        content = content[:insert_pos] + build_file_entry + "\n" + content[insert_pos:]
        print("  ✓ Aggiunto PBXBuildFile")
    
    # 2. Aggiungi PBXFileReference
    file_ref_entry = f"\t\t{file_id} /* HomeView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MyNoleggioApp/Features/Home/HomeView.swift; sourceTree = \"<group>\"; }};"
    
    pbx_file_section = re.search(r'(\/\* Begin PBXFileReference section \*\/\n)', content)
    if pbx_file_section:
        insert_pos = pbx_file_section.end()
        content = content[:insert_pos] + file_ref_entry + "\n" + content[insert_pos:]
        print("  ✓ Aggiunto PBXFileReference")
    
    # 3. Aggiungi a PBXSourcesBuildPhase
    sources_pattern = re.search(r'(\/\* Sources \*\/ = \{[^}]*files = \(\n)', content)
    if sources_pattern:
        insert_pos = sources_pattern.end()
        source_entry = f"\t\t\t\t{build_id} /* HomeView.swift in Sources */,\n"
        content = content[:insert_pos] + source_entry + content[insert_pos:]
        print("  ✓ Aggiunto a PBXSourcesBuildPhase")
    
    # Backup
    with open(proj_path + ".backup_home", 'w') as f:
        f.write(content)
    
    # Salva
    with open(proj_path, 'w') as f:
        f.write(content)
    
    print("✅ HomeView.swift aggiunto al progetto!")

if __name__ == "__main__":
    main()
