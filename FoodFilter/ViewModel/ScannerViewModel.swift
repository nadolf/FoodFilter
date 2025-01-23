import AVFoundation
import SwiftUICore
import CoreImage
import FirebaseFirestore

class ScannerViewModel: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var scannedBarcode: String?
    @Published var ingredientsInfo: String = "Scan to see ingredients"
    @Published var dietaryResultBackground: Color = .black.opacity(0.5)
    @Published var dietaryResultTextColor: Color = .white
    var dietaryRestrictions: [String] = []
    
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    private var isScanning = false
    private var isCameraRunning = true
    private var hasFetchedIngredients = false
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [weak self] in
            self?.setupCaptureSession()
            self?.captureSession.startRunning()
        }
    }
    
    func checkDietaryRestrictions(for ingredients: String) -> Bool {
        let ingredientList = ingredients.lowercased()
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let restrictedIngredients = ingredientList.filter { ingredient in
            dietaryRestrictions.contains(where: { restriction in
                ingredient.contains(restriction.lowercased())
            })
        }
        
        return restrictedIngredients.isEmpty
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
    
    func startStopCaptureSession() {
        sessionQueue.async { [weak self] in
            if self?.isCameraRunning ?? false {
                self?.captureSession.startRunning()
            } else {
                self?.captureSession.stopRunning()
            }
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
           let scannedValue = metadataObject.stringValue,
           !isScanning {
            isScanning = true
            DispatchQueue.main.async { [weak self] in
                self?.scannedBarcode = scannedValue
                self?.isCameraRunning = false
                self?.hasFetchedIngredients = false
                self?.fetchIngredientsInfo(for: scannedValue)
                // Restart the camera after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.isCameraRunning = true
                    self?.resetScanner()
                    self?.isScanning = false
                }
            }
        }
    }
}

// Fetch Item Ingredients from API
extension ScannerViewModel {
    func fetchIngredientsInfo(for barcode: String) {
        guard !hasFetchedIngredients else { return }
        hasFetchedIngredients = true
        
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
                   let productName = product["product_name"] as? String,
                   let ingredients = product["ingredients_text"] as? String {
                    
                    DispatchQueue.main.async {
                        self.ingredientsInfo = ingredients
                        let meetsDietaryNeeds = self.checkDietaryRestrictions(for: ingredients)
                        self.saveToDatabase(name: productName, ingredients: ingredients, meetsDietaryNeeds: meetsDietaryNeeds)
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

extension ScannerViewModel {
    func saveToDatabase(name: String, ingredients: String, meetsDietaryNeeds: Bool) {
        let db = Firestore.firestore()
        let scannedItem = ScannedItem(
            id: UUID().uuidString,
            name: name,
            ingredients: ingredients,
            meetsDietaryNeeds: meetsDietaryNeeds,
            timestamp: Date()
        )
        
        db.collection("scannedItems").addDocument(data: scannedItem.toDictionary()) { error in
            if let error = error {
                print("Error saving to database: \(error.localizedDescription)")
            } else {
                print("Scanned item saved successfully.")
            }
        }
    }
}

extension ScannerViewModel {
    func resetScanner() {
        scannedBarcode = nil
        ingredientsInfo = "Scan to see ingredients"
        dietaryResultBackground = .black.opacity(0.5)
        dietaryResultTextColor = .white
        hasFetchedIngredients = false
    }
}
