import SwiftUI
import FirebaseFirestore

struct ActivityView: View {
    @State private var scannedItems: [ScannedItem] = []
    @State private var isLoading = true
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case meetsDietary = "Good"
        case doesNotMeetDietary = "Bad"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilterOption.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.top, .horizontal])
                .cornerRadius(10)
                
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding()
                } else if scannedItems.isEmpty {
                    Text("No scanned items yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        if selectedFilter == .all {
                            ForEach(scannedItems) { item in
                                ScannedItemView(item: item)
                                    .listRowSeparator(.hidden)
                                    .background(Color.clear)
                            }
                        }
                        
                        if selectedFilter == .meetsDietary {
                            ForEach(scannedItems.filter { $0.meetsDietaryNeeds }) { item in
                                ScannedItemView(item: item)
                                    .listRowSeparator(.hidden)
                                    .background(Color.clear)
                            }
                        }
                        
                        if selectedFilter == .doesNotMeetDietary {
                            ForEach(scannedItems.filter { !$0.meetsDietaryNeeds }) { item in
                                ScannedItemView(item: item)
                                    .listRowSeparator(.hidden)
                                    .background(Color.clear)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchScannedItems()
            }
        }
    }
    
    private func fetchScannedItems() {
        let db = Firestore.firestore()
        db.collection("scannedItems").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching scanned items: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.isLoading = false
                return
            }
            
            self.scannedItems = documents.compactMap { doc -> ScannedItem? in
                let data = doc.data()
                guard let id = data["id"] as? String,
                      let name = data["name"] as? String,
                      let ingredients = data["ingredients"] as? String,
                      let meetsDietaryNeeds = data["meetsDietaryNeeds"] as? Bool,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    return nil
                }
                return ScannedItem(
                    id: id,
                    name: name,
                    ingredients: ingredients,
                    meetsDietaryNeeds: meetsDietaryNeeds,
                    timestamp: timestamp.dateValue()
                )
            }
            self.isLoading = false
        }
    }
}

struct ScannedItemView: View {
    var item: ScannedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Image(systemName: item.meetsDietaryNeeds ? "checkmark.circle.fill" : "x.circle.fill")
                    .foregroundColor(item.meetsDietaryNeeds ? .green : .red)
            }
            
            Text("Ingredients: \(item.ingredients)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Scanned on \(item.timestamp, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding([.top, .bottom], 8)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
