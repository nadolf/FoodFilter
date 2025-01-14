import Foundation

struct UserModel: Identifiable, Codable {
    let id: String
    let email: String
    var dietaryRestrictions: [String]
    
    init(id: String, email: String, dietaryRestrictions: [String] = []) {
        self.id = id
        self.email = email
        self.dietaryRestrictions = dietaryRestrictions
    }
}
