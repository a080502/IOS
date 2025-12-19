import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Binding var isPresented: Bool
    let onBarcodeScanned: (String) -> Void
    
    @StateObject private var scanner = BarcodeScannerViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview
                if scanner.hasPermission {
                    CameraPreview(session: scanner.session)
                        .ignoresSafeArea()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                        Text("Permesso fotocamera necessario")
                        Button("Richiedi permesso") {
                            scanner.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                // Overlay with scanning area
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(width: 250, height: 250)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .navigationTitle("Scansiona QR/Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                if scanner.hasPermission {
                    scanner.startScanning { barcode in
                        onBarcodeScanned(barcode)
                        isPresented = false
                    }
                }
            }
            .onChange(of: scanner.hasPermission) { oldValue, newValue in
                if newValue {
                    scanner.startScanning { barcode in
                        onBarcodeScanned(barcode)
                        isPresented = false
                    }
                }
            }
            .onDisappear {
                scanner.stopScanning()
            }
        }
    }
}

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = context.coordinator.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Barcode Scanner ViewModel

@MainActor
final class BarcodeScannerViewModel: NSObject, ObservableObject {
    @Published var hasPermission = false
    
    let session = AVCaptureSession()
    private var metadataOutput = AVCaptureMetadataOutput()
    private var onBarcodeScanned: ((String) -> Void)?
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                if granted {
                    self?.setupCamera()
                }
            }
        }
    }
    
    private func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        hasPermission = status == .authorized
        if hasPermission {
            setupCamera()
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .qr,
                .ean13,
                .ean8,
                .code128,
                .code39,
                .code93,
                .upce,
                .pdf417
            ]
        }
    }
    
    func startScanning(onBarcodeScanned: @escaping (String) -> Void) {
        self.onBarcodeScanned = onBarcodeScanned
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }
    
    func stopScanning() {
        if session.isRunning {
            session.stopRunning()
        }
    }
}

extension BarcodeScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = metadataObject.stringValue else {
            return
        }
        
        stopScanning()
        onBarcodeScanned?(barcode)
    }
}

