//
//  TreeViewController.swift
//  TreeDiary
//
//  Created by Stephen Williams on 30/07/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import BSImagePicker
import Photos
import SafariServices
import ImageViewer

class TreeViewController: UIViewController {

    @IBOutlet weak var commonNameTextField: UITextField!
    @IBOutlet weak var varietyTextField: UITextField!
    @IBOutlet weak var botanicalNameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var updateLocationButton: UIButton!
    @IBOutlet weak var harvestingMonths: MonthSelector!
    @IBOutlet weak var floweringMonths: MonthSelector!
    @IBOutlet weak var diaryHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var hideEverythingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var managedObjectContext: NSManagedObjectContext!
    
    let locationManager = CLLocationManager()
    var location: CLLocation? {
        didSet {
            if let location = location {
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.mapView.centerCoordinate = location.coordinate
                    let span = MKCoordinateSpan(latitudeDelta: 0.0006, longitudeDelta: 0.0006)
                    self.mapView.region = MKCoordinateRegion(center: location.coordinate, span: span)
                    self.markLocation()
                })
            }
        }
    }
    var currentLocationAnnotation: MKPointAnnotation?

    var tree: Tree? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        guard let _ = commonNameTextField else { return }
        
        // Update the user interface for the detail item.
        if let tree = self.tree {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(TreeViewController.handleLongGesture(_:)))
            attachmentCollectionView.addGestureRecognizer(longPressGesture)
            
            if tree.commonName == nil && tree.botanicalName == nil {
                commonNameTextField.becomeFirstResponder()
                setupLocation()
            }
            commonNameTextField.text = tree.commonName
            varietyTextField.text = tree.variety
            botanicalNameTextField.text = tree.botanicalName
            notesTextView.text = tree.notes ?? ""
            if let latitude = tree.valueForKey("latitude") as? Double,
                longitude = tree.valueForKey("longitude") as? Double {
                location = CLLocation(latitude: latitude, longitude: longitude)
            }
            floweringMonths.monthsString = tree.floweringMonths
            harvestingMonths.monthsString = tree.harvestingMonths
            showEverything()
            showEntries()
        } else {
            hideEverything()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        hideEverything()
        if managedObjectContext != nil {
            if tree == nil {
                tree = NSEntityDescription.insertNewObjectForEntityForName("Tree", inManagedObjectContext: managedObjectContext) as? Tree
                tree!.timeStamp = NSDate()
            }
            configureView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if let _ = self.tree {
            attachmentCollectionView.reloadData()
        } else {
            hideEverything()
        }
        showEntries()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard let tree = tree else { return }
        if commonNameTextField.text!.isEmpty && botanicalNameTextField.text!.isEmpty && varietyTextField.text!.isEmpty {
            managedObjectContext.deleteObject(tree)
        }
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = attachmentCollectionView.indexPathForItemAtPoint(gesture.locationInView(attachmentCollectionView)) else {
                break
            }
            
            self.setTheCoverPhotoToTheItemAtIndexPath(selectedIndexPath)
            
        default: ()
        }
    }
    
    func setTheCoverPhotoToTheItemAtIndexPath(indexPath: NSIndexPath) {
        for attachment in tree!.attachments {
            attachment.isCover = NSNumber(bool: false)
        }
        let attachment = tree!.attachments[indexPath.row] as Attachment
        attachment.isCover = NSNumber(bool: true)
        attachmentCollectionView.reloadData()
    }
    
    func showEverything() {
        hideEverythingView.hidden = true
    }
    
    func hideEverything() {
        view.bringSubviewToFront(hideEverythingView)
        hideEverythingView.hidden = false
    }
    
    func showEntries() {
        guard let tree = tree else { return }
        let diary = NSMutableAttributedString()
        for entry in tree.diaryEntries {
            diary.appendAttributedString(entry.attributedString())
        }
        notesTextView.attributedText = diary
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = notesTextView.sizeThatFits(CGSizeMake(CGRectGetWidth(notesTextView.frame), CGFloat(FLT_MAX)))
        diaryHeightContraint.constant = size.height - 50
    }
    
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapSave(sender: AnyObject) {
        guard let tree = tree,
            managedObjectContext = managedObjectContext else { return }
        
        tree.commonName = commonNameTextField.text
        tree.variety = varietyTextField.text
        tree.botanicalName = botanicalNameTextField.text
        tree.notes = notesTextView.text
        if let location = location {
            tree.latitude = location.coordinate.latitude
            tree.longitude = location.coordinate.longitude
        }
        tree.floweringMonths = floweringMonths.monthsString
        tree.harvestingMonths = harvestingMonths.monthsString
        
        do {
            try managedObjectContext.save()
            dismissViewControllerAnimated(true, completion: nil)
            navigationController?.popViewControllerAnimated(true)
            if let navController = splitViewController?.viewControllers[0] as? UINavigationController {
                navController.popViewControllerAnimated(true)
            }
        } catch {
            print("Save failed")
        }
        
    }

    @IBAction func didTapUpdateLocation(sender: AnyObject) {
        if let currentLocationAnnotation = currentLocationAnnotation {
            mapView.removeAnnotation(currentLocationAnnotation)
        }
        currentLocationAnnotation = nil
        setupLocation()
    }
    
    @IBAction func didTapAddPhoto(sender: AnyObject) {
        let vc = BSImagePickerViewController()
        vc.takePhotos = true
        
        bs_presentImagePickerController(vc, animated: true,
                                        select: { (asset: PHAsset) -> Void in
                                            // User selected an asset.
                                            // Do something with it, start upload perhaps?
            }, deselect: { (asset: PHAsset) -> Void in
                // User deselected an assets.
                // Do something, cancel upload?
            }, cancel: { (assets: [PHAsset]) -> Void in
                // User cancelled. And this where the assets currently selected.
            }, finish: { (assets: [PHAsset]) -> Void in
                // User finished with these assets
                for asset in assets {
                    self.updateLocationWithAsset(asset)
                    self.copyAndSaveAsset(asset)
                }
            }, completion: nil)
    }
    
    func markLocation() {
        guard let coordinate = location?.coordinate else { return }
        
        if let currentLocationAnnotation = currentLocationAnnotation {
            mapView.removeAnnotation(currentLocationAnnotation)
        }

        currentLocationAnnotation = MKPointAnnotation()
        currentLocationAnnotation!.coordinate = coordinate
        mapView.addAnnotation(currentLocationAnnotation!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let attachmentViewController = segue.destinationViewController as? AttachmentViewController {
            guard let indexPath = attachmentCollectionView.indexPathsForSelectedItems()?.first else { return }
            let attachment = tree!.attachments[indexPath.row] as Attachment
            attachmentViewController.attachment = attachment
        } else if let entryViewController = segue.destinationViewController as? EntryTableViewController {
            entryViewController.managedObjectContext = managedObjectContext
            entryViewController.tree = tree
        }

    }
}

extension TreeViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = manager.location
        markLocation()
        locationManager.stopUpdatingLocation()
    }
}

extension TreeViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tree == nil {
            return 0
        }
        return tree?.attachments.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AttachmentCell", forIndexPath: indexPath)
        if let attachmentCell = cell as? AttachmentCell {
            let attachment = tree!.attachments[indexPath.row] as Attachment
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            if let path = attachment.path {
                let targetImageURL = documentsURL.URLByAppendingPathComponent(path)
                attachmentCell.imageView.image = UIImage(contentsOfFile: targetImageURL.path!)
                attachmentCell.coverLabel.hidden = true
                if let isCover = attachment.isCover?.boolValue {
                    attachmentCell.coverLabel.hidden = !isCover
                }
            }
            return attachmentCell
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                                 moveItemAtIndexPath sourceIndexPath: NSIndexPath,
                                                     toIndexPath destinationIndexPath: NSIndexPath) {
        // move your data order
        print("moveItem")
    }
}

extension TreeViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < tree!.attachments.count {
            showGaleryFromIndex(indexPath.row, fromView: collectionView.cellForItemAtIndexPath(indexPath)!)
//            performSegueWithIdentifier("ShowAttachment", sender: nil)
            return
        }
    }
    
    func updateLocationWithAsset(asset: PHAsset) {
        guard let tree = tree,
            assetLocation = asset.location
            else { return }
        
        if tree.latitude == 0 {
            location = assetLocation
        }
    }
    
    func copyAndSaveAsset(asset: PHAsset) {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileName = "Image-\(asset.creationDate!.timeIntervalSince1970).JPG"
        let targetImgeURL = documentsURL.URLByAppendingPathComponent(fileName)
        let phManager = PHImageManager.defaultManager()
        let options = PHImageRequestOptions()
        options.synchronous = true; // do it if you want things running in background thread
        phManager.requestImageDataForAsset(asset, options: options)
        {   imageData,dataUTI,orientation,info in
            
            if let newData:NSData = imageData
            {
                newData.writeToFile(targetImgeURL.path!, atomically: true)
                if let attachment = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: self.managedObjectContext!) as? Attachment {
                    attachment.type = "image"
                    attachment.path = fileName
                    attachment.tree = self.tree
                }
            }
        }
    }
}

class TreeImageProvider: ImageProvider {
    var attachments: [Attachment] = []
    
    var imageCount: Int {
        return attachments.count
    }
    
    func provideImage(completion: UIImage? -> Void) {
        completion(UIImage(named: "image_big"))
    }
    
    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        var image: UIImage?
        let attachment = attachments[index]
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let targetImgeURL = documentsURL.URLByAppendingPathComponent(attachment.path!)
        if let path = targetImgeURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                image = UIImage(contentsOfFile: path)
            }
        }

        completion(image)
    }
}

extension TreeViewController {
    func showGaleryFromIndex(index: Int, fromView displacedView: UIView) {
        guard let tree = tree else { return }
        let imageProvider = TreeImageProvider()
        imageProvider.attachments = tree.attachments
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: index, count: tree.attachments.count)
        let footerView = CounterView(frame: frame, currentIndex: index, count: tree.attachments.count)
        
        let galleryViewController = GalleryViewController(imageProvider: imageProvider,
                                                          displacedView: displacedView,
                                                          imageCount: tree.attachments.count,
                                                          startIndex: index)
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            headerView.currentIndex = index
            footerView.currentIndex = index
        }
        
        self.presentImageGallery(galleryViewController)
    }
}

extension TreeViewController {
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
        self.scrollView.contentOffset = CGPointZero
        self.bottomConstraint.constant = 0
    }
    
    func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool)
    {
        if !isTopLevelViewController() {
            return
        }
        
        let userInfo = notification.userInfo!
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        if originDelta > 100 {
            self.bottomConstraint.constant = 0
        } else {
            self.bottomConstraint.constant = -keyboardScreenEndFrame.size.height
        }
        
        // Scroll to the selected text once the keyboard frame changes.
        let selectedRange = descriptionTextView.selectedRange
        descriptionTextView.scrollRangeToVisible(selectedRange)
    }
}