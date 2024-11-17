import SwiftUI
import CoreLocation
import MapKit

struct ActiveRideView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingEndRideAlert = false
    @State private var isPaused = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingJourneyEdit = false
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
                            pauseRide()
                        } else {
                            resumeRide()
                        }
                    }) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            )
                    }
                    
                    // Stop Button
                    Button(action: {
                        showingEndRideAlert = true
                    }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            )
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            startRide()
        }
        .onChange(of: locationManager.currentLocation) { location in
            if let location = location {
                locationManager.reverseGeocode(location: location)
                weatherManager.fetchWeather(for: location)
            }
        }
        .alert("End Ride", isPresented: $showingEndRideAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Ride", role: .destructive) {
                endRide()
            }
        } message: {
            Text("Are you sure you want to end this ride?")
        }
        .fullScreenCover(isPresented: $showingJourneyEdit) {
            NavigationView {
                JourneyDetailView(journey: .constant(createJourneyFromRide()))
            }
        }
    }
    
    private func startRide() {
        locationManager.startTracking()
        startTimer()
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
        showingJourneyEdit = true
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
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
            title: "New Ride",
            date: Date(),
            distance: String(format: "%.1f mi", locationManager.calculateDistance() / 1609.34),
            location: locationManager.currentLocationName,
            weather: weatherManager.currentWeather ?? .sunny,
            mood: .good,
            road: .excellent,
            notes: "",
            isCompleted: true
        )
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