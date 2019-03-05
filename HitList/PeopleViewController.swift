//
//  ViewController.swift
//  HitList
//
//  Created by Lawrence on 2018-10-24.
//  Copyright © 2018 Lawrence. All rights reserved.
//  Added something here to try pull request

import UIKit
import CoreData

protocol PersonPickerDelegate: class {
    func didSelectPerson(person: Person)
}

class PeopleTableViewController: UITableViewController {
    

    var coreDataStack : CoreDataStack!
    var managedObjectContext : NSManagedObjectContext!
//    @IBOutlet weak var tableView: UITableView!
    var people : [Person] = []
    
    weak var personPickerDelegate: PersonPickerDelegate?
    var selectedPerson: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = coreDataStack.managedObjectContext
        title = "People List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
//        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: "addName:")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }

    fileprivate func reloadData() {
        //        coreDataStack = CoreDataStack(completionClosure: {
        //        })
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //3
        do {
            people = try managedObjectContext.fetch(fetchRequest) as! [Person]
            if (people.count == 0){
                //                self.initializeData()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    fileprivate func initializeData() {
        // Override point for customization after application launch.
        let devicesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        do {
            let fetchedDevices = try managedObjectContext!.fetch(devicesFetch) as! [Device]
            if fetchedDevices.count == 0 {
                addTestData_AnotherWay()
                tableView.reloadData()
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    func addTestData_AnotherWay(){
        guard let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedObjectContext), let personEntity = NSEntityDescription.entity(forEntityName: "Person", in: managedObjectContext) else {
            fatalError("Counld not find entity descriptions!")
        }

        for i in 1...10 {
            let device = Device(context: managedObjectContext)
            device.name = "Some Device #\(i)"
            device.deviceType = i % 3 == 0 ? "Watch" : "iPhone"
        }
        
//        let bob = Person(context: managedContext)
        let bob = Person(entity: personEntity, insertInto: managedObjectContext)
        bob.name = "Lawrence"
        
        let jane = Person(entity: personEntity, insertInto: managedObjectContext)
        jane.name = "Great"
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
    }
//
//    func addTestData() {
//        let managedContext = coreDataStack.managedObjectContext
//        guard let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext), let personEntity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext) else {
//                fatalError("Counld not find entity descriptions!")
//        }
//        
//        for i in 1 ... 10 {
//            let device = NSEntityDescription.insertNewObject(forEntityName: "Device", into: managedContext) as! Device
//            //        else {
//            //            fatalError("Could not find entity descriptions!")
//            device.name = "Some Device #\(i)"
//            device.deviceType = i % 3 == 0 ? "Watch" : "iPhone"
//        }
//        
//        let bob = NSEntityDescription.insertNewObject(forEntityName: "Person", into: managedContext) as! Person
//        bob.name = "Bob"
//        
//        let jane = NSEntityDescription.insertNewObject(forEntityName: "Person", into: managedContext) as! Person
//        jane.name = "Jane"
//        
//        coreDataStack.saveContext()
//        
//        tableView.reloadData()
//    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
//        alert.addTextField(configurationHandler: { (textField) in
//            textField.placeholder = "Enter Name"
//        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
//            (action) in
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else{
                    return
            }
//            var person =
            self.save(name:nameToSave)
           
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func save(name:String) {
        //1
//        let managedContext = coreDataStack.managedObjectContext
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedObjectContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedObjectContext) as! Person
        //3
        //person.setValue(name, forKeyPath: "name")
        person.name = name
        //4
        do {
            try managedObjectContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save it. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return names.count
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        personPickerDelegate?.didSelectPerson(person: people[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return personPickerDelegate == nil;
    }
   
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let person = people[indexPath.row]
            managedObjectContext.delete(person)
            reloadData()
        }
    }
}


//extension PeopleTableViewController : UITableViewDataSource {
//
//}

