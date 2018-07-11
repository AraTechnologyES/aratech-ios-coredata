//
//  DataController.swift
//  ATCoreData Example iOS
//
//  Created by Nicolás Landa on 11/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import Foundation
import CoreData
import ATCoreData

class DataController: NSObject {
	
	var persistentContainer: ATPersistentContainer
	
	init(completion: @escaping () -> Void) {
		
		self.persistentContainer = ATPersistentContainer(name: "ODR")
		
		self.persistentContainer.loadPersistentStores { (description, error) in
			if let error = error {
				fatalError("Failed to load Core Data stack: \(error)")
			}
			
			completion()
		}
		
		super.init()
		
		// Observers when a context has been saved
		NotificationCenter.default.addObserver(self.persistentContainer,
											   selector: #selector(self.persistentContainer.contextSave(_:)),
											   name: NSNotification.Name.NSManagedObjectContextDidSave,
											   object: nil)
	}
}

