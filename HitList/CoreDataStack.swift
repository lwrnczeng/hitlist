//
//  CoreDataStack.swift
//  HitList
//
//  Created by Lawrence on 2018-11-01.
//  Copyright © 2018 Lawrence. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack: NSObject {
    
    let persistentStoreCoordinator : NSPersistentStoreCoordinator?
    
    override init() {  //completionClosure: @escaping () -> ()
        let modelName = "DataModel";
        //This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        //        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        //        managedObjectContext?.persistentStoreCoordinator = persistentStoreCoordinator
        
        //        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        //        queue.async {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("Unable to resolve document directory")
        }
        let storeURL = docURL.appendingPathComponent("\(modelName).sqlite")
        do {
            try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true])
            //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
            //                DispatchQueue.main.sync(execute: completionClosure)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        //        }
    }
    
    
    func saveMainContext () {
        
        guard managedObjectContext.hasChanges || saveManagedObjectContext.hasChanges else {
            return
        }
        
        managedObjectContext.performAndWait {
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    //todo: handle errors, may show a message
                    print(("Unresolved error \(nserror), \(nserror.userInfo)"))
                    //                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
        saveManagedObjectContext.perform {
            if self.saveManagedObjectContext.hasChanges {
                do {
                    try self.saveManagedObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    print(("Unresolved error \(nserror), \(nserror.userInfo)"))
                }
            }
        }
        
    }
    
    private lazy var saveManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        managedObjectContext.parent = self.saveManagedObjectContext
        return managedObjectContext
    }()
    
    
}
