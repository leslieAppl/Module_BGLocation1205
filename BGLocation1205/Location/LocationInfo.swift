//
//  LocationInfo.swift
//  BGLocation1205
//
//  Created by leslie on 12/5/19.
//  Copyright © 2019 leslie. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationInfo {
    let lat: CLLocationCoordinate2D
    let long: CLLocationCoordinate2D
    let timestamp: Date
    
    init(lat: CLLocationCoordinate2D, long: CLLocationCoordinate2D, timestamp: Date) {
        self.lat = lat
        self.long = long
        self.timestamp = timestamp
    }
}
