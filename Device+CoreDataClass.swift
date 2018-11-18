//
//  Device+CoreDataClass.swift
//  HitList
//
//  Created by Lawrence on 2018-11-12.
//  Copyright © 2018 Lawrence. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Device)
public class Device: NSManagedObject {
    var deviceDescription : String {
        return "\(name) \(deviceType)"
    }
}
