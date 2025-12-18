#!/bin/bash

# Script di controllo pre-build per Codemagic
# Questo script verifica che tutto sia configurato correttamente prima di uploadare su Codemagic

echo "🔍 Controllo configurazione progetto iOS..."
echo ""

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# 1. Verifica file codemagic.yaml
echo "📄 Controllo codemagic.yaml..."
if [ -f "codemagic.yaml" ]; then
    echo -e "${GREEN}✓${NC} codemagic.yaml presente"
    
    # Controlla se l'email è ancora quella di default
    if grep -q "your-email@example.com" codemagic.yaml; then
        echo -e "${YELLOW}⚠${NC} ATTENZIONE: Aggiorna l'email in codemagic.yaml"
        ((WARNINGS++))
    fi
    
    # Controlla bundle ID
    if grep -q "com.mynoleggioapp.app" codemagic.yaml; then
        echo -e "${YELLOW}⚠${NC} ATTENZIONE: Considera di personalizzare il bundle ID"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗${NC} codemagic.yaml NON trovato"
    ((ERRORS++))
fi

# 2. Verifica progetto Xcode
echo ""
echo "📱 Controllo progetto Xcode..."
if [ -d "MyNoleggioApp.xcodeproj" ]; then
    echo -e "${GREEN}✓${NC} MyNoleggioApp.xcodeproj presente"
else
    echo -e "${RED}✗${NC} MyNoleggioApp.xcodeproj NON trovato"
    ((ERRORS++))
fi

# 3. Verifica Info.plist
echo ""
echo "📋 Controllo Info.plist..."
if [ -f "MyNoleggioApp/Info.plist" ]; then
    echo -e "${GREEN}✓${NC} Info.plist presente"
    
    # Controlla versione
    VERSION=$(grep -A1 "CFBundleShortVersionString" MyNoleggioApp/Info.plist | tail -1 | sed 's/<[^>]*>//g' | tr -d '\t ')
    BUILD=$(grep -A1 "CFBundleVersion" MyNoleggioApp/Info.plist | tail -1 | sed 's/<[^>]*>//g' | tr -d '\t ')
    echo "   Versione: $VERSION (Build: $BUILD)"
else
    echo -e "${RED}✗${NC} Info.plist NON trovato"
    ((ERRORS++))
fi

# 4. Verifica Assets
echo ""
echo "🎨 Controllo Assets..."
if [ -d "MyNoleggioApp/Assets.xcassets" ]; then
    echo -e "${GREEN}✓${NC} Assets.xcassets presente"
    
    if [ -d "MyNoleggioApp/Assets.xcassets/AppIcon.appiconset" ]; then
        echo -e "${GREEN}✓${NC} AppIcon presente"
    else
        echo -e "${YELLOW}⚠${NC} AppIcon non configurato"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗${NC} Assets.xcassets NON trovato"
    ((ERRORS++))
fi

# 5. Verifica file Swift principali
echo ""
echo "💻 Controllo file Swift..."
SWIFT_FILES=("MyNoleggioApp/App.swift" "MyNoleggioApp/RootView.swift")
for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $(basename $file) presente"
    else
        echo -e "${RED}✗${NC} $(basename $file) NON trovato"
        ((ERRORS++))
    fi
done

# 6. Conta file Swift totali
SWIFT_COUNT=$(find MyNoleggioApp -name "*.swift" -type f | wc -l)
echo "   Totale file Swift: $SWIFT_COUNT"

# 7. Verifica struttura Features
echo ""
echo "🗂️  Controllo struttura Features..."
FEATURES=("Login" "Clients" "Rentals" "BarcodeScanner" "ServerSetup")
for feature in "${FEATURES[@]}"; do
    if [ -d "MyNoleggioApp/Features/$feature" ]; then
        FILE_COUNT=$(find "MyNoleggioApp/Features/$feature" -name "*.swift" -type f | wc -l)
        echo -e "${GREEN}✓${NC} $feature ($FILE_COUNT files)"
    else
        echo -e "${YELLOW}⚠${NC} $feature non trovato"
    fi
done

# 8. Verifica .gitignore
echo ""
echo "🚫 Controllo .gitignore..."
if [ -f ".gitignore" ]; then
    echo -e "${GREEN}✓${NC} .gitignore presente"
else
    echo -e "${YELLOW}⚠${NC} .gitignore non presente (consigliato)"
    ((WARNINGS++))
fi

# 9. Verifica documentazione
echo ""
echo "📚 Controllo documentazione..."
DOC_FILES=("README_BUILD.md" "CODEMAGIC_SETUP.md")
for doc in "${DOC_FILES[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✓${NC} $doc presente"
    else
        echo -e "${YELLOW}⚠${NC} $doc non trovato"
    fi
done

# 10. Summary
echo ""
echo "═══════════════════════════════════════════"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Tutto OK! Pronto per Codemagic! 🚀${NC}"
    echo ""
    echo "Prossimi passi:"
    echo "1. Leggi CODEMAGIC_SETUP.md per le istruzioni dettagliate"
    echo "2. Carica il progetto su GitHub/GitLab/Bitbucket"
    echo "3. Connetti il repository a Codemagic"
    echo "4. Configura i certificati di code signing"
    echo "5. Avvia la build!"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warnings - Controlla i messaggi sopra${NC}"
    echo "Il progetto dovrebbe funzionare, ma considera di risolvere i warnings"
else
    echo -e "${RED}✗ $ERRORS errori trovati${NC}"
    echo "Correggi gli errori prima di procedere"
    exit 1
fi
echo "═══════════════════════════════════════════"
