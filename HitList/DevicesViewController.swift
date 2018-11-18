//
//  DevicesViewController.swift
//  HitList
//
//  Created by Lawrence on 2018-11-04.
//  Copyright © 2018 Lawrence. All rights reserved.
//

import UIKit
import CoreData

class DevicesTableViewController: UIViewController {
    
    var coreDataStack : CoreDataStack!
    var managedObjectContext : NSManagedObjectContext!
    
    @IBOutlet weak var tableView: UITableView!
    
    var devices : [NSManagedObject] = []
    var selectedPerson : Person?
    
    private let cellId = "DeviceCell"
    
    fileprivate func reloadData(deviceFilterString : NSString? = nil) {
        //      tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: cellId) //
        if let selectedPerson = selectedPerson {
            if let personDevices = selectedPerson.devices?.allObjects as? [Device] {
                devices = personDevices
            }
        } else {
            let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "Device")
            if let deviceFilterString = deviceFilterString {
                let deviceFilterPredicate = NSPredicate(format: "deviceType =[c] %@", deviceFilterString)  //[c] means case insensitive
                fetchReqeust.predicate = deviceFilterPredicate
            }
            
            do {
                if let results = try managedObjectContext.fetch(fetchReqeust) as? [Device] {
                    devices = results
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
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
            self.reloadData(deviceFilterString: "iphone")
        }))
        sheet.addAction(UIAlertAction(title: "Only Watches", style: .default, handler: { (action) -> Void in
            self.reloadData(deviceFilterString: "watch")
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
                let indexPath = tableView.indexPathForSelectedRow! as NSIndexPath
                let selectedItem : Device = devices[indexPath.row] as! Device
                detailViewController!.device = selectedItem
               
//                detailViewController!.passedValue = cell!.textLabel?.text
            }
        }
    }
    

}


extension DevicesTableViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let device = devices[indexPath.row] as! Device
        
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
            let device = devices[indexPath.row]
            managedObjectContext.delete(device)
            reloadData()
        }
    }
    
}
