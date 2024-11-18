import SwiftUI
import CoreLocation

struct Journey: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var distance: String
    var location: String
    var weather: Weather
    var mood: Mood
    var road: Road
    var notes: String
    var isCompleted: Bool
    
    var duration: String?
    var averageSpeed: String?
    var elevation: String?
    
    // These properties can't be directly encoded
    var locationManager: LocationManager?
    var routeLocations: [CLLocation]?
    var images: [Data]?
    
    // Coding keys to exclude non-codable properties
    enum CodingKeys: String, CodingKey {
        case id, title, date, distance, location, weather, mood, road, notes, isCompleted
        case duration, averageSpeed, elevation, images
    }
}

enum Weather: String, CaseIterable, Codable {
    case sunny = "Sunny"
    case overcast = "Overcast"
    case rainy = "Rainy"
    case stormy = "Stormy"
    case lightning = "Lightning"
    case snow = "Snow"
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .overcast: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .stormy: return "cloud.bolt.rain.fill"
        case .lightning: return "cloud.bolt.fill"
        case .snow: return "cloud.snow.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .overcast: return "☁️"
        case .rainy: return "🌧"
        case .stormy: return "⛈"
        case .lightning: return "⚡️"
        case .snow: return "🌨"
        }
    }
    
    var color: Color {
        switch self {
        case .sunny: return .yellow
        case .overcast: return .gray
        case .rainy: return .blue
        case .stormy: return .purple
        case .lightning: return .orange
        case .snow: return .cyan
        }
    }
}

enum Mood: String, CaseIterable, Codable {
    case amazing = "Amazing"
    case happy = "Happy"
    case good = "Good"
    case meh = "Meh"
    case tired = "Tired"
    case rough = "Rough"
    
    var icon: String {
        switch self {
        case .amazing: return "star.fill"
        case .happy: return "heart.fill"
        case .good: return "hand.thumbsup.fill"
        case .meh: return "face.smiling"
        case .tired: return "zzz"
        case .rough: return "hand.thumbsdown.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .amazing: return "💫"
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
        case .happy: return .pink
        case .good: return .green
        case .meh: return .orange
        case .tired, .rough: return .red
        }
    }
}

enum Road: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case caution = "Caution"
    case poor = "Poor"
    
    var icon: String {
        switch self {
        case .excellent: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .poor: return "xmark.circle.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .excellent: return "✅"
        case .caution: return "⚠️"
        case .poor: return "❌"
        }
    }
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .caution: return .yellow
        case .poor: return .red
        }
    }
} 