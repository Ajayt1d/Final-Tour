import SwiftUI

struct JourneyStatsCard: View {
    let journey: Journey
    
    var body: some View {
        VStack(spacing: 20) {
            // Title & Date
            HStack {
                Text(journey.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(1)
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
                StatsItemCard(title: "Distance", value: journey.distance, emoji: "🏍")
                StatsItemCard(title: "Duration", value: journey.duration ?? "00:00", emoji: "⏱")
                StatsItemCard(title: "Average Speed", value: journey.averageSpeed ?? "0 mph", emoji: "⚡️")
                StatsItemCard(title: "Location", value: journey.location, emoji: "📍")
            }
            .frame(maxWidth: .infinity)
            
            // Conditions Row
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text(journey.weather.emoji)
                        .font(.system(size: 32))
                    Text("Weather")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text(journey.mood.emoji)
                        .font(.system(size: 32))
                    Text("Mood")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text(journey.road.emoji)
                        .font(.system(size: 32))
                    Text("Road")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width - 40)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
    }
}

// Renamed StatCard to StatsItemCard
private struct StatsItemCard: View {
    let title: String
    let value: String
    let emoji: String
    var color: Color = .primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.title3)
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
} 