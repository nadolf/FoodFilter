import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var showAlert = false

    var body: some View {
        Form {
            Section(header: Text("Update Your Password")) {
                SecureField("Current Password", text: $currentPassword)
                
                SecureField("New Password", text: $newPassword)
                
                SecureField("Confirm New Password", text: $confirmPassword)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Section {
                Button(action: changePassword) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid() ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!isFormValid())
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Change Password")
        .alert("Password Updated", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private func isFormValid() -> Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }

    private func changePassword() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not logged in."
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Re-authentication failed: \(error.localizedDescription)"
            } else {
                // Update the password
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = "Password update failed: \(error.localizedDescription)"
                    } else {
                        errorMessage = nil
                        showAlert = true
                    }
                }
            }
        }
    }
}
