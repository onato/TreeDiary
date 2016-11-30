//
//  DesignableXIBView.swift
//  TreeDiary
//
//  Created by Stephen Williams on 22/08/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit

class DesignableXIBView: UIControl {
    @IBOutlet weak var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last ?? "ClassNameNotFound"
        bundle.loadNibNamed(className, owner: self, options: [:])
        addSubview(view)
        
        let viewBindingsDict = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindingsDict))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindingsDict))
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
}
