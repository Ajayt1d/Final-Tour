import SwiftUI

struct JourneyView: View {
    @StateObject private var journeyStore = JourneyStore.shared
    @State private var showingPreRideChecklist = false
    
    var sortedJourneys: [Journey] {
        journeyStore.journeys.sorted { $0.date > $1.date }  // Sort by newest first
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            Text("Journey")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($sortedJourneys) { $journey in
                        JourneyCard(
                            journey: $journey,
                            onDelete: {
                                if let index = journeyStore.journeys.firstIndex(where: { $0.id == journey.id }) {
                                    journeyStore.journeys.remove(at: index)
                                    journeyStore.save()
                                }
                            }
                        )
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
            .padding(.bottom, -55)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .sheet(isPresented: $showingPreRideChecklist) {
            PreRideChecklistView()
        }
    }
}

struct JourneyCard: View {
    @Binding var journey: Journey
    let onDelete: () -> Void
    @State private var showingDetail = false
    @StateObject private var journeyStore = JourneyStore.shared
    
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
                JourneyDetailView(
                    journey: Binding(
                        get: { journey },
                        set: { newValue in
                            if let index = journeyStore.journeys.firstIndex(where: { $0.id == journey.id }) {
                                journeyStore.journeys[index] = newValue
                            }
                        }
                    ),
                    isFromJourneyMenu: true,
                    onDelete: {
                        if let index = journeyStore.journeys.firstIndex(where: { $0.id == journey.id }) {
                            journeyStore.journeys.remove(at: index)
                        }
                        showingDetail = false
                    }
                )
            }
        }
    }
}

#Preview {
    JourneyView()
} 