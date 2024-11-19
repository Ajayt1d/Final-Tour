import SwiftUI

struct ProfileView: View {
    @StateObject private var journeyStore = JourneyStore.shared
    @State private var showingEditProfile = false
    @State private var showingImagePicker = false
    @State private var showingCameraSheet = false
    @State private var profileImage: UIImage?
    @AppStorage("userName") private var userName: String = "Rider"
    @AppStorage("location") private var location: String = "London, UK"
    @AppStorage("bikeModel") private var bikeModel: String = "Yamaha MT-07"
    @AppStorage("useMetric") private var useMetric: Bool = false
    
    var totalDistance: Double {
        journeyStore.journeys.reduce(0) { total, journey in
            let distance = Double(journey.distance.replacingOccurrences(of: " mi", with: "")) ?? 0
            return total + distance
        }
    }
    
    var averageDistance: Double {
        guard !journeyStore.journeys.isEmpty else { return 0 }
        return totalDistance / Double(journeyStore.journeys.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            Text("Profile")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header with editable image
                    VStack {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(editButton, alignment: .bottomTrailing)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .overlay(editButton, alignment: .bottomTrailing)
                        }
                        
                        Text(userName)
                            .font(.title)
                            .bold()
                        
                        Text(location)
                            .foregroundColor(.secondary)
                        
                        Text(bikeModel)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Statistics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            StatCard(title: "Total Distance", 
                                   value: String(format: "%.1f mi", totalDistance),
                                   emoji: "📏")
                            
                            StatCard(title: "Total Rides",
                                   value: "\(journeyStore.journeys.count)",
                                   emoji: "🏍")
                            
                            StatCard(title: "Average Distance",
                                   value: String(format: "%.1f mi", averageDistance),
                                   emoji: "📊")
                            
                            StatCard(title: "Longest Ride",
                                   value: findLongestRide(),
                                   emoji: "🏆")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Achievements
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Achievements")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                AchievementCard(title: "Century Rider",
                                              description: "Complete a 100+ mile ride",
                                              isAchieved: hasCompletedCenturyRide())
                                
                                AchievementCard(title: "Early Bird",
                                              description: "Start a ride before 6 AM",
                                              isAchieved: hasEarlyRide())
                                
                                AchievementCard(title: "Road Warrior",
                                              description: "Complete 10 rides",
                                              isAchieved: journeyStore.journeys.count >= 10)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            Toggle("Use Metric System", isOn: $useMetric)
                            
                            Button(action: {
                                showingEditProfile = true
                            }) {
                                Text("Edit Profile")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .confirmationDialog("Change Profile Picture", isPresented: $showingCameraSheet) {
            Button("Take Photo") {
                // Show camera
            }
            Button("Choose from Library") {
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingImagePicker) {
            ProfileImagePicker(selectedImage: Binding(
                get: { profileImage },
                set: { newImage in
                    if let image = newImage {
                        profileImage = image
                        // Save image to UserDefaults as Data
                        if let imageData = image.jpegData(compressionQuality: 0.7) {
                            UserDefaults.standard.set(imageData, forKey: "profileImage")
                        }
                    }
                }
            ))
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(
                userName: $userName,
                location: $location,
                bikeModel: $bikeModel
            )
        }
    }
    
    private var editButton: some View {
        Button(action: {
            showingCameraSheet = true
        }) {
            Image(systemName: "pencil.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .blue)
                .font(.system(size: 30))
                .background(Circle().fill(Color.white))
        }
    }
    
    // Add init to load saved profile image
    init() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            _profileImage = State(initialValue: savedImage)
        }
    }
    
    private func findLongestRide() -> String {
        let longest = journeyStore.journeys.max { a, b in
            (Double(a.distance.replacingOccurrences(of: " mi", with: "")) ?? 0) <
            (Double(b.distance.replacingOccurrences(of: " mi", with: "")) ?? 0)
        }
        return longest?.distance ?? "0 mi"
    }
    
    private func hasCompletedCenturyRide() -> Bool {
        journeyStore.journeys.contains { journey in
            (Double(journey.distance.replacingOccurrences(of: " mi", with: "")) ?? 0) >= 100
        }
    }
    
    private func hasEarlyRide() -> Bool {
        journeyStore.journeys.contains { journey in
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: journey.date)
            return hour < 6
        }
    }
}

struct AchievementCard: View {
    let title: String
    let description: String
    let isAchieved: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: isAchieved ? "trophy.fill" : "trophy")
                .font(.title)
                .foregroundColor(isAchieved ? .yellow : .gray)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var location: String
    @Binding var bikeModel: String
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    TextField("Name", text: $userName)
                    TextField("Location", text: $location)
                    TextField("Bike Model", text: $bikeModel)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 