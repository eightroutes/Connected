import SwiftUI
import MapKit

struct MKMapViewRepresentable: UIViewRepresentable {
    @Binding var annotations: [MKAnnotation]
    @Binding var selectedUser: User?
    @Binding var showProfileDetail: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        mapView.delegate = context.coordinator
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(MKMarkerAnnotationView.self))
        mapView.register(MKClusterAnnotation.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.showsUserLocation = true

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MKMapViewRepresentable

        init(_ parent: MKMapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView
                clusterView.markerTintColor = .blue
                return clusterView
            } else if let userAnnotation = annotation as? UserAnnotation {
                let markerView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(MKMarkerAnnotationView.self), for: annotation) as! MKMarkerAnnotationView
                markerView.markerTintColor = .red
                markerView.canShowCallout = true
                markerView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return markerView
            } else {
                return nil
            }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let userAnnotation = view.annotation as? UserAnnotation {
                parent.selectedUser = userAnnotation.user
                parent.showProfileDetail = true
            }
        }
    }
}


import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    let user: User
    var coordinate: CLLocationCoordinate2D

    init(user: User) {
        self.user = user
        self.coordinate = CLLocationCoordinate2D(latitude: user.latitude ?? 0, longitude: user.longitude ?? 0)
        super.init()
    }

    var title: String? {
        return user.name
    }
}
