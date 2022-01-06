//
//  Event.swift
//  EventsFeed
//
//  Created by Khateeb H. on 12/5/21.
//

import Foundation
import CoreLocation

struct Spot: Codable {
    let spotId: Int
    let name: String
    let currentTimeLocal: Date
    
    let lat: Double
    let lon: Double
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    let dataNames: [String]
    let stations: [StationDataValue]
    var stationsData: [[String: StringOrDoubleType?]] {
        var result = [[String: StringOrDoubleType?]]()
        for station in self.stations {
            var stationData = [String: StringOrDoubleType?]()
            for i in 0..<self.dataNames.count {
                stationData[self.dataNames[i]] = station.dataValues.first![i]
            }
            result.append(stationData)
        }
        return result
    }
}

struct StationDataValue: Codable {
    let dataValues: [[StringOrDoubleType?]]
}

struct SpotsResponseBody: Codable {
    var status: SpotStatus
    let spots: [Spot]?
}

struct SpotStatus: Codable {
    let statusCode: Int
    let statusMessage: String
}

enum StringOrDoubleType: Codable {
    case string(String)
    case double(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .string(container.decode(String.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .double(container.decode(Double.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(StringOrDoubleType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let double):
            try container.encode(double)
        case .string(let string):
            try container.encode(string)
        }
    }
}

