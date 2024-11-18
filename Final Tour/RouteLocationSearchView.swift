import SwiftUI
import MapKit

struct RouteLocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: String
    @State private var searchText = ""
    @StateObject private var searchCompleter = LocationSearchCompleter()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchCompleter.searchResults, id: \.self) { result in
                    Button(action: {
                        selectedLocation = result.title
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(result.title)
                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
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
                searchCompleter.search(query: newValue)
            }
        }
    }
} 