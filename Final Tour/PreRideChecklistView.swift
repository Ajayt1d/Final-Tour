import SwiftUI

struct ChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    var isRequired: Bool
    var isChecked: Bool
    var icon: String
}

struct PreRideChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checklistItems: [ChecklistItem] = [
        ChecklistItem(title: "Helmet & Gear", isRequired: true, isChecked: false, icon: "helmet"),
        ChecklistItem(title: "Weather Checked", isRequired: true, isChecked: false, icon: "cloud.sun"),
        ChecklistItem(title: "Bike Condition", isRequired: true, isChecked: false, icon: "wrench.and.screwdriver"),
        ChecklistItem(title: "Phone Charged", isRequired: true, isChecked: false, icon: "battery.100"),
        ChecklistItem(title: "First Aid Kit", isRequired: false, isChecked: false, icon: "cross.case"),
        ChecklistItem(title: "Water/Snacks", isRequired: false, isChecked: false, icon: "drop")
    ]
    
    @State private var customItems: [ChecklistItem] = []
    @State private var newItemTitle = ""
    @State private var showingLocationPermission = false
    @State private var showingCameraPermission = false
    
    var canStartRide: Bool {
        checklistItems.filter { $0.isRequired }.allSatisfy { $0.isChecked }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Required Items")) {
                    ForEach($checklistItems.filter { $0.isRequired.wrappedValue }) { $item in
                        ChecklistItemRow(item: $item)
                    }
                }
                
                Section(header: Text("Optional Items")) {
                    ForEach($checklistItems.filter { !$0.isRequired.wrappedValue }) { $item in
                        ChecklistItemRow(item: $item)
                    }
                }
                
                Section(header: Text("Custom Items")) {
                    ForEach($customItems) { $item in
                        ChecklistItemRow(item: $item)
                    }
                    
                    HStack {
                        TextField("Add new item", text: $newItemTitle)
                        Button(action: addCustomItem) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newItemTitle.isEmpty)
                    }
                }
                
                Section {
                    Button(action: {
                        requestPermissions()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Start Ride")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(canStartRide ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!canStartRide)
                }
            }
            .navigationTitle("Prepare for Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addCustomItem() {
        let newItem = ChecklistItem(
            title: newItemTitle,
            isRequired: false,
            isChecked: false,
            icon: "checkmark.circle"
        )
        customItems.append(newItem)
        newItemTitle = ""
    }
    
    private func requestPermissions() {
        // Request location permissions
        // Request camera/microphone permissions if needed
        // Start ride tracking
    }
}

struct ChecklistItemRow: View {
    @Binding var item: ChecklistItem
    
    var body: some View {
        HStack {
            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(item.isChecked ? .green : .gray)
                .onTapGesture {
                    item.isChecked.toggle()
                }
            
            Image(systemName: item.icon)
                .foregroundColor(.blue)
            
            Text(item.title)
            
            if item.isRequired {
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    PreRideChecklistView()
} 