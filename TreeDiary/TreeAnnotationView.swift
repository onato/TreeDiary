//
//  TreeAnnotationView.swift
//  TreeDiary
//
//  Created by Stephen Williams on 7/08/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import MapKit

class TreeAnnotationView: MKPinAnnotationView {
    var tree: Tree!
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String?) {
        if let treeAnnotation = annotation as? TreeAnnotation {
            self.tree = treeAnnotation.tree
        }
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        pinTintColor = UIColor(red: 54/255, green: 204/255, blue: 30/255, alpha: 0.7)
        canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
