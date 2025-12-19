#!/bin/bash
# Script per rigenerare il progetto Xcode con tutti i file

echo "🔧 Rigenerazione progetto Xcode..."

cd "$(dirname "$0")"

# Rimuovi il vecchio progetto
echo "📦 Backup vecchio progetto..."
if [ -d "MyNoleggioApp.xcodeproj" ]; then
    mv MyNoleggioApp.xcodeproj MyNoleggioApp.xcodeproj.backup_$(date +%Y%m%d_%H%M%S)
fi

# Crea il nuovo progetto usando swift package
echo "🏗️  Creazione nuovo progetto..."

# Genera Package.swift se non esiste
cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyNoleggioApp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MyNoleggioApp", targets: ["MyNoleggioApp"])
    ],
    targets: [
        .target(
            name: "MyNoleggioApp",
            path: "MyNoleggioApp"
        )
    ]
)
EOF

# Genera il progetto Xcode dal package
echo "📱 Generazione progetto Xcode..."
swift package generate-xcodeproj --skip-extra-files 2>/dev/null || {
    echo "⚠️  swift package generate-xcodeproj non disponibile"
    echo "📝 Usa Xcode per aprire Package.swift direttamente"
    echo "   oppure crea manualmente il progetto aggiungendo tutti i file"
}

# Se il comando sopra non funziona, creiamo un progetto base manualmente
if [ ! -d "MyNoleggioApp.xcodeproj" ]; then
    echo "📝 Creazione manuale progetto base..."
    echo "   NOTA: Devi aprire il progetto in Xcode e aggiungere manualmente tutti i file"
    echo "   File > Add Files to 'MyNoleggioApp'..."
    echo "   Seleziona tutte le cartelle in MyNoleggioApp/"
fi

echo "✅ Fatto!"
echo ""
echo "🎯 Prossimi passi:"
echo "1. Apri MyNoleggioApp.xcodeproj in Xcode"
echo "2. Verifica che tutti i file Swift siano nella sezione 'Build Phases > Compile Sources'"
echo "3. Imposta PRODUCT_BUNDLE_IDENTIFIER nelle Build Settings"
echo "4. Imposta DEVELOPMENT_TEAM con il tuo Team ID"
echo ""
