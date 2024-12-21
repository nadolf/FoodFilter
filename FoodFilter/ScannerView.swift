import SwiftUI

struct ScannerView: View {
    var image: CGImage?
    var scannedBarcode: String?
    var ingredientsInfo: String?
    
    private let label = Text("frame")
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(image, scale: 1.0, orientation: .up, label: label)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Spacer()
                
                if let barcode = scannedBarcode {
                    Text("Scanned Barcode: \(barcode)")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                } else {
                    Text("Scanning for Barcode...")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                }
                
                if let details = ingredientsInfo {
                    Text(details)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    ScannerView()
}
