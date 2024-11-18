import SwiftUI
import MapKit

struct RouteNavigationView: View {
    @State private var startLocation: String = ""
    @State private var endLocation: String = ""
    @State private var isSearchingStart = false
    @State private var isSearchingEnd = false
    @State private var showingLocationOptions = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Start Location Section
            VStack(alignment: .leading) {
                Text("Start Location")
                    .font(.headline)
                
                Button(action: {
                    showingLocationOptions = true
                }) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                        Text(startLocation.isEmpty ? "Choose start location" : startLocation)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            
            // End Location Section
            VStack(alignment: .leading) {
                Text("End Location")
                    .font(.headline)
                
                TextField("Search destination", text: $endLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onTapGesture {
                        isSearchingEnd = true
                    }
            }
            
            Spacer()
            
            // Bottom Buttons
            HStack(spacing: 15) {
                Button(action: {
                    // Add stop action
                }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Stop")
                    }
                }
                
                Button(action: {
                    // Navigate action
                }) {
                    VStack {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        Text("Navigate")
                    }
                }
                
                Button(action: {
                    // Share action
                }) {
                    VStack {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                        Text("Share")
                    }
                }
            }
            .padding()
        }
        .padding()
        .actionSheet(isPresented: $showingLocationOptions) {
            ActionSheet(
                title: Text("Choose Start Location"),
                buttons: [
                    .default(Text("Use Current Location")) {
                        // Handle current location
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
        }
    }
} 