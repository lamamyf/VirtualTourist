//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Lama AlMayouf on 8/11/20.
//  Copyright © 2020 Lama AlMayouf. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var newCollectionBtn: UIBarButtonItem!
    var point: Point!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    
    var isEmpty: Bool{
        return fetchedResultsController.fetchedObjects?.count == 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        setupFetchedResultsController()
        if isEmpty{
            loadImages()
        }
    }
    
    func setupFetchedResultsController(){
           let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
           fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
           fetchRequest.predicate = NSPredicate(format: "point == %@", point)
           fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
           fetchedResultsController.delegate = self
           do{
               try fetchedResultsController.performFetch()
           }catch{
               debugPrint(error.localizedDescription)
           }
       }
       
    func loadImages(page: Int = 1){
        newCollectionBtn.isEnabled = false
        API.loadImageData(page: page, lat: point.latitude, lon: point.longitude) { (errorString, urls) in
                guard errorString == nil else{
                    self.showAlert(title: "ERROR", message: errorString!)
                    self.newCollectionBtn.isEnabled = true
                    return
                }
                guard urls!.count > 0 else{
                    self.label.isHidden = false
                    self.label.text = "No Images Found"
                    self.newCollectionBtn.isEnabled = true
                    return
                }
                for url in urls!{
                    let image = Image(context: DataController.shared.viewContext)
                    image.point = self.point
                    image.url = url
                    try? DataController.shared.viewContext.save()
                }
            self.newCollectionBtn.isEnabled = true
        }
    }
    
    
  
    @IBAction func handNewCollectionTapped(_ sender: Any) {
        for image in point.images!{
        DataController.shared.viewContext.delete(image as! NSManagedObject)
         }
        try? DataController.shared.viewContext.save()
        let page = Int.random(in: 1..<5)
        loadImages(page: page)
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageObj = fetchedResultsController.object(at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(imageToDelete)
        try? DataController.shared.viewContext.save()
    }

}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout{
      func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        let widthPerItem = availableWidth / 2
    
        return CGSize(width: widthPerItem, height: widthPerItem)
  }
  

  func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
  }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
  func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
  minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
  }

 func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
}
    

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionView.reloadData()
    }
}
