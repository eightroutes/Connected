import SwiftUI
import FirebaseAuth
import MapKit
import CoreLocation

struct mainMap: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @StateObject private var locationManager = LocationManager()
    @State private var showProfileDetail = false
    @State private var selectedUser: UserLocation?
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            UserAnnotation()
            ForEach(firestoreManager.usersLoc.filter { $0.id != firestoreManager.currentUserId }) { user in
//                Annotation("\(user.name)", coordinate: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)) {
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)) {
                    CustomMarker(user: user) {
                        selectedUser = user
                        showProfileDetail = true
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
        }
        .sheet(isPresented: $showProfileDetail) {
            if let selectedUser = selectedUser {
                ProfileDetail(userId: selectedUser.id)
            }
        }
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                firestoreManager.currentUserId = userId
            }
            locationManager.requestLocation()
            firestoreManager.fetchUserLocations()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                updateUserLocationAndFetch(location: location)
                cameraPosition = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 1000))
            }
        }
    }
    
    private func updateUserLocationAndFetch(location: CLLocation) {
        guard let userId = firestoreManager.currentUserId else { return }
        firestoreManager.updateUserLocation(userId: userId, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { success in
            if success {
                print("User location updated successfully")
                firestoreManager.fetchUserLocations()
            } else {
                print("Failed to update user location")
            }
        }
    }
}


#Preview {
    mainMap()
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() // 연속적인 위치 업데이트 시작
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        manager.stopUpdatingLocation() // 위치를 받았으면 업데이트 중지
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location", error)
    }
}

#Preview {
    mainMap()
}

