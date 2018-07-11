//
//  ATPersistentContainer.swift
//  ATCoreData
//
//  Created by Nicolás Landa on 4/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import CoreData

class ATPersistentContainer: NSPersistentContainer {
	
	/// Elimina masivamente los objetos especificados mediante `NSFetchRequest`
	///
	/// - Parameter request: Peticiones que especifican qué objetos borrar
	///
	/// - Creditos: @MarcoSantaDev
	func batchDelete(for requests: [NSFetchRequest<NSFetchRequestResult>]) {
		performBackgroundTask { privateManagedObjectContext in
			
			for request in requests {
				
				// Creates new batch delete request with a specific request
				let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
				
				// Asks to return the objectIDs deleted
				deleteRequest.resultType = .resultTypeObjectIDs
				
				do {
					// Executes batch
					let result = try privateManagedObjectContext.execute(deleteRequest) as? NSBatchDeleteResult
					
					guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
					NSLog("Eliminados \(objectIDs.count) objetos de tipo \(request.entityName ?? "null")")
					
				} catch {
					fatalError("Failed to execute request: \(error)")
				}
			}
			
			// Updates the main context
			self.viewContext.reset()
		}
	}
	
	/// Guarda el contexto principal
	///
	/// - Creditos: @MarcoSantaDev
	@objc func contextSave(_ notification: Notification) {
		// Retrieves the context saved from the notification
		guard let context = notification.object as? NSManagedObjectContext else { return }
		// Checks if the parent context is the main one
		if context.parent === self.viewContext {
			// Saves the main context
			self.viewContext.perform {
				do {
					if self.viewContext.hasChanges {
						try self.viewContext.save()
					}
				} catch {
					NSLog("%@", error.localizedDescription)
				}
			}
		}
	}
}

