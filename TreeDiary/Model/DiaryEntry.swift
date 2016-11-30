//
//  Entry.swift
//  TreeDiary
//
//  Created by Stephen Williams on 31/07/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import CoreData

@objc class DiaryEntry: NSManagedObject {
    @NSManaged var title: String!
    @NSManaged var text: String!
    @NSManaged var timeStamp: NSDate
    @NSManaged var tree: Tree?
    
    private static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    func attributedString() -> NSAttributedString {
        let time = "\(DiaryEntry.formatter.stringFromDate(timeStamp))\n"
        let titleLine = title.isEmpty ? "" : "\(title)\n"
        let textLine = text.isEmpty ? "" : "\(text)\n\n"
        let fullText = "\(time)\(titleLine)\(textLine)"
        let attributedString = NSMutableAttributedString(string: fullText)
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        attributedString.addAttributes([NSForegroundColorAttributeName:UIColor.grayColor()], range:(fullText as NSString).rangeOfString(time))
        attributedString.addAttribute(NSFontAttributeName, value:headlineFont, range:(fullText as NSString).rangeOfString(titleLine))
        attributedString.addAttribute(NSFontAttributeName, value:bodyFont, range:(fullText as NSString).rangeOfString(textLine))
        return attributedString
    }
}