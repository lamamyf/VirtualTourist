//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Lama AlMayouf on 8/11/20.
//  Copyright © 2020 Lama AlMayouf. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var fetchedResultsController: NSFetchedResultsController<Point>!
    
    func setupFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Point> = Point.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            debugPrint(error.localizedDescription)
        }
        
        loadAnnotations()
    }
    
    func loadAnnotations(){
        guard  let points = fetchedResultsController.fetchedObjects else{
            return
        }
        
        var annotations = [MKPointAnnotation]()
        for point in points{
            let annotation = MKPointAnnotation()
            annotation.coordinate = point.coordinate
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handelMapTapped(sender:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.isZoomEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
         if let region = MKCoordinateRegion.load(fromDefaults: UserDefaults.standard, withKey: "region") {
            mapView.region = region
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.region.write(toDefaults: UserDefaults.standard, withKey: "region")
    }
    
    @objc func handelMapTapped(sender: UIGestureRecognizer){
        if sender.state == .ended{
            let location  = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            addAnnotation(coordinate: coordinate)
        }
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D){
        let point = Point(context: DataController.shared.viewContext)
        point.latitude = coordinate.latitude
        point.longitude = coordinate.longitude
        try? DataController.shared.viewContext.save()
    }
    
    
    @IBAction func deletePins(_ sender: Any) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? DataController.shared.viewContext.executeAndMergeChanges(using: batchDeleteRequest)
    }
}

extension TravelLocationsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let resuedIdentifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: resuedIdentifier)
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: resuedIdentifier)
            pinView?.tintColor =  UIColor.red
        }else{
            pinView?.annotation = annotation
        }
    
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        
        let points = fetchedResultsController.fetchedObjects!
        var selectedPoint: Point!
        for point in points{
            if point.coordinate.latitude == view.annotation?.coordinate.latitude && point.coordinate.longitude == view.annotation?.coordinate.longitude {
                selectedPoint = point
                break
            }
        }
        photoAlbumViewController.point = selectedPoint
        navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
         mapView.region.write(toDefaults: UserDefaults.standard, withKey: "region")
    }

}

extension TravelLocationsViewController: NSFetchedResultsControllerDelegate{
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let point = anObject as? Point else {
            return
        }
        switch type {
        case .insert:   mapView.addAnnotation(point)
        case .delete: mapView.removeAnnotation(point)
        default:
            break
        }
    }
}
