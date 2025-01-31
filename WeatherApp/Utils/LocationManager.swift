import Foundation
import CoreLocation

enum LocationError: LocalizedError {
    case denied
    case notDetermined
    case restricted
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .denied:
            return "Konum izni reddedildi. Ayarlardan konum iznini etkinleştirin."
        case .notDetermined:
            return "Konum izni belirlenmedi."
        case .restricted:
            return "Konum erişimi kısıtlandı."
        case .unknown:
            return "Bilinmeyen bir hata oluştu."
        }
    }
}

protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation)
    func locationManager(_ manager: LocationManager, didFailWithError error: Error)
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    
    // İstanbul koordinatları (varsayılan konum)
    private let defaultLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 1000
    }
    
    func requestLocation() {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            delegate?.locationManager(self, didFailWithError: LocationError.restricted)
        case .denied:
            delegate?.locationManager(self, didFailWithError: LocationError.denied)
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        @unknown default:
            delegate?.locationManager(self, didFailWithError: LocationError.unknown)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.locationManager(self, didUpdateLocation: defaultLocation)
            return
        }
        delegate?.locationManager(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum Hatası: \(error.localizedDescription)")
        delegate?.locationManager(self, didFailWithError: LocationError.unknown)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied:
            delegate?.locationManager(self, didFailWithError: LocationError.denied)
        case .restricted:
            delegate?.locationManager(self, didFailWithError: LocationError.restricted)
        case .notDetermined:
            delegate?.locationManager(self, didFailWithError: LocationError.notDetermined)
        @unknown default:
            delegate?.locationManager(self, didFailWithError: LocationError.unknown)
        }
    }
} 