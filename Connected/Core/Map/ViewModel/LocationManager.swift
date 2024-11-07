////
////  LocationManager.swift
////  Connected
////
////  Created by 정근호 on 10/14/24.
////
//
//  LocationManager.swift
//  Connected
//
//  Created by 정근호 on 10/14/24.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        // 초기 권한 상태 설정
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
    }
    
    // 권한 상태 확인 및 요청
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // 권한이 제한되었거나 거부된 경우 처리
            print("Location access restricted or denied.")
            // 사용자에게 권한이 필요함을 알리는 알림을 추가할 수 있습니다.
        case .authorizedAlways, .authorizedWhenInUse:
            // 권한이 허용된 경우 위치 업데이트 시작
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    // 권한 상태 변경 시 호출되는 델리게이트 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            // 권한이 제한되었거나 거부된 경우 처리
            print("Location access denied or restricted.")
            // 사용자에게 권한이 필요함을 알리는 알림을 추가할 수 있습니다.
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    // 위치 업데이트 시 호출되는 델리게이트 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = latestLocation
        }
        
        // 위치 업데이트를 일시 중지하여 배터리 소모를 줄일 수 있습니다.
        locationManager.stopUpdatingLocation()
    }
    
    // 위치 업데이트 실패 시 호출되는 델리게이트 메서드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
    
    // 위치 업데이트 다시 시작 (필요 시 호출)
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // 위치 업데이트 일시 중지 (필요 시 호출)
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}




//
//import Foundation
//import MapKit
//import CoreLocation
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//    @Published var location: CLLocation?
//    
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//    
//    func requestLocation() {
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation() // 연속적인 위치 업데이트 시작
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        location = locations.last
//        manager.stopUpdatingLocation() // 위치를 받았으면 업데이트 중지
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Error getting location", error)
//    }
//}
