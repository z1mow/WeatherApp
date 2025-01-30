//
//  ViewController.swift
//  WeatherApp
//
//  Created by Şakir Yılmaz ÖĞÜT on 30.01.2025.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
    }
    
    private func setupDelegates() {
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.dataSource = self
        dailyForecastTableView.delegate = self
        dailyForecastTableView.dataSource = self
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24 // 24 saatlik tahmin
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCell", for: indexPath) as? HourlyForecastCell else {
            return UICollectionViewCell()
        }
        // Cell'i yapılandır (şimdilik örnek verilerle)
        cell.timeLabel.text = "12:00"
        cell.weatherIconLabel.text = "🌤️"
        cell.temperatureLabel.text = "23°"
        return cell
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7 // 7 günlük tahmin
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastCell", for: indexPath) as? DailyForecastCell else {
            return UITableViewCell()
        }
        // Cell'i yapılandır (şimdilik örnek verilerle)
        cell.dayLabel.text = "Monday"
        cell.weatherIconLabel.text = "⛅️"
        cell.minTemperatureLabel.text = "18°"
        cell.maxTemperatureLabel.text = "25°"
        return cell
    }
}

