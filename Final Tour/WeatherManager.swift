import Foundation
import CoreLocation

class WeatherManager: ObservableObject {
    @Published var currentWeather: Weather?
    private let apiKey = "YOUR_API_KEY" // You'll need to get an API key
    
    func fetchWeather(for location: CLLocation) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            if let decodedResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.currentWeather = self.mapWeather(from: decodedResponse)
                }
            }
        }.resume()
    }
    
    private func mapWeather(from response: WeatherResponse) -> Weather {
        // Map the API response to your Weather enum
        switch response.weather.first?.main.lowercased() {
        case "clear": return .sunny
        case "clouds": return .overcast
        case "rain": return .rainy
        case "thunderstorm": return .stormy
        case "snow": return .snow
        default: return .sunny
        }
    }
}

struct WeatherResponse: Codable {
    let weather: [WeatherData]
    
    struct WeatherData: Codable {
        let main: String
    }
} 