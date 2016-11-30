//
//  Attachment.swift
//  TreeDiary
//
//  Created by Stephen Williams on 31/07/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import CoreData

@objc class Attachment: NSManagedObject {
    @NSManaged var path: String?
    @NSManaged var type: String?
    @NSManaged var isCover: NSNumber?
    @NSManaged var tree: Tree?
    @NSManaged var timeStamp: NSDate
    
    func image() -> UIImage? {
        guard let path = path else { return nil }
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let targetImgeURL = documentsURL.URLByAppendingPathComponent(path)
        if let path = targetImgeURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                return UIImage(contentsOfFile: path)
            }
        }

        return nil
    }
}