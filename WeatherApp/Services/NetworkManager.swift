import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.openweathermap.org/data/3.0/onecall"
    private let apiKey: String = Constants.apiKey
    
    private init() {}
    
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
