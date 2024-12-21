import SwiftUI

@main
struct FoodFilterApp: App {
    @StateObject private var model = ScannerViewModel()
    
    var body: some Scene {
        WindowGroup {
            ScannerView(
                image: model.frame,
                scannedBarcode: model.scannedBarcode,
                ingredientsInfo: model.ingredientsInfo
            )
            .ignoresSafeArea()
        }
    }
}
