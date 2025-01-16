import Foundation

struct UserModel: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    var dietaryRestrictions: [String]
    
    init(id: String, firstName: String, lastName: String, email: String, dietaryRestrictions: [String] = []) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dietaryRestrictions = dietaryRestrictions
    }
}
