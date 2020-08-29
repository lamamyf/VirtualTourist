//
//  DataController.swift
//  VirtualTourist
//
//  Created by Lama AlMayouf on 8/11/20.
//  Copyright © 2020 Lama AlMayouf. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    static let shared = DataController()
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    private init(){
        persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    }
    
    func load(){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                return
            }
            
            self.autoSaveViewContext()
        }
    }
    
    private func autoSaveViewContext(timeInterval: TimeInterval = 30){
        let interval = timeInterval > 0 ? timeInterval : 30
        
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext()
        }
        
    }
    
}
