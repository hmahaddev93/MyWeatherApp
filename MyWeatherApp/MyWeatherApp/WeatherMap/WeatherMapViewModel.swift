//
//  WeatherMapViewModel.swift
//  MyWeatherApp
//
//  Created by Khateeb H. on 1/4/22.
//

import Foundation
import CoreLocation

final class WeatherMapViewModel {
    
    func spots(by minLocation: CLLocationCoordinate2D,
               maxLocation: CLLocationCoordinate2D,
               mapZoomLevel: Int,
               Completion: @escaping (Result<[StationAnnotation], Error>) -> Void) {
        WeatherService.shared.querySpots(by: minLocation, maxLocation: maxLocation, mapZoomLevel: mapZoomLevel) { result in
            switch (result) {
                
            case .success(let spots):
                var stations = [StationAnnotation]()
                for spot in spots {
                    if let station = spot.stationsData.first {
                        var windAngle: Double?
                        var windDirection: String?
                        var airTemp: Double?
                        var dateString: String?
                        if case .double(let angle) = station["dir"] {
                            windAngle = angle
                        }
                        if case .string(let directionText) = station["dir_text"] {
                            windDirection = directionText
                        }
                        if case .double(let aTemp) = station["atemp"] {
                            airTemp = aTemp
                        }
                        if case .string(let observeDate) = station["timestamp"] {
                            dateString = observeDate
                        }
                            
                        stations.append(
                            StationAnnotation(title: spot.name,
                                              windDirectionAngle: windAngle,
                                              windDirectionText: windDirection,
                                              airTemp: airTemp,
                                              observationDateString: dateString,
                                              coordinate: spot.location))
                    } else {
                        stations.append(StationAnnotation(title: spot.name, windDirectionAngle: nil, windDirectionText: nil, airTemp: nil, observationDateString: nil, coordinate: spot.location))
                    }
                    
                }
                
                Completion(.success(stations))
            case .failure(let error):
                Completion(.failure(error))
            }
        }
    }
}
