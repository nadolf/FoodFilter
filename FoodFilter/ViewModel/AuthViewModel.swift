import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let db = Firestore.firestore()
    
    init() {
        if let currentUser = Auth.auth().currentUser {
            fetchUserData(userID: currentUser.uid)
        }
    }
    
    func signUp(email: String, password: String, dietaryRestrictions: [String]) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else if let authUser = result?.user {
                let newUser = UserModel(id: authUser.uid, email: email, dietaryRestrictions: dietaryRestrictions)
                self?.saveUserToFirestore(user: newUser)
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else if let authUser = result?.user {
                self?.fetchUserData(userID: authUser.uid)
            }
        }
    }

    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func fetchUserData(userID: String) {
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else if let document = document, document.exists {
                let data = document.data()
                let email = data?["email"] as? String ?? ""
                let dietaryRestrictions = data?["dietaryRestrictions"] as? [String] ?? []
                
                self?.user = UserModel(id: userID, email: email, dietaryRestrictions: dietaryRestrictions)
                self?.isAuthenticated = true
            }
        }
    }
    
    private func saveUserToFirestore(user: UserModel) {
        db.collection("users").document(user.id).setData([
            "email": user.email,
            "dietaryRestrictions": user.dietaryRestrictions
        ]) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.user = user
                self?.isAuthenticated = true
            }
        }
    }
}
