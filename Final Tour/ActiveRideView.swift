import SwiftUI
import CoreLocation
import MapKit

struct ActiveRideView: View {
    let onComplete: (Journey) -> Void
    var pendingNavigation: Bool = false
    var navigationAction: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var journeyStore = JourneyStore.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingEndRideAlert = false
    @State private var showingJourneyDetail = false
    @State private var currentJourney: Journey?
    @State private var isPaused = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var trackingMode = MapUserTrackingMode.follow
    
    var body: some View {
        ZStack {
            MapView(locationManager: locationManager, region: $region)
                .ignoresSafeArea()
            
            // Stats Overlay
            VStack {
                // Stats Card
                HStack {
                    VStack(alignment: .leading) {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f mi", locationManager.calculateDistance() / 1609.34))
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Duration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(timeString(from: elapsedTime))
                            .font(.title2)
                            .bold()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding()
                
                Spacer()
                
                // Control Buttons
                HStack(spacing: 20) {
                    // Pause/Resume Button
                    Button(action: {
                        isPaused.toggle()
                        if isPaused {
                            locationManager.stopTracking()
                        } else {
                            locationManager.startTracking()
                        }
                    }) {
                        Circle()
                            .fill(isPaused ? Color.green : Color.yellow)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                    .foregroundColor(.white)
                                    .font(.title)
                            )
                    }
                    
                    // Stop Button
                    Button(action: {
                        timer?.invalidate()
                        showingEndRideAlert = true
                    }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.white)
                                    .font(.title)
                            )
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            locationManager.startTracking()
            
            // If we have pending navigation, open Maps after a delay
            if pendingNavigation, let action = navigationAction {
                // Wait for tracking to fully start
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    action()
                }
            }
        }
        .onChange(of: locationManager.currentLocation) { location in
            if let location = location {
                locationManager.reverseGeocode(location: location)
                weatherManager.fetchWeather(for: location)
            }
        }
        .alert("End Ride", isPresented: $showingEndRideAlert) {
            Button("Cancel", role: .cancel) {
                startTimer()
            }
            Button("End Ride", role: .destructive) {
                endRide()
            }
        } message: {
            Text("Are you sure you want to end this ride?")
        }
        .sheet(isPresented: $showingJourneyDetail) {
            if let index = journeyStore.journeys.firstIndex(where: { $0.id == currentJourney?.id }) {
                NavigationView {
                    JourneyDetailView(
                        journey: Binding(
                            get: { journeyStore.journeys[index] },
                            set: { updatedJourney in
                                journeyStore.journeys[index] = updatedJourney
                            }
                        ),
                        isNewJourney: false,
                        isFromJourneyMenu: false,
                        onSave: { _ in
                            showingJourneyDetail = false
                            if let journey = currentJourney {
                                onComplete(journey)
                                dismiss()
                            }
                        }
                    )
                }
            }
        }
    }
    
    private func pauseRide() {
        locationManager.pauseTracking()
        timer?.invalidate()
    }
    
    private func resumeRide() {
        locationManager.resumeTracking()
        startTimer()
    }
    
    private func endRide() {
        timer?.invalidate()
        locationManager.stopTracking()
        
        // Create and save the journey
        let newJourney = createJourneyFromRide()
        journeyStore.addJourney(newJourney)
        
        // Set current journey and show detail
        currentJourney = newJourney
        showingJourneyDetail = true
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !isPaused {
                elapsedTime += 1
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func createJourneyFromRide() -> Journey {
        Journey(
            id: UUID(),
            title: "New Ride",
            date: Date(),
            distance: String(format: "%.1f mi", locationManager.calculateDistance() / 1609.34),
            location: locationManager.currentLocationName,
            weather: weatherManager.currentWeather ?? .sunny,
            mood: .good,
            road: .excellent,
            notes: "",
            isCompleted: true,
            duration: timeString(from: elapsedTime),
            averageSpeed: calculateAverageSpeed(),
            elevation: "0 ft",
            locationManager: locationManager,
            routeLocations: locationManager.routeLocations
        )
    }
    
    private func calculateAverageSpeed() -> String {
        let distanceInMiles = locationManager.calculateDistance() / 1609.34
        let hours = elapsedTime / 3600
        let averageSpeed = hours > 0 ? distanceInMiles / hours : 0
        return String(format: "%.1f mph", averageSpeed)
    }
}

struct MapPolyline: Shape {
    let coordinates: [CLLocationCoordinate2D]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard coordinates.count > 1 else { return path }
        
        let points = coordinates.map { coordinate -> CGPoint in
            let latitude = (coordinate.latitude + 90) / 180
            let longitude = (coordinate.longitude + 180) / 360
            return CGPoint(x: longitude * rect.width, y: latitude * rect.height)
        }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
} 