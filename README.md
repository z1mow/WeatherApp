# Weather App 🌤️

A modern weather application that provides current weather conditions and forecasts. Developed using Swift and UIKit, with the assistance of Cursor IDE.

[Türkçe](#türkçe) | [English](#english)

## English

### Features
- Real-time weather data using OpenWeatherMap API
- Current weather conditions including:
  - Temperature
  - Weather condition with emoji
  - Humidity
  - Wind speed
  - Atmospheric pressure
- Hourly forecast for the next 24 hours
- 7-day weather forecast
- City search functionality
- Location-based weather data
- Fully localized in Turkish
- Beautiful and intuitive UI

### Technical Details
- Architecture & Design Patterns:
  - MVVM Architecture
  - Singleton Pattern
  - Delegate Pattern
  - Protocol-Oriented Programming
- UI Framework & Components:
  - Built with UIKit
  - UITableView for daily forecast
  - UICollectionView for hourly forecast
  - UIStackView for layout management
  - Custom UITableViewCell and UICollectionViewCell
  - UISearchBar for city search
  - Auto Layout with programmatic constraints
  - Storyboard and XIB files
- Location & Network:
  - CoreLocation for user location
  - URLSession for network requests
  - OpenWeatherMap REST API integration
  - JSON parsing with Codable
- Features:
  - Custom UI components
  - Error handling and user feedback
  - Localization support
  - Background threading
  - Memory management with weak references
  - Custom date formatting
  - String extensions for emoji mapping

### Requirements
- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+
- OpenWeatherMap API Key

### Installation
1. Clone the repository
2. Create a `Constants.swift` file in the project root
3. Add your OpenWeatherMap API key:
```swift
struct Constants {
    static let apiKey = "YOUR_API_KEY"
}
```
4. Build and run the project

### Acknowledgments
- Developed with the assistance of Cursor IDE
- Weather data provided by OpenWeatherMap
- Icons and emojis for weather conditions

---

## Türkçe

### Özellikler
- OpenWeatherMap API kullanarak gerçek zamanlı hava durumu verileri
- Güncel hava durumu bilgileri:
  - Sıcaklık
  - Emoji ile hava durumu gösterimi
  - Nem oranı
  - Rüzgar hızı
  - Atmosfer basıncı
- 24 saatlik saatlik tahmin
- 7 günlük hava durumu tahmini
- Şehir arama özelliği
- Konum bazlı hava durumu
- Tamamen Türkçe
- Güzel ve sezgisel kullanıcı arayüzü

### Teknik Detaylar
- Mimari & Tasarım Desenleri:
  - MVVM Mimarisi
  - Singleton Deseni
  - Delegate Deseni
  - Protokol Odaklı Programlama
- UI Framework & Bileşenler:
  - UIKit ile geliştirildi
  - Günlük tahmin için UITableView
  - Saatlik tahmin için UICollectionView
  - Düzen yönetimi için UIStackView
  - Özel UITableViewCell ve UICollectionViewCell
  - Şehir araması için UISearchBar
  - Programatik constraint'ler ile Auto Layout
  - Storyboard ve XIB dosyaları
- Konum & Ağ:
  - Kullanıcı konumu için CoreLocation
  - Ağ istekleri için URLSession
  - OpenWeatherMap REST API entegrasyonu
  - Codable ile JSON ayrıştırma
- Özellikler:
  - Özel UI bileşenleri
  - Hata yönetimi ve kullanıcı geri bildirimi
  - Lokalizasyon desteği
  - Arka plan iş parçacığı yönetimi
  - Weak referanslar ile bellek yönetimi
  - Özel tarih biçimlendirme
  - Emoji eşleştirme için String uzantıları

### Gereksinimler
- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+
- OpenWeatherMap API Anahtarı

### Kurulum
1. Projeyi klonlayın
2. Proje ana dizininde `Constants.swift` dosyası oluşturun
3. OpenWeatherMap API anahtarınızı ekleyin:
```swift
struct Constants {
    static let apiKey = "API_ANAHTARINIZ"
}
```
4. Projeyi derleyin ve çalıştırın

### Teşekkürler
- Cursor IDE desteğiyle geliştirildi
- Hava durumu verileri OpenWeatherMap tarafından sağlanmaktadır
- Hava durumu için ikonlar ve emojiler 
