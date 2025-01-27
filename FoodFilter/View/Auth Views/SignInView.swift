import SwiftUI

struct SignInView: View {
    @ObservedObject var authViewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack(spacing: 24) {
                    // Title
                    Text("Sign In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

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

                    // Toggle to show/hide password
                    HStack {
                        Spacer()
                        Toggle("Show Password", isOn: $showPassword)
                            .accentColor(.blue)
                            .padding(.horizontal)
                    }

                    // Sign In Button
                    Button(action: {
                        handleSignIn()
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    // Error Message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }

                    HStack {
                        Text("Don't have an account?")
                        NavigationLink("Sign Up", destination: SignUpView(authViewModel: authViewModel))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    private func handleSignIn() {
        guard !email.isEmpty, !password.isEmpty else {
            authViewModel.errorMessage = "Please fill in all fields."
            return
        }
        authViewModel.signIn(email: email, password: password)
    }
}
