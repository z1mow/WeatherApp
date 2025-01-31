//
//  ViewController.swift
//  WeatherApp
//
//  Created by Şakir Yılmaz ÖĞÜT on 30.01.2025.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    private var weatherData: WeatherModel?
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupLocationManager()
    }
    
    // MARK: - Setup Methods
    private func setupDelegates() {
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.dataSource = self
        dailyForecastTableView.delegate = self
        dailyForecastTableView.dataSource = self
    }
    
    private func setupLocationManager() {
        LocationManager.shared.delegate = self
        LocationManager.shared.requestLocation()
    }
    
    // MARK: - Data Methods
    private func fetchWeatherData(latitude: Double, longitude: Double) {
        NetworkManager.shared.fetchWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self.weatherData = weather
                    self.updateUI()
                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }
    
    private func updateUI() {
        guard let weather = weatherData else { return }
        
        // Ana hava durumu
        temperatureLabel.text = "\(Int(round(weather.current.temp)))°"
        if let description = weather.current.weather.first?.description {
            conditionLabel.text = translateWeatherDescription(description)
        }
        humidityLabel.text = "\(weather.current.humidity)%"
        windLabel.text = "\(Int(round(weather.current.windSpeed))) km/h"
        pressureLabel.text = "\(weather.current.pressure) hPa"
        
        // Collection view ve table view'ı göster ve güncelle
        hourlyForecastCollectionView.isHidden = false
        dailyForecastTableView.isHidden = false
        hourlyForecastCollectionView.reloadData()
        dailyForecastTableView.reloadData()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Hata", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func translateWeatherDescription(_ description: String) -> String {
        switch description.lowercased() {
        case "clear sky": return "Açık"
        case "few clouds": return "Az Bulutlu"
        case "scattered clouds": return "Parçalı Bulutlu"
        case "broken clouds": return "Çok Bulutlu"
        case "shower rain": return "Sağanak Yağışlı"
        case "rain": return "Yağmurlu"
        case "thunderstorm": return "Gök Gürültülü Fırtına"
        case "snow": return "Karlı"
        case "mist": return "Sisli"
        default: return description.capitalized
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData?.hourly.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCell", for: indexPath) as? HourlyForecastCell,
              let hourly = weatherData?.hourly[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        let date = Date(timeIntervalSince1970: Double(hourly.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        formatter.locale = Locale(identifier: "tr_TR")
        
        cell.timeLabel.text = formatter.string(from: date)
        cell.weatherIconLabel.text = hourly.weather.first?.icon.getWeatherEmoji()
        cell.temperatureLabel.text = "\(Int(round(hourly.temp)))°"
        
        return cell
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData?.daily.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastCell", for: indexPath) as? DailyForecastCell,
              let daily = weatherData?.daily[indexPath.row] else {
            return UITableViewCell()
        }
        
        let date = Date(timeIntervalSince1970: Double(daily.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        
        cell.dayLabel.text = formatter.string(from: date).capitalized
        cell.weatherIconLabel.text = daily.weather.first?.icon.getWeatherEmoji()
        cell.minTemperatureLabel.text = "\(Int(round(daily.temp.min)))°"
        cell.maxTemperatureLabel.text = "\(Int(round(daily.temp.max)))°"
        
        return cell
    }
}

// MARK: - LocationManagerDelegate
extension WeatherViewController: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        showError(error)
    }
}

// MARK: - Weather Icon Helper
extension String {
    func getWeatherEmoji() -> String {
        switch self {
        case "01d", "01n": return "☀️"  // Clear sky
        case "02d", "02n": return "🌤️"  // Few clouds
        case "03d", "03n": return "☁️"  // Scattered clouds
        case "04d", "04n": return "☁️"  // Broken clouds
        case "09d", "09n": return "🌧️"  // Shower rain
        case "10d", "10n": return "🌦️"  // Rain
        case "11d", "11n": return "⛈️"  // Thunderstorm
        case "13d", "13n": return "🌨️"  // Snow
        case "50d", "50n": return "🌫️"  // Mist
        default: return "❓"
        }
    }
}

