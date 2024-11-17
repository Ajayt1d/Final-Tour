import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                title: "Journey",
                icon: "map",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarButton(
                title: "Journal",
                icon: "book",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabBarButton(
                title: "Directions",
                icon: "location.north",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabBarButton(
                title: "Memories",
                icon: "photo.on.rectangle",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            TabBarButton(
                title: "Profile",
                icon: "person",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.top, 10)
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
} 