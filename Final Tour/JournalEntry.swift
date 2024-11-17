import Foundation

struct JournalEntry: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var content: String
    var location: String
    var hasPhotos: Bool
    var mood: EntryMood
}

enum EntryMood: String, CaseIterable {
    case amazing = "Amazing 🤩"
    case happy = "Happy 😊"
    case okay = "Okay 😌"
    case tired = "Tired 😮‍💨"
    case rough = "Rough 😫"
    
    var emoji: String {
        switch self {
        case .amazing: return "🤩"
        case .happy: return "😊"
        case .okay: return "😌"
        case .tired: return "😮‍💨"
        case .rough: return "😫"
        }
    }
} 