//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Dave Arnoldi on 2014/10/27.
//  Copyright (c) 2014 Dave Arnoldi. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context: CIContext = CIContext(options: nil)
    
    var filters:[CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//UICollectionViewDataSource
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        if cell.imageView.image == nil {
            cell.imageView.image = placeHolderImage
        
        //multithreading
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCacheImage(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })
        }
        
        
        
        
        return cell
        
    }
    
    
    //UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        CreateUIAlerController()
        
        
//        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
//        
//        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
//        
//        self.thisFeedItem.image = imageData
//        
//        let thumbnailData = UIImageJPEGRepresentation(filterImage, 0.1)
//        thisFeedItem.thumbnail = thumbnailData
//        
//        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
//        
//        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    //Helpers
    
    func photoFilters () -> [CIFilter]  {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colourControls = CIFilter(name: "CIColorControls")
        colourControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        
        
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colourControls, sepia, colorClamp, composite, vignette]
        
        
    }
    
    func filteredImageFromImage (imagedata: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imagedata)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage: CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
        
        
        
    }
    
    //UIAlertController Helper Functions
    
    func CreateUIAlerController () {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption"
            textField.secureTextEntry = false
            
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    // caching functions
    
    func cacheImage (imageNumber: Int) {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            let data = self.thisFeedItem.thumbnail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
            
        }
        
    }
    
    
    func getCacheImage (imageNumber: Int) -> UIImage {
        let filename = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(filename)
        
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
            
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
            
        }
        return image
        
    }
}












