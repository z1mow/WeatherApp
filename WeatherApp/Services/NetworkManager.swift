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
                print("Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
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
                print("Decode Error: \(error.localizedDescription)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(dataString)")
                }
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
} 
