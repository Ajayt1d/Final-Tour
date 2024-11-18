import Foundation
import UIKit

struct JournalEntry: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var content: String
    var location: String
    var hasPhotos: Bool
    var mood: EntryMood
    var images: [UIImage]?
}

enum EntryMood: String, CaseIterable {
    case happy = "Happy"
    case tired = "Tired"
    case upset = "Upset"
    case angry = "Angry"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .tired: return "😴"
        case .upset: return "☹️"
        case .angry: return "😠"
        }
    }
} 