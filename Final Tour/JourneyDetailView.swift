import SwiftUI
import MapKit

struct JourneyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var journey: Journey
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedMood: Mood
    @State private var editedRoad: Road
    @State private var editedWeather: Weather
    @State private var region = MKCoordinateRegion()
    var isNewJourney: Bool
    var isFromJourneyMenu: Bool
    var onSave: ((Journey) -> Void)?
    var onDelete: (() -> Void)?
    
    init(journey: Binding<Journey>, 
         isNewJourney: Bool = false, 
         isFromJourneyMenu: Bool = false, 
         onSave: ((Journey) -> Void)? = nil, 
         onDelete: (() -> Void)? = nil) {
        self._journey = journey
        self.isNewJourney = isNewJourney
        self.isFromJourneyMenu = isFromJourneyMenu
        self.onSave = onSave
        self.onDelete = onDelete
        self._editedTitle = State(initialValue: journey.wrappedValue.title)
        self._editedContent = State(initialValue: journey.wrappedValue.notes)
        self._editedMood = State(initialValue: journey.wrappedValue.mood)
        self._editedRoad = State(initialValue: journey.wrappedValue.road)
        self._editedWeather = State(initialValue: journey.wrappedValue.weather)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let locationManager = journey.locationManager {
                    MapView(locationManager: locationManager, region: $region)
                        .frame(height: 300)
                        .cornerRadius(15)
                }
                
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
            ToolbarItem(placement: .navigationBarLeading) {
                if !isEditing && isFromJourneyMenu {
                    Button("Delete") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveChanges()
                        isEditing.toggle()
                        if isNewJourney {
                            dismiss()
                        }
                    } else {
                        isEditing.toggle()
                    }
                }
            }
        }
        .alert("Delete Journey", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
        }
        .onChange(of: isEditing) { newValue in
            if !newValue {
                saveChanges()
            }
        }
    }
    
    private func saveChanges() {
        withAnimation {
            journey.title = editedTitle
            journey.notes = editedContent
            journey.mood = editedMood
            journey.road = editedRoad
            journey.weather = editedWeather
            journey.isCompleted = true
            onSave?(journey)
        }
    }
    
    private var editingView: some View {
        VStack(spacing: 20) {
            TextField("Title", text: $editedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Weather Selection
            VStack(alignment: .leading) {
                Text("Weather")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Weather.allCases, id: \.self) { weather in
                            WeatherButton(
                                weather: weather,
                                isSelected: editedWeather == weather,
                                action: { editedWeather = weather }
                            )
                        }
                    }
                }
            }
            
            // Mood Selection
            VStack(alignment: .leading) {
                Text("Mood")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: editedMood == mood,
                                action: { editedMood = mood }
                            )
                        }
                    }
                }
            }
            
            // Road Condition Selection
            VStack(alignment: .leading) {
                Text("Road Condition")
                    .font(.headline)
                HStack {
                    ForEach(Road.allCases, id: \.self) { road in
                        RoadConditionButton(
                            road: road,
                            isSelected: editedRoad == road,
                            action: { editedRoad = road }
                        )
                    }
                }
            }
            
            // Notes
            VStack(alignment: .leading) {
                Text("Comments")
                    .font(.headline)
                TextEditor(text: $editedContent)
                    .frame(height: 100)
                    .padding(5)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
            }
        }
    }
    
    private var viewingView: some View {
        VStack(spacing: 20) {
            // Title
            Text(journey.title)
                .font(.title)
                .bold()
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(title: "Date", value: journey.date.formatted(date: .abbreviated, time: .shortened), emoji: "📅")
                StatCard(title: "Distance", value: journey.distance, emoji: "📏")
                StatCard(title: "Duration", value: journey.duration ?? "00:00", emoji: "⏱")
                StatCard(title: "Average Speed", value: journey.averageSpeed ?? "0 mph", emoji: "⚡️")
                StatCard(title: "Elevation Gain", value: journey.elevation ?? "0 ft", emoji: "️")
            }
            
            // Conditions
            HStack(spacing: 20) {
                VStack {
                    Text("Weather")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(journey.weather.emoji)
                        .font(.title)
                }
                
                VStack {
                    Text("Mood")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(journey.mood.emoji)
                        .font(.title)
                }
                
                VStack {
                    Text("Road")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(journey.road.emoji)
                        .font(.title)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
            
            // Notes
            VStack(alignment: .leading) {
                Text("Comments")
                    .font(.headline)
                Text(journey.notes.isEmpty ? "No comments yet" : journey.notes)
                    .foregroundColor(journey.notes.isEmpty ? .secondary : .primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
        }
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