//
//  AttachmentViewController.swift
//  TreeDiary
//
//  Created by Stephen Williams on 31/07/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import CoreData

class AttachmentViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var attachment: Attachment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let targetImgeURL = documentsURL.URLByAppendingPathComponent(attachment.path!)
        if let path = targetImgeURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                imageView.image = UIImage(contentsOfFile: path)
            }
        }
        title = attachment.path
    }
    
    
    @IBAction func didTapDelete(sender: AnyObject) {
        attachment.managedObjectContext?.deleteObject(attachment)
        do {
            if let path = attachment.path {
                deleteFileAtPath(path)
            }
            try attachment.managedObjectContext?.save()
            navigationController?.popViewControllerAnimated(true)
        } catch {
        }
    }
    
    func deleteFileAtPath(path: String) {
        guard let managedObjectContext = attachment.managedObjectContext else { return }
        let fetchRequest = NSFetchRequest(entityName: "Attachment")
        fetchRequest.predicate = NSPredicate(format: "path = %@", argumentArray: [path])
        do {
            if let attachments = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Attachment] {
                if attachments.count == 0 {
                    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    let fileURL = documentsURL.URLByAppendingPathComponent(path)
                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                }
            }
        } catch {
            
        }
    }
}
