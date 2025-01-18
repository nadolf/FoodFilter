import SwiftUI
import Firebase

struct DietaryRestrictionsSelectionView: View {
    @Binding var userModel: UserModel
    @State private var multiSelection: Set<UUID>

    init(userModel: Binding<UserModel>) {
        _userModel = userModel
        _multiSelection = State(initialValue: Set(userModel.wrappedValue.dietaryRestrictions.map { restrictionName in
            Restrictions.first { $0.name == restrictionName }?.id ?? UUID()
        }))
    }

    var body: some View {
        NavigationView {
            VStack {
                List(Restrictions, selection: $multiSelection) { restriction in
                    Text(restriction.name)
                }
                .navigationTitle("Dietary Restrictions")
                .environment(\.editMode, .constant(.active))

                Button(action: saveDietaryRestrictions) {
                    Text("Save Selections")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Text("\(multiSelection.count) selections")
                    .padding(.top)
            }
        }
    }

    private func saveDietaryRestrictions() {
        let selectedRestrictions = Restrictions.filter { multiSelection.contains($0.id) }
            .map { $0.name }

        let db = Firestore.firestore()
        db.collection("users").document(userModel.id).setData(
            ["dietaryRestrictions": selectedRestrictions],
            merge: true
        ) { error in
            if let error = error {
                print("Error saving dietary restrictions: \(error.localizedDescription)")
            } else {
                print("Dietary restrictions saved successfully.")
                userModel.dietaryRestrictions = selectedRestrictions
            }
        }
    }
}
