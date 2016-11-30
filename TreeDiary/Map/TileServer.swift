//
//  TileServer.swift
//  NZCycleTrail
//
//  Created by Stephen Williams on 4/02/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import Foundation

enum TileServer: Int {
    case Apple
    case OpenStreetMap
    case TopOfTheSouth
    case Localhost
    case OpenCycleMap
    case CartoDB
    
    
    var name: String {
        switch self {
        case .Apple: return "Apple Mapkit"
        case .OpenStreetMap: return "Open Street Map"
        case .TopOfTheSouth: return "Top of the South"
        case .Localhost: return "Localhost"
        case .OpenCycleMap: return "Open Cycle Maps"
        case .CartoDB: return "Carto DB"
        }
    }
    
    var templateUrl: String {
        switch self {
        case .Apple: return ""
        case .OpenStreetMap: return "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .TopOfTheSouth: return "http://www.topofthesouthmaps.co.nz/ArcGIS/rest/services/CacheAerial/MapServer/tile/{z}/{x}/{y}"
        case .Localhost: return "http://localhost:8080/williams-road/{z}/{x}/{y}.jpeg"
        case .OpenCycleMap: return "http://b.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
        case .CartoDB: return "http://b.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
        }
    }
    static var count: Int { return TileServer.CartoDB.hashValue + 1}
}