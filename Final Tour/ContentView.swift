//
//  ContentView.swift
//  Final Tour
//
//  Created by AJAY Grant on 16/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            JourneyView()
                .tag(0)
            
            JournalView()
                .tag(1)
            
            Text("Directions")  // Placeholder for now
                .tag(2)
            
            Text("Memories")    // Placeholder for now
                .tag(3)
            
            Text("Profile")     // Placeholder for now
                .tag(4)
        }
        .overlay(
            CustomTabBar(selectedTab: $selectedTab)
                .background(Color(.systemBackground))
                .shadow(radius: 2),
            alignment: .bottom
        )
    }
}

#Preview {
    ContentView()
}
