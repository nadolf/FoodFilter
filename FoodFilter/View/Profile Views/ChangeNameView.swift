import SwiftUI
import FirebaseFirestore

struct ChangeNameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var userModel: UserModel
    
    @State private var newFirstName: String = ""
    @State private var newLastName: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Current Name")) {
                    HStack {
                        Text("First Name:")
                        Spacer()
                        TextField("Enter first name", text: $newFirstName)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.words)
                                        }
                    HStack {
                        Text("Last Name:")
                        Spacer()
                        TextField("Enter last name", text: $newLastName)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.words)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: updateName) {
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
                newFirstName = userModel.firstName
                newLastName = userModel.lastName
            }
        }
    }
    
    private func updateName() {
        guard !newFirstName.isEmpty, !newLastName.isEmpty else {
            errorMessage = "Both fields are required."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        let userID = userModel.id
        
        db.collection("users").document(userID).updateData([
            "firstName": newFirstName,
            "lastName": newLastName
        ]) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error updating name: \(error.localizedDescription)"
            } else {
                // Update the local user model
                userModel.firstName = newFirstName
                userModel.lastName = newLastName
                authViewModel.user?.firstName = newFirstName
                authViewModel.user?.lastName = newLastName
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
