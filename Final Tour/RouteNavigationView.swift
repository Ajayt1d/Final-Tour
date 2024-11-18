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
            
            // Search Bars Overlay at top
            VStack {
                VStack(spacing: 12) {
                    // Start Location
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
                    
                    // End Location
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        TextField("Search destination", text: $endLocation)
                            .onTapGesture {
                                isSearchingEnd = true
                            }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                
                // Control Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        // Add stop action
                    }) {
                        Circle()
                            .fill(Color.blue)
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

// Add the search view
struct RouteLocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: String
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.self) { location in
                    Button(action: {
                        selectedLocation = location
                        dismiss()
                    }) {
                        Text(location)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                // Here we'll add actual location search later
                searchResults = ["London", "Manchester", "Birmingham", "Edinburgh"]
                    .filter { $0.lowercased().contains(newValue.lowercased()) }
            }
        }
    }
} 