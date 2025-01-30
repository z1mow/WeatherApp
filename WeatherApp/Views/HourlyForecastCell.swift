//
//  HourlyForecastCell.swift
//  WeatherApp
//
//  Created by Şakir Yılmaz ÖĞÜT on 30.01.2025.
//

import UIKit

class HourlyForecastCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherIconLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
