//
//  MapViewWithZoom.swift
//  MyWeatherApp
//
//  Created by Khateeb H. on 1/5/22.
//

import UIKit
import MapKit

class MapViewWithZoom: MKMapView {

    var zoomLevel: Int {
        get {
            return Int(log2(360 * (Double(self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1);
        }

        set (newZoomLevel){
            setCenterCoordinate(coordinate:self.centerCoordinate, zoomLevel: newZoomLevel, animated: false)
        }
    }

    private func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(zoomLevel)) * Double(self.frame.size.width) / 256)
        setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: animated)
    }
}
