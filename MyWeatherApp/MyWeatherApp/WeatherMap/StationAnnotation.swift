//
//  StationAnnotation.swift
//  MyWeatherApp
//
//  Created by Khateeb H. on 1/4/22.
//

import Foundation
import MapKit

class StationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let windDirectionAngle: Double?
    let windDirectionText: String?
    let airTemp: Double?
    let observationDateString: String?

    let coordinate: CLLocationCoordinate2D

  init(
    title: String?,
    windDirectionAngle: Double?,
    windDirectionText: String?,
    airTemp: Double?,
    observationDateString: String?,
    coordinate: CLLocationCoordinate2D
  ) {
      self.title = title
      self.windDirectionAngle = windDirectionAngle
      self.windDirectionText = windDirectionText
      self.airTemp = airTemp
      self.observationDateString = observationDateString
      self.coordinate = coordinate
      super.init()
  }

  var subtitle: String? {
      guard let dirText = windDirectionText,
            let dirAngle = windDirectionAngle,
            let aTemp = airTemp,
            let dateString = observationDateString else { return nil }
    return String(format: "Wind: %@(%.0f°) Air: %.0f℉ at %@", dirText, dirAngle, aTemp, dateString)
  }
}
