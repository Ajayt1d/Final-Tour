import SwiftUI
import Foundation

class JourneyStore: ObservableObject {
    static let shared = JourneyStore()
    @Published var journeys: [Journey] = []
    
    init() {
        loadSampleJourneys()
    }
    
    func addJourney(_ journey: Journey) {
        journeys.append(journey)
        save()
    }
    
    func save() {
        // Add actual save functionality if needed
        objectWillChange.send()
    }
    
    private func loadSampleJourneys() {
        journeys = [
            Journey(
                id: UUID(),
                title: "Peak District Adventure",
                date: Date().addingTimeInterval(-86400 * 2),
                distance: "156.3 mi",
                location: "Peak District National Park",
                weather: .sunny,
                mood: .amazing,
                road: .excellent,
                notes: "Epic ride through Snake Pass and Winnats Pass. Perfect weather and roads were clear.",
                isCompleted: true,
                duration: "4:23:15",
                averageSpeed: "35.7 mph",
                elevation: "3,245 ft"
            ),
            Journey(
                id: UUID(),
                title: "Coastal Run",
                date: Date().addingTimeInterval(-86400),
                distance: "89.5 mi",
                location: "Brighton to Dover",
                weather: .overcast,
                mood: .happy,
                road: .excellent,
                notes: "Beautiful coastal ride with stunning views. Bit windy but great fun!",
                isCompleted: true,
                duration: "2:15:30",
                averageSpeed: "39.8 mph",
                elevation: "1,890 ft"
            ),
            Journey(
                id: UUID(),
                title: "Morning Commute",
                date: Date().addingTimeInterval(-3600 * 3),
                distance: "12.4 mi",
                location: "London City",
                weather: .rainy,
                mood: .good,
                road: .caution,
                notes: "Quick ride to work. Light rain but traffic was okay.",
                isCompleted: true,
                duration: "0:45:20",
                averageSpeed: "16.5 mph",
                elevation: "420 ft"
            )
        ]
    }
} 