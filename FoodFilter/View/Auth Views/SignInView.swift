import SwiftUI

struct SignInView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Email Field
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .cornerRadius(8)
            
            // Password Field
            if showPassword {
                TextField("Password", text: $password)
            } else {
                SecureField("Password", text: $password)
            }
            
            Toggle("Show Password", isOn: $showPassword)
            
            // Sign In Button
            Button(action: {
                handleSignIn()
            }) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            // Error Message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
            
            // Navigation to Sign Up
            HStack {
                Text("Don't have an account?")
                NavigationLink("Sign Up", destination: SignUpView(authViewModel: authViewModel))
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding()
    }
    
    private func handleSignIn() {
        guard !email.isEmpty, !password.isEmpty else {
            authViewModel.errorMessage = "Please fill in all fields."
            return
        }
        
        authViewModel.signIn(email: email, password: password)
    }
}
