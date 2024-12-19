import SwiftUI

@main
struct FoodFilterApp: App {
    @StateObject private var model = ScannerModelView()
    var body: some Scene {
        WindowGroup {
            ScannerView(image: model.frame)
                .ignoresSafeArea()
        }
    }
}
