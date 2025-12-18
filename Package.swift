// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyNoleggioApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyNoleggioApp",
            targets: ["MyNoleggioApp"]
        )
    ],
    targets: [
        .target(
            name: "MyNoleggioApp",
            path: "MyNoleggioApp"
        )
    ]
)

