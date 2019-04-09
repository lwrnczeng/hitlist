//
//  DetailViewController.swift
//  HitList
//
//  Created by Lawrence on 2018-11-04.
//  Copyright © 2018 Lawrence. All rights reserved.
//

import UIKit
import CoreData

class DeviceDetailTableViewController: UITableViewController {

    @IBOutlet weak var DeviceTypeLabel: UILabel!
    @IBOutlet weak var DeviceType: UITextField!
    @IBOutlet weak var DeivceNameLabel: UILabel!
    @IBOutlet weak var DeviceName: UITextField!
    @IBOutlet weak var DeviceOwnerNameLabel: UILabel!
    @IBOutlet weak var DeviceOwnerName: UILabel!
    
    var coreDataStack : CoreDataStack!
    var device : Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DeviceTypeLabel.text = "Device Type:"
        DeivceNameLabel.text = "Name:"
        DeviceOwnerNameLabel.text = "Owner:"
        if let device = device {
            DeviceType.text = device.deviceType
            DeviceName.text = device.name
            
            if let owner = device.owner {
                DeviceOwnerName.text = owner.name
            } else {
                DeviceOwnerName.text = "Set device owner"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1 && indexPath.row == 0){
            if let personPicker = storyboard?.instantiateViewController(withIdentifier: "People") as? PeopleTableViewController {
                personPicker.coreDataStack = coreDataStack
                personPicker.personPickerDelegate = self
                personPicker.selectedPerson = device?.owner
                
                navigationController?.pushViewController(personPicker, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let device = device, let name = DeviceName.text, let deviceType = DeviceType.text {
            device.name = name
            device.deviceType = deviceType
        } else if device == nil {
            if let name = DeviceName.text, let deviceType = DeviceType.text, let entity = NSEntityDescription.entity(forEntityName: "Device", in: coreDataStack.managedObjectContext), !name.isEmpty, !deviceType.isEmpty {
//                    let device = Device(entity: entity, insertInto: coreDataStack.managedObjectContext)//NSManagedObject as! Device
                    let device = Device(context: coreDataStack.managedObjectContext)
                    device.name = name
                    device.deviceType = deviceType
                }
            }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        coreDataStack?.saveMainContext()
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = (endTime - startTime) * 1000
        print("saving the context took \(elapsedTime) ms")
    
    }
    
}

extension DeviceDetailTableViewController:PersonPickerDelegate {
    func didSelectPerson(person: Person) {
        device?.owner = person
        DeviceOwnerName.text = device?.owner?.name
        coreDataStack?.saveMainContext()
    }
}
