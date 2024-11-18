import Foundation
import UIKit
import SwiftUI

struct JournalEntry: Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var content: String
    var location: String
    var hasPhotos: Bool
    var mood: EntryMood
    var images: [UIImage]?
    var importedJourney: Journey?
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        content: String = "",
        location: String = "",
        hasPhotos: Bool = false,
        mood: EntryMood = .happy,
        images: [UIImage]? = nil,
        importedJourney: Journey? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.content = content
        self.location = location
        self.hasPhotos = hasPhotos
        self.mood = mood
        self.images = images
        self.importedJourney = importedJourney
    }
    
    // Add CodingKeys to exclude non-codable properties
    enum CodingKeys: String, CodingKey {
        case id, title, date, content, location, hasPhotos, mood
        // Note: images and importedJourney are handled separately
    }
}

// Make EntryMood conform to Codable
enum EntryMood: String, CaseIterable, Codable {
    case amazing = "Amazing"
    case happy = "Happy"
    case good = "Good"
    case meh = "Meh"
    case tired = "Tired"
    case rough = "Rough"
    
    var emoji: String {
        switch self {
        case .amazing: return "🤩"
        case .happy: return "😊"
        case .good: return "😌"
        case .meh: return "😐"
        case .tired: return "😮‍💨"
        case .rough: return "😫"
        }
    }
    
    var color: Color {
        switch self {
        case .amazing: return .yellow
        case .happy: return .yellow
        case .good: return .green
        case .meh: return .orange
        case .tired: return .orange
        case .rough: return .red
        }
    }
} 