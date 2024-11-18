import SwiftUI

struct JourneyStatsCard: View {
    let journey: Journey
    
    var body: some View {
        VStack(spacing: 15) {
            // Title & Date
            HStack {
                Text(journey.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text(journey.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(title: "Distance", value: journey.distance, emoji: "🏍")
                StatCard(title: "Duration", value: journey.duration ?? "00:00", emoji: "⏱")
                StatCard(title: "Average Speed", value: journey.averageSpeed ?? "0 mph", emoji: "⚡️")
                StatCard(title: "Location", value: journey.location, emoji: "📍")
            }
            
            // Conditions Row
            HStack(spacing: 20) {
                VStack {
                    Text("Weather")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(journey.weather.emoji)
                        .font(.title)
                }
                
                VStack {
                    Text("Mood")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(journey.mood.emoji)
                        .font(.title)
                }
                
                VStack {
                    Text("Road")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(journey.road.emoji)
                        .font(.title)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
} 