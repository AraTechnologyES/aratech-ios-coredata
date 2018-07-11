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
