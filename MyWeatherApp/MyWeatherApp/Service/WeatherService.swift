//
//  AstroService.swift
//  AstroBrowser
//
//  Created by Khateeb H. on 12/3/21.
//

import Foundation
import Alamofire
import CoreLocation

enum WeatherFlowAPI  {
    static let host: String = "api.weatherflow.com"
    static let wfToken: String = "d24d7c08a1e0136dca93e86cd38455a4"
    enum EndPoints {
        static let getSpotDetailSetByZoomLevel = "/wxengine/rest/spot/getSpotDetailSetByZoomLevel"
    }
}

enum WeatherServiceError: Error {
    case failOrEmptySpots
}

protocol WeatherService_Protocol {
    func querySpots(by minLocation: CLLocationCoordinate2D,
                    maxLocation: CLLocationCoordinate2D,
                    mapZoomLevel: Int,
                    windUnits: String,
                    tempUnits: String,
                    distanceUnits: String,
                    completion: @escaping (Result<[Spot], Error>) -> Void)
}

class WeatherService: WeatherService_Protocol {
    static let shared = WeatherService()
    private let httpClient: HTTPClient_Protocol
    private let jsonDecoder: JSONDecoder

    init(httpClient: HTTPClient_Protocol = HTTPClient()) {
        self.httpClient = httpClient
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        self.jsonDecoder.dateDecodingStrategy = .formatted(formatter)
    }
    
    func querySpots(by minLocation: CLLocationCoordinate2D,
                    maxLocation: CLLocationCoordinate2D,
                    mapZoomLevel: Int,
                    windUnits: String = "mph",
                    tempUnits: String = "f",
                    distanceUnits: String = "mi",
                    completion: @escaping (Result<[Spot], Error>) -> Void) {
    
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = WeatherFlowAPI.host
        urlComponents.path = WeatherFlowAPI.EndPoints.getSpotDetailSetByZoomLevel
        
        let queryToken = URLQueryItem(name: "wf_token", value: WeatherFlowAPI.wfToken)
        let queryLatMin = URLQueryItem(name: "lat_min", value: "\(minLocation.latitude)")
        let queryLonMin = URLQueryItem(name: "lon_min", value: "\(minLocation.longitude)")
        let queryLatMax = URLQueryItem(name: "lat_max", value: "\(maxLocation.latitude)")
        let queryLonMax = URLQueryItem(name: "lon_max", value: "\(maxLocation.longitude)")
        let queryZoom = URLQueryItem(name: "zoom", value: "\(mapZoomLevel)")
        let queryWindUnits = URLQueryItem(name: "units_wind", value: windUnits)
        let queryTempUnits = URLQueryItem(name: "units_temp", value: tempUnits)
        let queryDistanceUnits = URLQueryItem(name: "units_distance", value: distanceUnits)

        urlComponents.queryItems = [queryToken, queryLatMin, queryLonMin, queryLatMax, queryLonMax, queryZoom, queryWindUnits, queryTempUnits, queryDistanceUnits]
        
        let request = HTTPRequest(url: urlComponents.url!)
        httpClient.send(request: request) { result in
            switch result {
            case let .success(data):
                let spotsResponse = try! self.jsonDecoder.decode(SpotsResponseBody.self, from: data)
                if spotsResponse.status.statusCode == 0, let spots = spotsResponse.spots {
                    completion(.success(spots))
                } else {
                    completion(.failure(WeatherServiceError.failOrEmptySpots))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
