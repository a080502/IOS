#!/usr/bin/env python3
"""
Script per aggiungere tutti i file Swift al progetto Xcode
"""
import os
import uuid
import re

def find_swift_files(base_path="MyNoleggioApp"):
    """Trova tutti i file Swift nel progetto"""
    swift_files = []
    for root, dirs, files in os.walk(base_path):
        # Salta directory nascoste
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        for file in files:
            if file.endswith('.swift'):
                rel_path = os.path.relpath(os.path.join(root, file), base_path)
                swift_files.append((file, rel_path))
    
    return sorted(swift_files)

def generate_hex_id(prefix="A10000"):
    """Genera un ID univoco in formato esadecimale"""
    import random
    suffix = ''.join([str(random.randint(0, 9)) for _ in range(5)])
    return prefix + suffix

def main():
    print("🔍 Ricerca file Swift...")
    swift_files = find_swift_files()
    
    # Rimuovi App.swift e RootView.swift perché già presenti
    swift_files = [(f, p) for f, p in swift_files if f not in ['App.swift', 'RootView.swift']]
    
    print(f"📝 Trovati {len(swift_files)} file Swift da aggiungere")
    
    # Leggi il progetto esistente
    proj_path = "MyNoleggioApp.xcodeproj/project.pbxproj"
    with open(proj_path, 'r') as f:
        content = f.read()
    
    # Genera le sezioni
    build_file_section = []
    file_ref_section = []
    sources_section = []
    
    for filename, filepath in swift_files:
        file_id = generate_hex_id("A100000")
        build_id = generate_hex_id("A100000")
        
        build_file_section.append(
            f'\t\t{build_id} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {filename} */; }};'
        )
        
        file_ref_section.append(
            f'\t\t{file_id} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};'
        )
        
        sources_section.append(
            f'\t\t\t\t{build_id} /* {filename} in Sources */,'
        )
    
    # Aggiungi le sezioni al progetto
    # 1. PBXBuildFile section
    content = content.replace(
        '/* End PBXBuildFile section */',
        '\n'.join(build_file_section) + '\n/* End PBXBuildFile section */'
    )
    
    # 2. PBXFileReference section
    content = content.replace(
        '/* End PBXFileReference section */',
        '\n'.join(file_ref_section) + '\n/* End PBXFileReference section */'
    )
    
    # 3. PBXSourcesBuildPhase section
    content = content.replace(
        '\t\t\t\tA1000002001 /* RootView.swift in Sources */,',
        '\t\t\t\tA1000002001 /* RootView.swift in Sources */,\n' + '\n'.join(sources_section)
    )
    
    # Backup del vecchio file
    backup_path = proj_path + ".backup"
    with open(backup_path, 'w') as f:
        f.write(content)
    
    # Scrivi il nuovo file
    with open(proj_path, 'w') as f:
        f.write(content)
    
    print(f"✅ Progetto aggiornato! ({len(swift_files)} file aggiunti)")
    print(f"💾 Backup salvato in: {backup_path}")
    print("\n⚠️  IMPORTANTE: Apri il progetto in Xcode e verifica che:")
    print("   1. Tutti i file siano visibili nel Project Navigator")
    print("   2. Build Phases > Compile Sources contenga tutti i file")
    print("   3. Se ci sono errori, ripristina il backup e aggiungi i file manualmente")

if __name__ == "__main__":
    main()
