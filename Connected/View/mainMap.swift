import SwiftUI
import MapKit

struct mainMap: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position, interactionModes: .all) {
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
            setupInitialCamera()
        }
    }
    
    private func setupInitialCamera() {
        // 사용자 위치를 기반으로 카메라 설정
        position = .userLocation(fallback: .camera(MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 폴백 좌표
            distance: 10, // 줌 레벨 조정 (낮은 값일수록 더 줌인됨)
            heading: 0,
            pitch: 45 // 3D 효과를 위한 pitch 값 (0-90 사이, 높을수록 더 기울어짐)
        )))
    }
}

#Preview {
    mainMap()
}

