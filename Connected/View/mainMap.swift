//
//  Map.swift
//  Connected
//
//  Created by 정근호 on 4/9/24.
//

import SwiftUI
import MapKit

struct mainMap: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    var body: some View {
        Map(position: $position){
            
        }
        .mapControls{
            MapUserLocationButton()
            MapPitchToggle()
        }
        .onAppear(){
            CLLocationManager().requestWhenInUseAuthorization()
            
        }
        
    }
}

#Preview {
    mainMap()
}
