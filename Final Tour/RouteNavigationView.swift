import SwiftUI
import MapKit

struct RouteNavigationView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var stopLocations: [String] = []
    @State private var startPlacemark: MKPlacemark?
    @State private var endPlacemark: MKPlacemark?
    @State private var stopPlacemarks: [MKPlacemark] = []
    @State private var isSearchingStart = false
    @State private var isSearchingEnd = false
    @State private var isSearchingStop = false
    @State private var showingLocationOptions = false
    @State private var showingNavigationOptions = false
    @State private var showingPreRideChecklist = false
    @State private var showingActiveRide = false
    @State private var pendingNavigation = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingShareSheet = false
    
    private func startNavigation() {
        var mapItems: [MKMapItem] = []
        
        if startLocation != "Current Location", let start = startPlacemark {
            mapItems.append(MKMapItem(placemark: start))
        } else {
            mapItems.append(MKMapItem.forCurrentLocation())
        }
        
        for stop in stopPlacemarks {
            mapItems.append(MKMapItem(placemark: stop))
        }
        
        if let end = endPlacemark {
            mapItems.append(MKMapItem(placemark: end))
        }
        
        MKMapItem.openMaps(
            with: mapItems,
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                MKLaunchOptionsShowsTrafficKey: true
            ]
        )
    }
    
    private func createRouteText() -> String {
        var routeText = "Check out this route on Final Tour! 🏍\n\n"
        routeText += "From: \(startLocation)\n"
        if !stopLocations.isEmpty {
            routeText += "\nStops:\n"
            stopLocations.forEach { stop in
                routeText += "- \(stop)\n"
            }
        }
        routeText += "\nTo: \(endLocation)"
        return routeText
    }
    
    private func createShareableRoute() -> [Any] {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "maps.apple.com"
        
        var queryItems: [URLQueryItem] = []
        
        // Add start location
        if startLocation != "Current Location", let start = startPlacemark {
            queryItems.append(URLQueryItem(name: "saddr", value: "\(start.coordinate.latitude),\(start.coordinate.longitude)"))
        }
        
        // Create waypoints string including stops and destination
        var waypoints: [String] = []
        
        // Add stops
        for stop in stopPlacemarks {
            waypoints.append("\(stop.coordinate.latitude),\(stop.coordinate.longitude)")
        }
        
        // Add destination
        if let end = endPlacemark {
            waypoints.append("\(end.coordinate.latitude),\(end.coordinate.longitude)")
        }
        
        // Join waypoints with '+to:'
        if !waypoints.isEmpty {
            queryItems.append(URLQueryItem(name: "daddr", value: waypoints.joined(separator: "+to:")))
        }
        
        // Add driving mode
        queryItems.append(URLQueryItem(name: "dirflg", value: "d"))
        
        urlComponents.queryItems = queryItems
        
        var items: [Any] = [createRouteText()]
        if let url = urlComponents.url {
            items.append(url)
        }
        
        return items
    }
    
    var body: some View {
        ZStack {
            MapView(locationManager: locationManager, region: $region)
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 12) {
                    Button(action: {
                        showingLocationOptions = true
                    }) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.blue)
                            Text(startLocation.isEmpty ? "Choose start location" : startLocation)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                    
                    ForEach(stopLocations.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.orange)
                            Text(stopLocations[index])
                                .foregroundColor(.primary)
                            Spacer()
                            Button(action: {
                                stopLocations.remove(at: index)
                                stopPlacemarks.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isSearchingEnd = true
                    }) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text(endLocation.isEmpty ? "Search destination" : endLocation)
                                .foregroundColor(endLocation.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
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
                        showingShareSheet = true
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
                .padding(.bottom, -55)
            }
        }
        .alert("Start Navigation", isPresented: $showingNavigationOptions) {
            Button("Navigate Only") {
                startNavigation()
            }
            
            Button("Navigate with Tracking") {
                pendingNavigation = true
                showingPreRideChecklist = true
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose how you would like to navigate")
        }
        .sheet(isPresented: $showingPreRideChecklist) {
            PreRideChecklistView { 
                showingPreRideChecklist = false
                showingActiveRide = true
            }
        }
        .fullScreenCover(isPresented: $showingActiveRide) {
            ActiveRideView(
                onComplete: { journey in
                    showingActiveRide = false
                },
                pendingNavigation: pendingNavigation,
                navigationAction: {
                    startNavigation()
                    pendingNavigation = false
                }
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
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: createShareableRoute())
        }
        .actionSheet(isPresented: $showingLocationOptions) {
            ActionSheet(
                title: Text("Choose Start Location"),
                buttons: [
                    .default(Text("Use Current Location")) {
                        startLocation = "Current Location"
                        startPlacemark = nil
                    },
                    .default(Text("Search Location")) {
                        isSearchingStart = true
                    },
                    .cancel()
                ]
            )
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
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
