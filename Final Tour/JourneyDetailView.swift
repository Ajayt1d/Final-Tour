import SwiftUI

struct JourneyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var journey: Journey
    @State private var isEditing = false
    
    // Editing states
    @State private var editedTitle: String
    @State private var editedDistance: String
    @State private var editedLocation: String
    @State private var editedWeather: Weather
    @State private var editedMood: Mood
    @State private var editedRoad: Road
    @State private var editedNotes: String
    
    init(journey: Binding<Journey>) {
        self._journey = journey
        self._editedTitle = State(initialValue: journey.wrappedValue.title)
        self._editedDistance = State(initialValue: journey.wrappedValue.distance)
        self._editedLocation = State(initialValue: journey.wrappedValue.location)
        self._editedWeather = State(initialValue: journey.wrappedValue.weather)
        self._editedMood = State(initialValue: journey.wrappedValue.mood)
        self._editedRoad = State(initialValue: journey.wrappedValue.road)
        self._editedNotes = State(initialValue: journey.wrappedValue.notes)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isEditing {
                    editingView
                } else {
                    viewingView
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title Section
            VStack(alignment: .leading, spacing: 8) {
                Label("Journey Title", systemImage: "pencil")
                    .foregroundColor(.secondary)
                TextField("Title", text: $editedTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Stats Section
            VStack(alignment: .leading, spacing: 16) {
                // Distance
                VStack(alignment: .leading, spacing: 8) {
                    Label("Distance", systemImage: "speedometer")
                        .foregroundColor(.secondary)
                    TextField("Distance", text: $editedDistance)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Label("Location", systemImage: "location.fill")
                        .foregroundColor(.secondary)
                    TextField("Location", text: $editedLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // Conditions Section
            VStack(alignment: .leading, spacing: 16) {
                // Weather
                VStack(alignment: .leading, spacing: 8) {
                    Label("Weather", systemImage: "cloud.sun.fill")
                        .foregroundColor(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Weather.allCases, id: \.self) { weather in
                                WeatherButton(
                                    weather: weather,
                                    isSelected: editedWeather == weather,
                                    action: { editedWeather = weather }
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Mood
                VStack(alignment: .leading, spacing: 8) {
                    Label("Mood", systemImage: "face.smiling")
                        .foregroundColor(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                MoodButton(
                                    mood: mood,
                                    isSelected: editedMood == mood,
                                    action: { editedMood = mood }
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Road Condition
                VStack(alignment: .leading, spacing: 8) {
                    Label("Road Condition", systemImage: "road.lanes")
                        .foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        ForEach(Road.allCases, id: \.self) { road in
                            RoadConditionButton(
                                road: road,
                                isSelected: editedRoad == road,
                                action: { editedRoad = road }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Notes Section
            VStack(alignment: .leading, spacing: 8) {
                Label("Notes", systemImage: "note.text")
                    .foregroundColor(.secondary)
                TextEditor(text: $editedNotes)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
            }
        }
    }
    
    private var viewingView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(journey.title)
                        .font(.title)
                        .bold()
                    Spacer()
                    if journey.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
                
                Text(journey.date.formatted(date: .long, time: .shortened))
                    .foregroundColor(.secondary)
            }
            
            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // Distance
                StatCard(title: "Distance", value: journey.distance, emoji: "🏃‍♂️")
                
                // Location
                StatCard(title: "Location", value: journey.location, emoji: "🌍", color: .blue)
                
                // Weather
                StatCard(
                    title: "Weather",
                    value: journey.weather.rawValue,
                    emoji: journey.weather.emoji,
                    color: journey.weather.color
                )
                
                // Mood
                StatCard(
                    title: "Mood",
                    value: journey.mood.rawValue,
                    emoji: journey.mood.emoji,
                    color: journey.mood.color
                )
            }
            
            // Road Condition
            HStack {
                Image(systemName: journey.road.icon)
                    .foregroundColor(journey.road.color)
                Text(journey.road.rawValue)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            
            // Notes
            if !journey.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    Text(journey.notes)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func saveChanges() {
        journey.title = editedTitle
        journey.distance = editedDistance
        journey.location = editedLocation
        journey.weather = editedWeather
        journey.mood = editedMood
        journey.road = editedRoad
        journey.notes = editedNotes
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let emoji: String
    var color: Color = .primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                Text(emoji)
                    .font(.title3)
                Text(value)
                    .font(.headline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct RoadConditionButton: View {
    let road: Road
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: road.icon)
                    .font(.title2)
                Text(road.rawValue)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? road.color.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? road.color : .gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? road.color : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct WeatherButton: View {
    let weather: Weather
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(weather.emoji)
                    .font(.title2)
                Text(weather.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? weather.color.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? weather.color : .gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? weather.color : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.title2)
                Text(mood.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? mood.color.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? mood.color : .gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? mood.color : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
} 