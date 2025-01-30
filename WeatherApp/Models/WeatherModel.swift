import Foundation

// Ana hava durumu modeli
struct WeatherModel: Codable {
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
}

// Mevcut hava durumu
struct Current: Codable {
    let temp: Double
    let humidity: Int
    let windSpeed: Double
    let pressure: Int
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case temp
        case humidity
        case windSpeed = "wind_speed"
        case pressure
        case weather
    }
}

// Saatlik tahmin
struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

// Günlük tahmin
struct Daily: Codable {
    let dt: Int
    let temp: Temperature
    let weather: [Weather]
}

// Sıcaklık detayları (günlük için)
struct Temperature: Codable {
    let min: Double
    let max: Double
}

// Hava durumu detayı
struct Weather: Codable {
    let description: String
    let icon: String
} 