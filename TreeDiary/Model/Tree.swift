//
//  Tree.swift
//  TreeDiary
//
//  Created by Stephen Williams on 31/07/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import Foundation
import CoreData

@objc class Tree: NSManagedObject {
    @NSManaged var commonName: String?
    @NSManaged var variety: String?
    @NSManaged var botanicalName: String?
    @NSManaged var notes: String?
    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var harvestingMonths: String
    @NSManaged var floweringMonths: String
    @NSManaged var timeStamp: NSDate
    @NSManaged var attachments: [Attachment]
    @NSManaged var diaryEntries: [DiaryEntry]
}