import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var showSignIn = false
    @State private var scanLineOffset: CGFloat = -50
    
    private let duration: Double = 2.0

    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                ZStack {
                    HStack(spacing: 2) {
                        ForEach(0..<15) { index in
                            Rectangle()
                                .frame(width: 10, height: 150)
                                .foregroundColor(index % 2 == 0 ? .white : .blue) // Black and blue bars
                        }
                    }
                    .frame(width: 140)
                    
                    Rectangle()
                        .frame(width: 250, height: 5)
                        .foregroundColor(.red)
                        .offset(y: scanLineOffset)
                }
                
                Text("Food Filter")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                self.scanLineOffset = 70 // Move the scan line over the barcode
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation {
                    self.isActive = true
                }
                if authViewModel.isAuthenticated {
                    showSignIn = false
                } else {
                    showSignIn = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            if showSignIn {
                SignInView(authViewModel: authViewModel)
            } else {
                ContentView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
