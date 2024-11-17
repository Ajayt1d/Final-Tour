import SwiftUI
import CoreLocation
import MapKit

struct ActiveRideView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingEndRideAlert = false
    @State private var trackingMode = MapUserTrackingMode.follow
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode)
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
                        Text("00:00:00")
                            .font(.title2)
                            .bold()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding()
                
                Spacer()
                
                // End Ride Button
                Button(action: {
                    showingEndRideAlert = true
                }) {
                    Text("End Ride")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            locationManager.startTracking()
        }
        .alert("End Ride", isPresented: $showingEndRideAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Ride", role: .destructive) {
                locationManager.stopTracking()
                // Save ride data
            }
        } message: {
            Text("Are you sure you want to end this ride?")
        }
    }
} 