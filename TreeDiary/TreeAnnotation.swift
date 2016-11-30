//
//  TreeAnnotation.swift
//  TreeDiary
//
//  Created by Stephen Williams on 7/08/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import MapKit

class TreeAnnotation: MKPointAnnotation {
    var tree: Tree!
    
    init(tree: Tree) {
        super.init()
        self.tree = tree
        self.coordinate = CLLocationCoordinate2DMake(tree.latitude, tree.longitude)
        title = tree.commonName
        subtitle = tree.variety
    }
}
