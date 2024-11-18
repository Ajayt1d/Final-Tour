import SwiftUI

struct JourneyView: View {
    @State private var entries: [JournalEntry] = [
        JournalEntry(
            title: "Great Morning Ride",
            date: Date(),
            content: "Had an amazing ride through the city...",
            location: "Edinburgh",
            hasPhotos: false,
            mood: .happy,
            images: nil
        )
    ]
    @StateObject private var journeyStore = JourneyStore.shared
    @State private var showingPreRideChecklist = false
    @State private var showingActiveRide = false
    @State private var showingJourneyDetail = false
    @State private var selectedJourney: Journey?
    
    var body: some View {
        VStack {
            // Header
            Text("Journey")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            // Journey List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($journeyStore.journeys) { $journey in
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
            .padding(.vertical, 10)
        }
        .sheet(isPresented: $showingPreRideChecklist) {
            PreRideChecklistView(onStartRide: {
                showingPreRideChecklist = false
                showingActiveRide = true
            })
        }
        .fullScreenCover(isPresented: $showingActiveRide) {
            ActiveRideView { newJourney in
                showingActiveRide = false
            }
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