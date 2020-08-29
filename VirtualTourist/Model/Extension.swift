//
//  Extiinsion.swift
//  VirtualTourist
//
//  Created by Lama AlMayouf on 8/11/20.
//  Copyright © 2020 Lama AlMayouf. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Point: MKAnnotation{
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }
    
       class func keyPathsForValuesAffectingCoordinate() -> Set<String> {
         return Set<String>([ #keyPath(latitude), #keyPath(longitude) ])
     }
    
}

extension Image{
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    func fetchImage() -> UIImage?{
        if let image = image{
             return UIImage(data: image)
        }
       return nil
    }
}

extension UIViewController{
func showAlert(title: String, message: String) {
         let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
         present(alertController, animated: true, completion: nil)
     }
}

extension MKCoordinateRegion {
  public func write(toDefaults defaults:UserDefaults, withKey key:String) {
    let locationData = [center.latitude, center.longitude,
                        span.latitudeDelta, span.longitudeDelta]
    defaults.set(locationData, forKey: key)
  }

  public static func load(fromDefaults defaults:UserDefaults, withKey key:String) -> MKCoordinateRegion? {
    guard let region = defaults.object(forKey: key) as? [Double] else { return nil }
    let center = CLLocationCoordinate2D(latitude: region[0], longitude: region[1])
    let span = MKCoordinateSpan(latitudeDelta: region[2], longitudeDelta: region[3])
    return MKCoordinateRegion(center: center, span: span)
  }
}

extension NSManagedObjectContext {
    
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter batchDeleteRequest: The `NSBatchDeleteRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
