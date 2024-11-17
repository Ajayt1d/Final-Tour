import SwiftUI

struct JourneyView: View {
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
                    JourneyCard(title: "New Ride", 
                              distance: "0.0 mi",
                              date: "14 Nov 2024 at 16:55",
                              weather: .sunny,
                              mood: .good)
                    
                    JourneyCard(title: "Scottish Highlands",
                              distance: "280 mi",
                              date: "2 days ago",
                              weather: .rainy,
                              mood: .bad)
                    
                    JourneyCard(title: "Alps Adventure",
                              distance: "450 mi",
                              date: "Last Week",
                              weather: .sunny,
                              mood: .good)
                }
                .padding()
            }
            
            // Start Ride Button
            Button(action: {
                // Add start ride action here
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
    }
}

struct JourneyCard: View {
    let title: String
    let distance: String
    let date: String
    let weather: Weather
    let mood: Mood
    
    var body: some View {
        HStack {
            // Left side - Title and Distance
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(distance)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .bold()
            }
            
            Spacer()
            
            // Right side - Date and Icons
            VStack(alignment: .trailing, spacing: 4) {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    // Weather Icon
                    Image(systemName: weatherIcon)
                        .foregroundColor(weatherColor)
                    
                    // Mood Icon
                    Image(systemName: moodIcon)
                        .foregroundColor(moodColor)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    // Helper properties for icons
    private var weatherIcon: String {
        switch weather {
        case .sunny: return "sun.max.fill"
        case .rainy: return "cloud.rain.fill"
        }
    }
    
    private var weatherColor: Color {
        switch weather {
        case .sunny: return .yellow
        case .rainy: return .blue
        }
    }
    
    private var moodIcon: String {
        switch mood {
        case .good: return "heart.fill"
        case .bad: return "hand.thumbsdown.fill"
        }
    }
    
    private var moodColor: Color {
        switch mood {
        case .good: return .red
        case .bad: return .red
        }
    }
}

enum Weather {
    case sunny, rainy
}

enum Mood {
    case good, bad
}

#Preview {
    JourneyView()
} 