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
    private var searchResults: [City] = []
    private let searchResultsTableView = UITableView()
    private var currentCityName: String = "Konum Bilgisi Alınıyor..."
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Şehir ara..."
        searchBar.delegate = self
        return searchBar
    }()
    
    @IBOutlet weak var cityNameLabel: UILabel!
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
        setupUI()
        setupSearchResultsTableView()
        cityNameLabel.text = currentCityName
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
    
    private func setupUI() {
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width - 40, height: 44)
        navigationItem.titleView = searchBar
    }
    
    private func setupSearchResultsTableView() {
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
        searchResultsTableView.isHidden = true
        
        view.addSubview(searchResultsTableView)
        searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchResultsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        view.bringSubviewToFront(searchResultsTableView)
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
        case "overcast clouds": return "Kapalı"
        case "shower rain": return "Sağanak Yağışlı"
        case "rain": return "Yağmurlu"
        case "thunderstorm": return "Gök Gürültülü Fırtına"
        case "snow": return "Karlı"
        case "mist": return "Sisli"
        default: return description.capitalized
        }
    }
}

// MARK: - UISearchBarDelegate
extension WeatherViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = []
            searchResultsTableView.isHidden = true
        } else {
            NetworkManager.shared.searchCity(query: searchText) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let cities):
                        self.searchResults = cities
                        self.searchResultsTableView.isHidden = false
                        self.searchResultsTableView.reloadData()
                    case .failure(let error):
                        self.showError(error)
                    }
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
        if tableView == searchResultsTableView {
            return searchResults.count
        }
        return weatherData?.daily.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchResultsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
            let city = searchResults[indexPath.row]
            cell.textLabel?.text = city.displayName
            return cell
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchResultsTableView {
            let selectedCity = searchResults[indexPath.row]
            currentCityName = selectedCity.name
            cityNameLabel.text = currentCityName
            fetchWeatherData(latitude: selectedCity.lat, longitude: selectedCity.lon)
            searchBar.text = ""
            searchResults = []
            searchResultsTableView.isHidden = true
            searchBar.resignFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - LocationManagerDelegate
extension WeatherViewController: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        // Konum güncellendiğinde şehir ismini almak için CLGeocoder kullanıyoruz
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else {
                return
            }
            
            if let city = placemark.locality {
                self.currentCityName = city
                DispatchQueue.main.async {
                    self.cityNameLabel.text = self.currentCityName
                }
            }
        }
        
        fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        showError(error)
        cityNameLabel.text = "Konum Alınamadı"
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

