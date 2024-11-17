import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastError: Error?
    @Published var isTracking = false
    @Published var routeLocations: [CLLocation] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        isTracking = true
        routeLocations.removeAll()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
    }
    
    func calculateDistance() -> Double {
        var distance = 0.0
        guard routeLocations.count > 1 else { return distance }
        
        for i in 0..<routeLocations.count-1 {
            distance += routeLocations[i].distance(from: routeLocations[i+1])
        }
        return distance
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        if isTracking {
            routeLocations.append(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error
    }
} 