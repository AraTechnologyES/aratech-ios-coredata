//
//  ATDataControllerMock.swift
//  ATCoreDataTests
//
//  Created by Nicolás Landa on 4/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import CoreData
@testable import ATCoreData

class ATDataControllerMock {
	
	private lazy var managedObjectModel: NSManagedObjectModel = {
		let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
		return managedObjectModel
	}()
	
	lazy var persistentContainerMock: ATPersistentContainer = {
		
		let container = ATPersistentContainer(name: "ATCoreData", managedObjectModel: self.managedObjectModel)
		let description = NSPersistentStoreDescription()
		description.type = NSInMemoryStoreType
		description.shouldAddStoreAsynchronously = false // Make it simpler in test env
		
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores { (description, error) in
			// Check if the data store is in memory
			precondition( description.type == NSInMemoryStoreType )
			
			// Check if creating container wrong
			if let error = error {
				fatalError("Create an in-mem coordinator failed \(error)")
			}
		}
		return container
	}()
}
