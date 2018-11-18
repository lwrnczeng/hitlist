//
//  DevicesViewController.swift
//  HitList
//
//  Created by Lawrence on 2018-11-04.
//  Copyright © 2018 Lawrence. All rights reserved.
//

import UIKit
import CoreData

class DevicesWithFetchRequestController: UIViewController {
    
    var coreDataStack : CoreDataStack!
    var managedObjectContext : NSManagedObjectContext!
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>!
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedPerson : Person?
    
    private let cellId = "DeviceCell"
    
    fileprivate func reloadData(predicate: NSPredicate? = nil) {
        //      tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: cellId) //
        if let selectedPerson = selectedPerson {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "owner == %@", selectedPerson)
        } else {
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        do {
          try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
       
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = coreDataStack.managedObjectContext
        if let selectedPerson = selectedPerson {
            title = "\(selectedPerson.name)'s Devices"
        } else {
            title = "Devices"
            
            //            navigationItem.rightBarButtonItem =
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem:.add, target: self, action:#selector(addDevice(sender:))),
                UIBarButtonItem(title: "Filter", style:UIBarButtonItem.Style.plain, target: self, action:#selector(selectFilter(sender:)))
            ]
        }
        
        tableView.dataSource = self
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }
    
    @objc func selectFilter(sender: AnyObject?){
        let sheet = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        sheet.addAction(UIAlertAction(title: "Show All", style: .default, handler: { (action) -> Void in
            self.reloadData()
        }))
        sheet.addAction(UIAlertAction(title: "Only Phones", style: .default, handler: {(action) -> Void in
            let predicate = NSPredicate(format: "deviceType =[c] %@", "iphone")
            self.reloadData(predicate: predicate)
        }))
        sheet.addAction(UIAlertAction(title: "Only Watches", style: .default, handler: { (action) -> Void in
            let predicate = NSPredicate(format: "deviceType =[c] %@", "watch")
            self.reloadData(predicate: predicate)
        }))
        self.present(sheet, animated: true, completion: nil)
    }
    
    @objc func addDevice(sender: UIBarButtonItem!) {
        //        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DeviceDetail") as? DeviceDetailTableViewController {
        //            detailViewController.managedObjectContext = managedObjectContext
        //            navigationController?.pushViewController(detailViewController, animated: true)
        //        }
        performSegue(withIdentifier: "segueDeviceDetail", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDeviceDetail" {
            let detailViewController = segue.destination as? DeviceDetailTableViewController
            detailViewController?.coreDataStack = coreDataStack
            let cell = sender as? UITableViewCell
            if (cell != nil && detailViewController != nil) {
                let indexPath = tableView.indexPathForSelectedRow!
                let selectedItem : Device = fetchedResultsController.object(at: indexPath as IndexPath) as! Device
                detailViewController!.device = selectedItem
                
                //                detailViewController!.passedValue = cell!.textLabel?.text
            }
        }
    }
    
    
}


extension DevicesWithFetchRequestController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let device = fetchedResultsController.object(at: indexPath) as! Device
        
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = device.deviceType
        //                    cell.ownerLabel.text = "Test Owner"
        //        if (device.owner != nil) {
        //            cell.ownerLabel.text = device.owner!.name
        //        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let device = fetchedResultsController.object(at: indexPath) as! Device
            managedObjectContext.delete(device)
            reloadData()
        }
    }
    
}
