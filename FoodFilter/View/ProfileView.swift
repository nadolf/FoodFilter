import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var userModel: UserModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account Settings")) {
                    NavigationLink(destination: ChangeNameView(authViewModel: authViewModel, userModel: $userModel)) {
                        Text("Change Name")
                    }
                    NavigationLink(destination: ChangeEmailView(authViewModel: authViewModel, userModel: $userModel)) {
                        Text("Change Email")
                    }
                    NavigationLink(destination: ChangePasswordView()) {
                        Text("Change Password")
                    }
                }
                
                Section(header: Text("Dietary Restrictions")) {
                    NavigationLink(destination: DietaryRestrictionsSelectionView(userModel: $userModel)) {
                        Text("Edit Dietary Restrictions")
                    }
                }
                
                Section {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}
