import SwiftUI
import MapKit

struct LocationWrapper: Identifiable {
    let id = UUID()
    let location: CLLocation
}

struct MapView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var region: MKCoordinateRegion
    @State private var trackingMode = MapUserTrackingMode.follow
    
    private var locationWrappers: [LocationWrapper] {
        locationManager.routeLocations.map { LocationWrapper(location: $0) }
    }
    
    var body: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            userTrackingMode: $trackingMode)
            .overlay(
                RoutePolyline(locations: locationManager.routeLocations)
                    .stroke(.blue, lineWidth: 4)
            )
            .onAppear {
                locationManager.requestPermission()
            }
    }
}

struct RoutePolyline: Shape {
    let locations: [CLLocation]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard locations.count > 1 else { return path }
        
        let points = locations.map { location -> CGPoint in
            let coordinate = location.coordinate
            let latitude = (coordinate.latitude + 90) / 180
            let longitude = (coordinate.longitude + 180) / 360
            return CGPoint(x: longitude * rect.width, y: latitude * rect.height)
        }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
} 