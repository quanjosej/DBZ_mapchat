import MapKit
import Foundation

class UserMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            // 1
            guard let user = newValue as? User else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            
            // 2
            markerTintColor = .black
            glyphText = String("hhhjgh")
        }
    }
}
