import SwiftUI

struct SignUpView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
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
            
            // Confirm Password Field
            if showPassword {
                TextField("Confirm Password", text: $confirmPassword)
            } else {
                SecureField("Confirm Password", text: $confirmPassword)
            }
            
            Toggle("Show Password", isOn: $showPassword)
            
            // Sign Up Button
            Button(action: {
                handleSignUp()
            }) {
                Text("Create Account")
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
            
            // Navigation to Sign In
            HStack {
                Text("Already have an account?")
                NavigationLink("Sign In", destination: SignInView(authViewModel: authViewModel))
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
    
    private func handleSignUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            authViewModel.errorMessage = "Please fill in all fields."
            return
        }
        
        guard password == confirmPassword else {
            authViewModel.errorMessage = "Passwords do not match."
            return
        }
        
        let emptyDietaryRestrictions: [String] = []
        authViewModel.signUp(email: email, password: password, dietaryRestrictions: emptyDietaryRestrictions)
    }
}
