import AVFoundation
import CoreImage

class ScannerViewModel: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var scannedBarcode: String?
    @Published var ingredientsInfo: String = "Scan to see ingredients"
    
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [weak self] in
            self?.setupCaptureSession()
            self?.captureSession.startRunning()
        }
    }
}

extension ScannerViewModel {
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            self.permissionGranted = false
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if granted {
                    self?.sessionQueue.async {
                        self?.setupCaptureSession()
                        self?.captureSession.startRunning()
                    }
                }
            }
        }
    }
}

extension ScannerViewModel {
    func setupCaptureSession() {
        guard permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }
        
        // Video Output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        if let videoConnection = videoOutput.connection(with: .video) {
            if videoConnection.isVideoRotationAngleSupported(90) {
                videoConnection.videoRotationAngle = 90
            }
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .upce, .code128]
        }
    }

}

extension ScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
}

// Barcode Scanning
extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let scannedValue = metadataObject.stringValue {
            DispatchQueue.main.async { [weak self] in
                self?.scannedBarcode = scannedValue
                self?.captureSession.stopRunning()
                self?.fetchIngredientsInfo(for: scannedValue)
            }
        }
    }
}

// Fetch Item Ingredients from API
extension ScannerViewModel {
    func fetchIngredientsInfo(for barcode: String) {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json") else {
            DispatchQueue.main.async {
                self.ingredientsInfo = "Invalid barcode URL."
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.ingredientsInfo = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.ingredientsInfo = "No data received from server."
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let product = json["product"] as? [String: Any],
                   let ingredients = product["ingredients_text"] as? String {
                    DispatchQueue.main.async {
                        self.ingredientsInfo = "Ingredients: \(ingredients)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.ingredientsInfo = "No ingredients found for this product."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.ingredientsInfo = "Error parsing product data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
