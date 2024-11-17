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
    @State private var showingStartRideConfirmation = false
    @State private var showingIconPicker = false
    @State private var selectedIcon = "checkmark.circle"
    
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
                            
                            Button(action: {
                                if !newItemTitle.isEmpty {
                                    showingIconPicker = true
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .disabled(newItemTitle.isEmpty)
                        }
                    }
                }
                
                if !isEditing {
                    Section {
                        Button(action: {
                            showingStartRideConfirmation = true
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
            .confirmationDialog(
                "Start Ride",
                isPresented: $showingStartRideConfirmation,
                titleVisibility: .visible
            ) {
                Button("Start Ride", role: .none) {
                    requestPermissions()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you ready to begin your ride? Make sure you have everything you need.")
            }
            .sheet(isPresented: $showingIconPicker) {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Essential Gear Section
                            VStack(alignment: .leading) {
                                Text("Essential Gear")
                                    .font(.headline)
                                    .padding(.horizontal)
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 60))
                                ], spacing: 15) {
                                    ForEach(["checkmark.circle.fill", "wrench.fill", "screwdriver.fill", "hammer.fill"], id: \.self) { icon in
                                        IconButton(icon: icon, isSelected: selectedIcon == icon) {
                                            selectedIcon = icon
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Camping Gear Section
                            VStack(alignment: .leading) {
                                Text("Camping")
                                    .font(.headline)
                                    .padding(.horizontal)
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 60))
                                ], spacing: 15) {
                                    ForEach(["tent.fill", "flashlight.on.fill", "flame.fill", "bed.double.fill"], id: \.self) { icon in
                                        IconButton(icon: icon, isSelected: selectedIcon == icon) {
                                            selectedIcon = icon
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Medical Section
                            VStack(alignment: .leading) {
                                Text("Medical")
                                    .font(.headline)
                                    .padding(.horizontal)
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 60))
                                ], spacing: 15) {
                                    ForEach(["cross.case.fill", "pills.fill", "syringe.fill", "bandage.fill"], id: \.self) { icon in
                                        IconButton(icon: icon, isSelected: selectedIcon == icon) {
                                            selectedIcon = icon
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Essentials Section
                            VStack(alignment: .leading) {
                                Text("Essentials")
                                    .font(.headline)
                                    .padding(.horizontal)
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 60))
                                ], spacing: 15) {
                                    ForEach(["drop.fill", "fork.knife", "tshirt.fill", "umbrella.fill"], id: \.self) { icon in
                                        IconButton(icon: icon, isSelected: selectedIcon == icon) {
                                            selectedIcon = icon
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Electronics Section
                            VStack(alignment: .leading) {
                                Text("Electronics")
                                    .font(.headline)
                                    .padding(.horizontal)
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 60))
                                ], spacing: 15) {
                                    ForEach(["laptopcomputer", "keyboard", "headphones"], id: \.self) { icon in
                                        IconButton(icon: icon, isSelected: selectedIcon == icon) {
                                            selectedIcon = icon
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Documents Section
                            VStack(alignment: .leading) {
                                Text("Documents")
                                    .font(.headline)
                                    .padding(.horizontal)
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 60))
                                ], spacing: 15) {
                                    ForEach(["doc.fill", "creditcard.fill", "key.fill", "map.fill"], id: \.self) { icon in
                                        IconButton(icon: icon, isSelected: selectedIcon == icon) {
                                            selectedIcon = icon
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .navigationTitle("Select Icon")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                addCustomItem()
                                showingIconPicker = false
                            }
                        }
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
            icon: selectedIcon,
            isCustom: true
        )
        checklistItems.append(newItem)
        newItemTitle = ""
        selectedIcon = "wrench.fill"
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

struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    PreRideChecklistView(onStartRide: {})
} 