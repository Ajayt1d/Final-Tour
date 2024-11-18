import Foundation
import CoreLocation

class JourneyStore: ObservableObject {
    @Published var journeys: [Journey] = []
    private let saveKey = "SavedJourneys"
    
    static let shared = JourneyStore()
    
    init() {
        journeys = []
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
    
    func addJourney(_ journey: Journey) {
        if !journeys.contains(where: { $0.id == journey.id }) {
            journeys.insert(journey, at: 0)
            save()
        }
    }
    
    func updateJourney(_ journey: Journey) {
        if let index = journeys.firstIndex(where: { $0.id == journey.id }) {
            journeys[index] = journey
            save()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(journeys) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
} 