//
//  MKMapView+Utils.swift
//  MyWeatherApp
//
//  Created by Khateeb H. on 1/5/22.
//

import Foundation
import MapKit

public struct MapBounds {
  let firstBound: CLLocation
  let secondBound: CLLocation
}

extension MKMapView {
    var newBounds: MapBounds {
      let originPoint = CGPoint(x: bounds.origin.x + bounds.size.width, y: bounds.origin.y)
      let rightBottomPoint = CGPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height)

      let originCoordinates = convert(originPoint, toCoordinateFrom: self)
      let rightBottomCoordinates = convert(rightBottomPoint, toCoordinateFrom: self)

      return MapBounds(
        firstBound: CLLocation(latitude: originCoordinates.latitude, longitude: originCoordinates.longitude),
        secondBound: CLLocation(latitude: rightBottomCoordinates.latitude, longitude: rightBottomCoordinates.longitude)
      )
    }
    
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 50000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

