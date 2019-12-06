//
//  LocationManager.swift
//  BGLocation1205
//
//  Created by leslie on 12/5/19.
//  Copyright © 2019 leslie. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

let LOCATION_UPDATED_NOTIFICATION = NSNotification.Name("BackLoc.LocationUpdated.Notification")

class LocationManager: NSObject, CLLocationManagerDelegate, URLSessionDelegate {
    private let locationManager = CLLocationManager()
    private let persistenceKey = "BackLoc.LocationsKey"
    private let secondsBetweenRecordingUpdates: TimeInterval = 5
    private var lastUpdate = Date.distantPast
    private var locationUpdateMode: Int = 0
    private var session: URLSession?
    
    // MARK: - Lifecycle Methods
    
    override init() {
        super.init()
        
        print("Initializing a Location Manager: \(self)")
        // configuring the Core Location services.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // If needed for more detail: ...For Navigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.distanceFilter = kCLDistanceFilterNone // default
        
        // TODO: Also use a timer?
    }
    
    deinit {
        print("Location Manager de-initialized: \(self)")
        session?.invalidateAndCancel()
        locationManager.delegate = nil
    }
    
    // MARK: - Process Methods
    
    
    func startUpdatingLocation() {
        let auth = CLLocationManager.authorizationStatus()
        if auth == .denied {
            print("Location Service Permissions are disabled")
        } else {
            print("Starting to monitor location updates")
            locationUpdateMode = 1
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // Note: As configured, this only works while app is in the background, on actual device,
    //       and seems to go to notification center but not be visible.
    private func postUserNotification(loc: CLLocation) {
        let content = UNMutableNotificationContent()
        content.title = "Location Updated"
        content.subtitle = "again"
        content.body = "\(loc)"
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: "\(loc)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error requesting user notification: \(error)")
            }
        }
    }
    
    private func processUpdate(loc: CLLocation) {
        
//        NotificationCenter.default.post(name: LOCATION_UPDATED_NOTIFICATION, object: nil)
        postUserNotification(loc: loc)
    }
    
    // MARK: - Location Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        switch locationUpdateMode {
        case 0:
            // Throttle: location update and notification with time interval by timestamp.
            
            // Compare two dates using swift in iOS
            // if firstDate.compare(secondDate) == ComparisonResult.orderedSame
            // The two operands are equal.
            // if firstDate.compare(secondDate) == ComparisonResult.orderedDescending
            // The left operand(firstDate) is greater than the right operand(secondDate).
            // if firstDate.compare(secondDate) == ComparisonResult.orderedAscending
            // The left operand(firstDate) is smaller than the right operand(secondDate).
            let hasNotBeenLongEnough = lastUpdate.addingTimeInterval(secondsBetweenRecordingUpdates).compare(loc.timestamp) == ComparisonResult.orderedDescending

            if hasNotBeenLongEnough {
                return
            }
            lastUpdate = loc.timestamp
            print("\(lastUpdate)")
            print("\(loc)")
            processUpdate(loc: loc)
        case 1:
            // location update without time interval and notification
            for location in locations {
                print(">>> \(location)")
            }
        default:
            return
        }
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error! \(error)")
//        save()
    }
}
