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
    @State private var isSearchingStart = false
    @State private var isSearchingEnd = false
    @State private var showingLocationOptions = false
    
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
                        // Add stop action
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
                        // Navigate action
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
            RouteLocationSearchView(selectedLocation: $startLocation)
        }
        .sheet(isPresented: $isSearchingEnd) {
            RouteLocationSearchView(selectedLocation: $endLocation)
        }
    }
} 