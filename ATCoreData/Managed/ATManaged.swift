//
//  ATManaged.swift
//  ODR
//
//  Created by Nicolás Landa on 8/6/18. Credits to https://www.objc.io/books/core-data/
//  Copyright © 2018 Aratech. All rights reserved.
//

import CoreData

public protocol ATManaged: class, NSFetchRequestResult {
	static var managedEntityDescription: NSEntityDescription { get }
	static var entityName: String { get }
	static var defaultSortDescriptors: [NSSortDescriptor] { get }
	static var defaultPredicate: NSPredicate { get }
	var managedObjectContext: NSManagedObjectContext? { get }
}

public protocol DefaultManaged: ATManaged {}

public extension DefaultManaged {
	public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
}

public extension ATManaged {
	
	public static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
	public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
	
	public static var sortedFetchRequest: NSFetchRequest<Self> {
		let request = NSFetchRequest<Self>(entityName: entityName)
		request.sortDescriptors = defaultSortDescriptors
		request.predicate = defaultPredicate
		return request
	}
	
	public static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
		let request = sortedFetchRequest
		guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
		request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
		return request
	}
	
	public static func predicate(format: String, _ args: CVarArg...) -> NSPredicate {
		let p = withVaList(args) { NSPredicate(format: format, arguments: $0) }
		return predicate(p)
	}
	
	public static func predicate(_ predicate: NSPredicate) -> NSPredicate {
		return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
	}
	
}

public extension ATManaged where Self: NSManagedObject {
	
	public static var managedEntityDescription: NSEntityDescription {
		return entity()
	}
	
	public static var entityName: String {
		return managedEntityDescription.name!
	}
	
	public static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> Void) -> Self {
		guard let object = findOrFetch(in: context, matching: predicate) else {
			let newObject: Self = context.insertObject()
			configure(newObject)
			return newObject
		}
		return object
	}
	
	public static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
		guard let object = materializedObject(in: context, matching: predicate) else {
			return fetch(in: context) { request in
				request.predicate = predicate
				request.returnsObjectsAsFaults = false
				request.fetchLimit = 1
				}.first
		}
		return object
	}
	
	public static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }) -> [Self] {
		let request = NSFetchRequest<Self>(entityName: Self.entityName)
		configurationBlock(request)
		return try! context.fetch(request)
	}
	
	public static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void = { _ in }) -> Int {
		let request = NSFetchRequest<Self>(entityName: entityName)
		configure(request)
		return try! context.count(for: request)
	}
	
	public static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
		for object in context.registeredObjects where !object.isFault {
			guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
			return result
		}
		return nil
	}
	
}

public extension ATManaged where Self: NSManagedObject & RemoteIdentificable {
	
	typealias RemoteID = String
	
	static func predicate(remoteID: RemoteID) -> NSPredicate {
		return NSPredicate(format: "remoteID = %@", remoteID)
	}
	
	static func predicate(remoteObject: RemoteObject) -> NSPredicate {
		return predicate(remoteID: remoteObject.remoteID)
	}
	
	public typealias ConfigureObjectBlock = (Self) -> Void
	
	/// Busca en el contexto el objeto con el identificador remoto provisto
	///
	/// - Parameters:
	///   - context: contexto en el que buscar
	///   - remoteObject: identificador del objeto remoto a buscar
	/// - Returns: El objeto encontrado o nulo
	public static func findOrFetch(in context: NSManagedObjectContext, remoteID: RemoteID) -> Self? {
		let predicate = Self.predicate(remoteID: remoteID)
		return findOrFetch(in: context, matching: predicate)
	}
	
	/// Busca en el contexto el objeto con el identificador remoto provisto por el `RemoteObject`
	///
	/// - Parameters:
	///   - context: contexto en el que buscar
	///   - remoteObject: objeto remoto a buscar
	/// - Returns: El objeto encontrado o nulo
	public static func findOrFetch(in context: NSManagedObjectContext, remoteObject: RemoteObject) -> Self? {
		return findOrFetch(in: context, remoteID: remoteObject.remoteID)
	}
	
	/// Busca o crea el objeto en el contexto con el identificador remoto provisto
	///
	/// - Parameters:
	///   - context: contexto en el que buscar
	///   - remoteID: identificador del objeto remoto a buscar o crear
	///   - configure: bloque para configurar el objeto recuperado o creado
	/// - Returns: El objeto recuperado o creado
	public static func findOrCreate(in context: NSManagedObjectContext, remoteID: RemoteID, configure: ConfigureObjectBlock) -> Self {
		let predicate = Self.predicate(remoteID: remoteID)
		let localObject: Self = Self.findOrCreate(in: context, matching: predicate) { (remoteIdentificable) in
			remoteIdentificable.remoteID = remoteID
		}
		
		configure(localObject)
		
		return localObject
	}
	
	/// Busca o crea el objeto en el contexto con el identificador remoto provisto por el `RemoteObject`
	///
	/// - Parameters:
	///   - context: contexto en el que buscar
	///   - remoteObject: objeto remoto a buscar o crear
	///   - configure: bloque para configurar el objeto recuperado o creado
	/// - Returns: El objeto recuperado o creado
	public static func findOrCreate(in context: NSManagedObjectContext, remoteObject: RemoteObject, configure: ConfigureObjectBlock) -> Self {
		return findOrCreate(in: context, remoteID: remoteObject.remoteID, configure: configure)
	}
}

public extension ATManaged where Self: NSManagedObject {
	public static func fetchSingleObject(in context: NSManagedObjectContext, cacheKey: String, configure: (NSFetchRequest<Self>) -> Void) -> Self? {
		if let cached = context.object(forSingleObjectCacheKey: cacheKey) as? Self { return cached
		}
		let result = fetchSingleObject(in: context, configure: configure)
		context.set(result, forSingleObjectCacheKey: cacheKey)
		return result
	}
	
	fileprivate static func fetchSingleObject(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> Void) -> Self? {
		let result = fetch(in: context) { request in
			configure(request)
			request.fetchLimit = 2
		}
		switch result.count {
		case 0: return nil
		case 1: return result[0]
		default: fatalError("Returned multiple objects, expected max 1")
		}
	}
}
