import Foundation

struct Restriction: Identifiable {
    let id = UUID()
    let name: String
}

let Restrictions = [
    Restriction(name: "Milk"),
    Restriction(name: "Egg"),
    Restriction(name: "Peanuts"),
    Restriction(name: "Tree Nuts"),
    Restriction(name: "Fish"),
    Restriction(name: "Shellfish"),
    Restriction(name: "Soy"),
    Restriction(name: "Wheat"),
    Restriction(name: "Gelatin")
]
