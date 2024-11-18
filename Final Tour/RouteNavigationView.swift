import SwiftUI
import MapKit

struct RouteNavigationView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @StateObject private var locationManager = LocationManager()
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var startPlacemark: MKPlacemark?
    @State private var endPlacemark: MKPlacemark?
    @State private var isSearchingStart = false
    @State private var isSearchingEnd = false
    @State private var showingLocationOptions = false
    @State private var showingNavigationOptions = false
    @State private var stopLocations: [String] = []
    @State private var stopPlacemarks: [MKPlacemark] = []
    @State private var isSearchingStop = false
    
    private func createRouteURL() -> URL? {
        var urlString = "maps://?dirflg=d"
        
        // Add start location
        if startLocation != "Current Location", let start = startPlacemark {
            urlString += "&saddr=\(start.coordinate.latitude),\(start.coordinate.longitude)"
        }
        
        // Combine all locations (stops and final destination) into one array
        var allStops = stopPlacemarks
        if let end = endPlacemark {
            allStops.append(end)  // Add final destination as last stop
        }
        
        // Create route with all points
        if !allStops.isEmpty {
            let stopString = allStops.map { stop in
                "\(stop.coordinate.latitude),\(stop.coordinate.longitude)"
            }.joined(separator: "+to+")
            
            urlString += "&daddr=\(stopString)"
        }
        
        print("Debug - Full URL before encoding: \(urlString)")
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
    
    private func startNavigation() {
        var mapItems: [MKMapItem] = []
        
        // Start point
        if startLocation != "Current Location", let start = startPlacemark {
            mapItems.append(MKMapItem(placemark: start))
        } else {
            mapItems.append(MKMapItem.forCurrentLocation())
        }
        
        // Add stops
        for stop in stopPlacemarks {
            mapItems.append(MKMapItem(placemark: stop))
        }
        
        // Add destination
        if let end = endPlacemark {
            mapItems.append(MKMapItem(placemark: end))
        }
        
        // Launch Maps with all locations
        MKMapItem.openMaps(
            with: mapItems,
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                MKLaunchOptionsShowsTrafficKey: true
            ]
        )
    }
    
    var body: some View {
        ZStack {
            MapView(locationManager: locationManager, region: $region)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 12) {
                    // Start Location Button
                    Button(action: {
                        showingLocationOptions = true
                    }) {
                        LocationRowView(
                            icon: "location.circle.fill",
                            iconColor: .blue,
                            text: startLocation.isEmpty ? "Choose start location" : startLocation
                        )
                    }
                    
                    // Stops
                    ForEach(stopLocations.indices, id: \.self) { index in
                        LocationRowView(
                            icon: "mappin.and.ellipse",
                            iconColor: .orange,
                            text: stopLocations[index],
                            showDelete: true,
                            onDelete: {
                                stopLocations.remove(at: index)
                                stopPlacemarks.remove(at: index)
                            }
                        )
                    }
                    
                    // End Location Button (visually distinct but treated as a stop)
                    Button(action: {
                        isSearchingEnd = true
                    }) {
                        LocationRowView(
                            icon: "mappin.circle.fill",
                            iconColor: .red,
                            text: endLocation.isEmpty ? "Search destination" : endLocation
                        )
                    }
                }
                .padding()
                
                Spacer()
                
                HStack(spacing: 40) {
                    Button(action: {
                        isSearchingStop = true
                    }) {
                        Circle()
                            .fill(startLocation.isEmpty || endLocation.isEmpty ? Color.gray : Color.blue)
                            .frame(width: 70, height: 70)
                            .overlay(
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Stop")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                            )
                    }
                    .disabled(startLocation.isEmpty || endLocation.isEmpty)
                    
                    Button(action: {
                        showingNavigationOptions = true
                    }) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 70, height: 70)
                            .overlay(
                                VStack {
                                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                    Text("Navigate")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                            )
                    }
                    
                    Button(action: {
                        // Share action
                    }) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 70, height: 70)
                            .overlay(
                                VStack {
                                    Image(systemName: "square.and.arrow.up.circle.fill")
                                    Text("Share")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .actionSheet(isPresented: $showingLocationOptions) {
            ActionSheet(
                title: Text("Choose Start Location"),
                buttons: [
                    .default(Text("Use Current Location")) {
                        startLocation = "Current Location"
                    },
                    .default(Text("Search Location")) {
                        isSearchingStart = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $isSearchingStart) {
            RouteLocationSearchView(
                selectedLocation: $startLocation,
                selectedPlacemark: $startPlacemark
            )
        }
        .sheet(isPresented: $isSearchingEnd) {
            RouteLocationSearchView(
                selectedLocation: $endLocation,
                selectedPlacemark: $endPlacemark
            )
        }
        .sheet(isPresented: $isSearchingStop) {
            RouteLocationSearchView(
                selectedLocation: Binding(
                    get: { "" },
                    set: { newValue in
                        if !newValue.isEmpty {
                            stopLocations.append(newValue)
                        }
                    }
                ),
                selectedPlacemark: Binding(
                    get: { nil },
                    set: { newValue in
                        if let placemark = newValue {
                            stopPlacemarks.append(placemark)
                        }
                    }
                )
            )
        }
        .alert("Start Navigation", isPresented: $showingNavigationOptions) {
            Button("Navigate Only") {
                startNavigation()
            }
            
            Button("Navigate with Tracking") {
                locationManager.startTracking()
                startNavigation()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose how you would like to navigate")
        }
    }
}

// Helper view for consistent location row styling
struct LocationRowView: View {
    let icon: String
    let iconColor: Color
    let text: String
    var showDelete: Bool = false
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(text)
                .foregroundColor(text == "Search destination" ? .gray : .primary)
            Spacer()
            if showDelete {
                Button(action: { onDelete?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
} 