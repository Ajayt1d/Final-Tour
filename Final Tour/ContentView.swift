//
//  ContentView.swift
//  Final Tour
//
//  Created by AJAY Grant on 16/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var journeyStore = JourneyStore.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            JourneyView()
                .tag(0)
            
            JournalView()
                .tag(1)
            
            RouteNavigationView()
                .tag(2)
            
            ProfileView()
                .tag(3)
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
