import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.openweathermap.org/data/3.0/onecall"
    private let geoURL = "https://api.openweathermap.org/geo/1.0/direct"
    private let apiKey: String = Constants.apiKey
    
    private init() {}
    
    func searchCity(query: String, completion: @escaping (Result<[City], Error>) -> Void) {
        let urlString = "\(geoURL)?q=\(query)&limit=5&appid=\(apiKey)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.customError("İnternet bağlantınızı kontrol edin.")))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    completion(.failure(NetworkError.customError("API anahtarı geçersiz veya süresi dolmuş.")))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let cities = try JSONDecoder().decode([City].self, from: data)
                completion(.success(cities))
            } catch {
                completion(.failure(NetworkError.customError("Şehir bilgileri alınamadı.")))
            }
        }
        
        task.resume()
    }
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(apiKey)"
        
        print("API URL: \(urlString)") // Debug için URL'i yazdıralım
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ağ Hatası: \(error.localizedDescription)")
                completion(.failure(NetworkError.customError("İnternet bağlantınızı kontrol edin.")))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Durum Kodu: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(NetworkError.customError("API anahtarı geçersiz veya süresi dolmuş.")))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weather = try decoder.decode(WeatherModel.self, from: data)
                completion(.success(weather))
            } catch {
                print("Çözümleme Hatası: \(error.localizedDescription)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(dataString)")
                }
                completion(.failure(NetworkError.customError("Hava durumu verileri alınamadı.")))
            }
        }
        
        task.resume()
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case customError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL adresi."
        case .noData:
            return "Veri alınamadı."
        case .customError(let message):
            return message
        }
    }
}

struct City: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    var displayName: String {
        if let state = state {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }
} 
