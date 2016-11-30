//
//  EntryTableViewController.swift
//  WilliamsRoad
//
//  Created by Stephen Williams on 4/09/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class EntryTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    let locationManager = CLLocationManager()
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!

    var tree: Tree?
    var entry: DiaryEntry? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.requestWhenInUseAuthorization()
        
        if managedObjectContext != nil {
            if entry == nil {
                entry = NSEntityDescription.insertNewObjectForEntityForName("DiaryEntry", inManagedObjectContext: managedObjectContext) as? DiaryEntry
                entry!.timeStamp = NSDate()
                entry!.tree = tree
            }
            configureView()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard let entry = entry else { return }
        if titleTextField.text!.isEmpty && detailTextView.text!.isEmpty {
            managedObjectContext.deleteObject(entry)
        } else {
            entry.title = titleTextField.text
            entry.text = detailTextView.text
            do {
                try managedObjectContext.save()
            } catch {
                print("Save failed")
            }
        }
    }
    
}
