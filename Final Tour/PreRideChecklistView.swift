import SwiftUI

struct ChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var isRequired: Bool
    var isChecked: Bool
    var icon: String
    var isCustom: Bool
}

struct PreRideChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checklistItems: [ChecklistItem] = [
        ChecklistItem(title: "Helmet & Gear", isRequired: true, isChecked: false, icon: "helmet", isCustom: false),
        ChecklistItem(title: "Weather Checked", isRequired: true, isChecked: false, icon: "cloud.sun", isCustom: false),
        ChecklistItem(title: "Bike Condition", isRequired: true, isChecked: false, icon: "wrench.and.screwdriver", isCustom: false),
        ChecklistItem(title: "Phone Charged", isRequired: true, isChecked: false, icon: "battery.100", isCustom: false),
        ChecklistItem(title: "First Aid Kit", isRequired: false, isChecked: false, icon: "cross.case", isCustom: false),
        ChecklistItem(title: "Water/Snacks", isRequired: false, isChecked: false, icon: "drop", isCustom: false)
    ]
    
    @State private var newItemTitle = ""
    @State private var newItemRequired = false
    @State private var isEditing = false
    
    var canStartRide: Bool {
        checklistItems.filter { $0.isRequired }.allSatisfy { $0.isChecked }
    }
    
    var onStartRide: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Required Items")) {
                    ForEach($checklistItems.filter { $0.isRequired.wrappedValue }) { $item in
                        ChecklistItemRow(
                            item: $item,
                            onRequiredToggle: { newValue in
                                if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
                                    withAnimation {
                                        checklistItems[index].isRequired = newValue
                                    }
                                }
                            },
                            isEditing: isEditing
                        )
                    }
                    .onDelete { indices in
                        let requiredItems = checklistItems.filter { $0.isRequired }
                        for index in indices {
                            if let itemToDelete = requiredItems[safe: index],
                               let actualIndex = checklistItems.firstIndex(where: { $0.id == itemToDelete.id }) {
                                checklistItems.remove(at: actualIndex)
                            }
                        }
                    }
                }
                
                Section(header: Text("Optional Items")) {
                    ForEach($checklistItems.filter { !$0.isRequired.wrappedValue }) { $item in
                        ChecklistItemRow(
                            item: $item,
                            onRequiredToggle: { newValue in
                                if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
                                    withAnimation {
                                        checklistItems[index].isRequired = newValue
                                    }
                                }
                            },
                            isEditing: isEditing
                        )
                    }
                    .onDelete { indices in
                        let optionalItems = checklistItems.filter { !$0.isRequired }
                        for index in indices {
                            if let itemToDelete = optionalItems[safe: index],
                               let actualIndex = checklistItems.firstIndex(where: { $0.id == itemToDelete.id }) {
                                checklistItems.remove(at: actualIndex)
                            }
                        }
                    }
                    
                    if !isEditing {
                        HStack {
                            TextField("Add new item", text: $newItemTitle)
                            Button(action: addCustomItem) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .disabled(newItemTitle.isEmpty)
                        }
                    }
                }
                
                if !isEditing {
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
            }
            .navigationTitle("Prepare for Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
            }
            .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
        }
    }
    
    private func addCustomItem() {
        let newItem = ChecklistItem(
            title: newItemTitle,
            isRequired: false,
            isChecked: false,
            icon: "checkmark.circle",
            isCustom: true
        )
        checklistItems.append(newItem)
        newItemTitle = ""
        newItemRequired = false
    }
    
    private func requestPermissions() {
        let locationManager = LocationManager()
        locationManager.requestPermission()
        onStartRide()
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ChecklistItemRow: View {
    @Binding var item: ChecklistItem
    var onRequiredToggle: (Bool) -> Void
    var isEditing: Bool
    
    var body: some View {
        HStack {
            if !isEditing {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .green : .gray)
                    .onTapGesture {
                        item.isChecked.toggle()
                    }
            }
            
            Image(systemName: item.icon)
                .foregroundColor(.blue)
            
            Text(item.title)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    onRequiredToggle(!item.isRequired)
                }
            }) {
                Image(systemName: item.isRequired ? "star.fill" : "star")
                    .foregroundColor(item.isRequired ? .yellow : .gray)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    PreRideChecklistView(onStartRide: {})
} 