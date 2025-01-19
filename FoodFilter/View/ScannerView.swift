import SwiftUI

struct ScannerView: View {
    var image: CGImage?
    var scannedBarcode: String?
    var ingredientsInfo: String?
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var dietaryResultBackground: Color = .black.opacity(0.5)
    @State private var dietaryResultTextColor: Color = .white
    
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
                
                if scannedBarcode != nil {
                    if let result = checkDietaryRestrictions() {
                        Text(result)
                            .font(.headline)
                            .foregroundColor(dietaryResultTextColor)
                            .padding()
                            .background(dietaryResultBackground)
                            .cornerRadius(8)
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity, alignment: .center)  // Dynamically adjusting the width
                            .padding(.horizontal, 20)  // Add some padding for better layout
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            DispatchQueue.main.async {
                if let _ = scannedBarcode {
                    _ = checkDietaryRestrictions()
                }
            }
        }
    }
    
    private func checkDietaryRestrictions() -> String? {
        guard let ingredients = ingredientsInfo?.lowercased().components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }),
              let restrictions = authViewModel.user?.dietaryRestrictions else {
            return nil
        }

        let restrictedIngredients = ingredients.filter { ingredient in
            restrictions.contains(where: { restriction in
                ingredient.contains(restriction.lowercased())
            })
        }

        if restrictedIngredients.isEmpty {
            DispatchQueue.main.async {
                dietaryResultBackground = Color.green
                alertMessage = "Good News: Product doesn't have any restricted ingredients."
            }
            return alertMessage
        } else {
            DispatchQueue.main.async {
                dietaryResultBackground = Color.red.opacity(0.7)
                alertMessage = "Warning: This product contains \(restrictedIngredients.joined(separator: ", "))"
            }
            return alertMessage
        }
    }
}
