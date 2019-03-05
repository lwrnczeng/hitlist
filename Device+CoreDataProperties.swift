//
//  Device+CoreDataProperties.swift
//  HitList
//
//  Created by Lawrence on 2019-02-12.
//  Copyright © 2019 Lawrence. All rights reserved.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var deviceID: String?
    @NSManaged public var deviceType: String?
    @NSManaged public var name: String?
    @NSManaged public var purchaseDate: NSDate?
    @NSManaged public var owner: Person?

}
