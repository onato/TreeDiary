//
//  MapViewController.swift
//  TreeDiary
//
//  Created by Stephen Williams on 7/08/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    var selectedTree: Tree?
    var tileServerOverlay: MKTileOverlay?
    var tileServer: TileServer! {
        didSet {
            if let tileServerOverlay = tileServerOverlay {
                self.mapView.removeOverlay(tileServerOverlay)
            }
            self.tileServerOverlay = MKTileOverlay(URLTemplate: tileServer.templateUrl)
            tileServerOverlay!.canReplaceMapContent = true
            mapView.addOverlay(tileServerOverlay!, level: .AboveLabels)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(-41.2125, 173.052)
        let span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        self.mapView.region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: span)
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Tree", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let commonNameSortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
        let varietySortDescriptor = NSSortDescriptor(key: "variety", ascending: true)
        
        fetchRequest.sortDescriptors = [commonNameSortDescriptor, varietySortDescriptor]
        
        do {
            let trees = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Tree] ?? []
            for tree in trees {
                mapView.addAnnotation(TreeAnnotation(tree: tree))
            }
        } catch {
            
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // If the annotation is the user location, just return nil.
        if let _ = annotation as? MKUserLocation {
            return nil
        }
        
        let treeAnotation = TreeAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotation")
        let button = UIButton(type: .DetailDisclosure)
        button.addTarget(self, action: #selector(MapViewController.didTapCallout), forControlEvents: .TouchUpInside)
        treeAnotation.rightCalloutAccessoryView = button

        return treeAnotation
    }
    
    func didTapCallout() {
        performSegueWithIdentifier("ShowDetail", sender: nil)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let treeAnnotation = view.annotation as? TreeAnnotation {
            selectedTree = treeAnnotation.tree
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKTileOverlay) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        return MKOverlayRenderer()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! TreeViewController
        controller.managedObjectContext = managedObjectContext
        if let tree = selectedTree {
            controller.tree = tree
        }
    }
    
    @IBAction func didTapSettings(sender: AnyObject) {
        let alert = UIAlertController(title: "Map Styles",
                                      message: "Choose which map you would like to display",
                                      preferredStyle: .ActionSheet)
        for index in 0 ..< TileServer.count {
            let mapTileServer = TileServer(rawValue: index)!
            alert.addAction(UIAlertAction(title: mapTileServer.name, style: .Default, handler: { (alert: UIAlertAction) -> Void in
                self.tileServer = mapTileServer
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
}
