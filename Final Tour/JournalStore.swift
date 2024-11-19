import SwiftUI
import Foundation

class JournalStore: ObservableObject {
    static let shared = JournalStore()
    @Published var entries: [JournalEntry] = []
    
    init() {
        loadSampleEntries()
    }
    
    private func loadSampleEntries() {
        entries = [
            JournalEntry(
                title: "Epic Weekend Ride",
                date: Date().addingTimeInterval(-86400 * 2),
                content: "Had an amazing time exploring the Peak District. The weather was perfect and the roads were clear. Met some great fellow riders at the cafe stop.",
                location: "Peak District",
                hasPhotos: false,
                mood: .amazing,
                importedJourney: JourneyStore.shared.journeys[0]
            ),
            JournalEntry(
                title: "Coastal Adventure",
                date: Date().addingTimeInterval(-86400),
                content: "Beautiful ride along the coast. The sea breeze was refreshing and the views were spectacular. Stopped at a few viewpoints for photos.",
                location: "South Coast",
                hasPhotos: false,
                mood: .happy,
                importedJourney: JourneyStore.shared.journeys[1]
            ),
            JournalEntry(
                title: "Rainy Day Thoughts",
                date: Date().addingTimeInterval(-3600 * 3),
                content: "Despite the rain, it was a decent ride. The city has a different charm in the wet weather. Need to get new rain gear though!",
                location: "London",
                hasPhotos: false,
                mood: .good,
                importedJourney: JourneyStore.shared.journeys[2]
            ),
            JournalEntry(
                title: "Coffee and Thoughts",
                date: Date(),
                content: "Just reflecting on all the great rides lately. Can't wait for the weekend to get back out there!",
                location: "Home",
                hasPhotos: false,
                mood: .happy
            )
        ]
    }
} 