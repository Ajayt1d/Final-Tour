import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Journey Tab
            TabBarButton(
                icon: "figure.walk",
                text: "Journey",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            Spacer()
            
            // Journal Tab
            TabBarButton(
                icon: "book.fill",
                text: "Journal",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            Spacer()
            
            // Navigation Tab
            TabBarButton(
                icon: "map.fill",
                text: "Navigation",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            Spacer()
            
            // Profile Tab
            TabBarButton(
                icon: "person.fill",
                text: "Profile",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

struct TabBarButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(text)
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