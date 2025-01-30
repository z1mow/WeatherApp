import Foundation
import CoreLocation

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
        case .restricted, .denied:
            // Konum izni reddedilmişse varsayılan konumu kullan
            delegate?.locationManager(self, didUpdateLocation: defaultLocation)
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        @unknown default:
            delegate?.locationManager(self, didUpdateLocation: defaultLocation)
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
        // Konum alınamazsa varsayılan konumu kullan
        delegate?.locationManager(self, didUpdateLocation: defaultLocation)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            delegate?.locationManager(self, didUpdateLocation: defaultLocation)
        default:
            break
        }
    }
} 