import SwiftUI

struct JourneyView: View {
    @State private var journeys: [Journey] = [
        Journey(
            title: "New Ride",
            date: Date(),
            distance: "0.0 mi",
            location: "Starting Point",
            weather: .sunny,
            mood: .amazing,
            road: .excellent,
            notes: "",
            isCompleted: false
        ),
        Journey(
            title: "Scottish Highlands",
            date: Date().addingTimeInterval(-172800),
            distance: "280 mi",
            location: "Glencoe",
            weather: .overcast,
            mood: .happy,
            road: .caution,
            notes: "Beautiful mountain roads, but watch for visibility",
            isCompleted: true
        ),
        Journey(
            title: "Alps Adventure",
            date: Date().addingTimeInterval(-604800),
            distance: "450 mi",
            location: "Swiss Alps",
            weather: .snow,
            mood: .tired,
            road: .poor,
            notes: "Challenging conditions but worth it",
            isCompleted: true
        )
    ]
    @State private var showingPreRideChecklist = false
    @State private var showingActiveRide = false
    
    var body: some View {
        VStack {
            // Header
            Text("Journey")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(.primary)
            
            // Journey List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($journeys) { $journey in
                        JourneyCard(journey: $journey)
                    }
                }
                .padding()
            }
            
            // Start Ride Button
            Button(action: {
                showingPreRideChecklist = true
            }) {
                Text("Start Ride")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .padding(.horizontal)
            }
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingPreRideChecklist) {
            PreRideChecklistView(onStartRide: {
                showingPreRideChecklist = false
                showingActiveRide = true
            })
        }
        .fullScreenCover(isPresented: $showingActiveRide) {
            ActiveRideView()
        }
    }
}

struct JourneyCard: View {
    @Binding var journey: Journey
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            // Left side - Title and Distance
            VStack(alignment: .leading, spacing: 4) {
                Text(journey.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(journey.distance)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .bold()
            }
            
            Spacer()
            
            // Right side - Icons and Status
            VStack(alignment: .trailing, spacing: 8) {
                Text(journey.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    // Weather Emoji
                    Text(journey.weather.emoji)
                    
                    // Mood Emoji
                    Text(journey.mood.emoji)
                    
                    // Road Condition Emoji
                    Text(journey.road.emoji)
                }
                .font(.title3)  // Make emojis slightly larger
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            NavigationView {
                JourneyDetailView(journey: $journey)
            }
        }
    }
}

#Preview {
    JourneyView()
} 