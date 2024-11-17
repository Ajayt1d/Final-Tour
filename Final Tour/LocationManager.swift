import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastError: Error?
    @Published var isTracking = false
    @Published var isPaused = false
    @Published var routeLocations: [CLLocation] = []
    @Published var totalDistance: Double = 0
    @Published var currentLocationName: String = ""
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        isTracking = true
        isPaused = false
        routeLocations.removeAll()
        totalDistance = 0
    }
    
    func pauseTracking() {
        locationManager.stopUpdatingLocation()
        isPaused = true
    }
    
    func resumeTracking() {
        locationManager.startUpdatingLocation()
        isPaused = false
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
        isPaused = false
    }
    
    func calculateDistance() -> Double {
        return totalDistance
    }
    
    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let location = [
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.currentLocationName = location
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        if isTracking && !isPaused {
            if let lastLocation = routeLocations.last {
                let distance = location.distance(from: lastLocation)
                totalDistance += distance
            }
            routeLocations.append(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error
    }
} 