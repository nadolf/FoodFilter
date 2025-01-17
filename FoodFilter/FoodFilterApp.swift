import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FoodFilterApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var scannerViewModel = ScannerViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if authViewModel.isAuthenticated {
                    ContentView()
                        .environmentObject(authViewModel)
                        .environmentObject(scannerViewModel)
                } else {
                    SignInView(authViewModel: authViewModel)
                }
            }
            .ignoresSafeArea()
        }
    }
}
