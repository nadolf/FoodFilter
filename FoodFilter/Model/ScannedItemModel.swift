import Foundation

struct ScannedItem: Identifiable, Codable {
    let id: String
    let name: String
    let ingredients: String
    let meetsDietaryNeeds: Bool
    let timestamp: Date
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "ingredients": ingredients,
            "meetsDietaryNeeds": meetsDietaryNeeds,
            "timestamp": timestamp
        ]
    }
}

