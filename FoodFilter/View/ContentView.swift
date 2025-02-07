import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var scannerViewModel = ScannerViewModel()
    @State private var selectedTab: Tab = .activity
    @State private var isLoading: Bool = true

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGray6
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.blue]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            if let user = authViewModel.user, authViewModel.isAuthenticated {
                Group {
                    switch selectedTab {
                    case .activity:
                        ActivityView()
                    case .scanner:
                        ScannerView(
                            image: scannerViewModel.frame,
                            scannedBarcode: scannerViewModel.scannedBarcode,
                            ingredientsInfo: scannerViewModel.ingredientsInfo,
                            authViewModel: authViewModel
                        )
                    case .profile:
                        ProfileView(authViewModel: authViewModel, userModel: Binding(
                            get: { user },
                            set: { authViewModel.user = $0 }
                        ))
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                VStack {
                    Spacer()
                    HStack {
                        ForEach([Tab.activity, Tab.scanner, Tab.profile], id: \.self) { tab in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                                    
                                    Text(tab.rawValue)
                                        .font(.caption)
                                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                                }
                                .frame(width: 75)
                                .padding(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .frame(height: 80)
                }
            } else {
                SignInView(authViewModel: authViewModel)
            }

            if isLoading {
                LoadingView()
            }
        }
        .onAppear {
            // Simulate data loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.white.opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Loading...")
                    .font(.headline)
            }
        }
    }
}

enum Tab: String {
    case activity = "Activity"
    case scanner = "Scanner"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .activity: return "scroll"
        case .scanner: return "viewfinder"
        case .profile: return "person.crop.circle"
        }
    }
}
