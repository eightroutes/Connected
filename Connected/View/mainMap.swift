import SwiftUI
import MapKit
import CoreLocation

struct mainMap: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Map(position: $position, interactionModes: .all) {
            ForEach(firestoreManager.usersLoc) { usersLoc in
                Marker("User: \(usersLoc.name)", coordinate: CLLocationCoordinate2D(latitude: usersLoc.latitude, longitude: usersLoc.longitude))
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
        }
        .onAppear {
            locationManager.requestLocation()
            firestoreManager.fetchUserLocations()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                updateUserLocationAndFetch(location: location)
            }
        }
    }
    
    private func updateUserLocationAndFetch(location: CLLocation) {
        firestoreManager.updateUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { success in
            if success {
                print("User location updated successfully")
                firestoreManager.fetchUserLocations()
                setupInitialCamera(location: location)
            } else {
                print("Failed to update user location")
            }
        }
    }
    
    private func setupInitialCamera(location: CLLocation) {
        position = .camera(MapCamera(
            centerCoordinate: location.coordinate,
            distance: 1000,
            heading: 0,
            pitch: 60
        ))
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location", error)
    }
}

#Preview {
    mainMap()
}
