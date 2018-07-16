//
//  NSManagedObjectContext+Extensions.swift
//  ODR
//
//  Created by Nicolás Landa on 8/6/18. Credits to https://www.objc.io/books/core-data/
//  Copyright © 2018 Aratech. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
	
	public func insertObject<A: NSManagedObject>() -> A where A: ATManaged {
		guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
		return obj
	}
	
	/// Guarda los cambios en el contexto o loguea el error obtenido al intentarlo.
	/// Credits to [Andyshep](https://github.com/andyshep/Palettes)
	public func saveOrLog() {
		do {
			try saveOrLogAndThrow()
		} catch { }
	}
	
	/// Guarda los cambios en el contexto o loguea el error obtenido y lo lanza
	///
	/// - Throws: El error obtenido al guardar el contexto
	///
	/// Credits to [Andyshep](https://github.com/andyshep/Palettes)
	public func saveOrLogAndThrow() throws {
		do {
			if self.hasChanges {
				try self.save()
			}
		} catch let nsError as NSError {
			NSLog("%@", nsError.localizedDescription)
			throw nsError
		}
	}
	
//	private var store: NSPersistentStore {
//		guard let psc = persistentStoreCoordinator else { fatalError("PSC missing") }
//		guard let store = psc.persistentStores.first else { fatalError("No Store") }
//		return store
//	}
//
//	public var metaData: [String: AnyObject] {
//		get {
//			guard let psc = persistentStoreCoordinator else { fatalError("must have PSC") }
//			return psc.metadata(for: store) as [String : AnyObject]
//		}
//		set {
//			performChanges {
//				guard let psc = self.persistentStoreCoordinator else { fatalError("PSC missing") }
//				psc.setMetadata(newValue, for: self.store)
//			}
//		}
//	}
//
//	public func setMetaData(object: AnyObject?, forKey key: String) {
//		var md = metaData
//		md[key] = object
//		metaData = md
//	}
	
	
	
//	public func saveOrRollback() -> Bool {
//		do {
//			try save()
//			return true
//		} catch {
//			rollback()
//			return false
//		}
//	}
//	
//	public func performSaveOrRollback() {
//		perform {
//			_ = self.saveOrRollback()
//		}
//	}
//	
//	public func performChanges(block: @escaping () -> ()) {
//		perform {
//			block()
//			_ = self.saveOrRollback()
//		}
//	}
	
}

private let SingleObjectCacheKey = "SingleObjectCache"
private typealias SingleObjectCache = [String: NSManagedObject]

public extension NSManagedObjectContext {
	public func set(_ object: NSManagedObject?, forSingleObjectCacheKey key: String) {
		var cache = userInfo[SingleObjectCacheKey] as? SingleObjectCache ?? [:]
		cache[key] = object
		userInfo[SingleObjectCacheKey] = cache
	}
	
	public func object(forSingleObjectCacheKey key: String) -> NSManagedObject? {
		guard let cache = userInfo[SingleObjectCacheKey] as? [String: NSManagedObject] else { return nil }
		return cache[key]
	}
}
