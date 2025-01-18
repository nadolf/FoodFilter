import SwiftUI
import FirebaseFirestore

struct ChangeEmailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var userModel: UserModel
    
    @State private var newEmail: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Current Email")){
                    HStack{
                        Text("Email:")
                        Spacer()
                        TextField("Enter new email", text: $newEmail)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.words)
                    }
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                Button(action: updateEmail) {
                    Text(isLoading ? "Updating..." : "Save Changes")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
            }
            .navigationTitle("Change Name")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                newEmail = userModel.email
            }
        }
    }
    
    private func updateEmail() {
        guard !newEmail.isEmpty else {
            errorMessage = "Fill out field"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        let userID = userModel.id
        
        db.collection("users").document(userID).updateData([
            "email": newEmail,
        ]) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error updating name: \(error.localizedDescription)"
            } else {
                userModel.email = newEmail
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
