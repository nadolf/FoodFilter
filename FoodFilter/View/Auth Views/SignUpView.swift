import SwiftUI

struct SignUpView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            // First Name Field
            TextField("First Name", text: $firstName)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
                .padding(.horizontal)

            // Last Name Field
            TextField("Last Name", text: $lastName)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
                .padding(.horizontal)

            // Email Field
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
                .padding(.horizontal)

            // Password Field
            if showPassword {
                TextField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
                    .padding(.horizontal)
            } else {
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
                    .padding(.horizontal)
            }
            
            // Confirm Password Field
            if showPassword {
                TextField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
                    .padding(.horizontal)
            } else {
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
                    .padding(.horizontal)
            }
            
            // Toggle to show/hide password
            HStack {
                Spacer()
                Toggle("Show Password", isOn: $showPassword)
                    .accentColor(.blue)
                    .padding(.horizontal)
            }
            
            // Sign Up Button
            Button(action: {
                handleSignUp()
            }) {
                Text("Create Account")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue) // Accent color for the button
                    .cornerRadius(10)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 5)
                    .padding(.horizontal)
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            
            Spacer()
            
            // Navigation to Sign In
            HStack {
                Text("Already have an account?")
                NavigationLink("Sign In", destination: SignInView(authViewModel: authViewModel))
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .padding(.top, 40)
    }
    
    private func handleSignUp() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            authViewModel.errorMessage = "Please fill in all fields."
            return
        }
        
        guard password == confirmPassword else {
            authViewModel.errorMessage = "Passwords do not match."
            return
        }
        
        let emptyDietaryRestrictions: [String] = []
        authViewModel.signUp(firstName: firstName, lastName: lastName, email: email, password: password, dietaryRestrictions: emptyDietaryRestrictions)
    }
}
