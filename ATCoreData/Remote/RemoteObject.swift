//
//  RemoteObject.swift
//  ATCoreData
//
//  Created by Nicolás Landa on 11/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import CoreData
import Foundation

@objc public protocol Identificable {
	var remoteID: String? { get set }
}

@objc public protocol TimeStampable {
	var createdAt: Date? { get set }
	var updatedAt: Date? { get set }
}

public typealias RemoteObjectInfoProvider = Identificable & TimeStampable
public protocol RemoteObject: ATManaged, RemoteObjectInfoProvider { }

public extension RemoteObject {
	
	public typealias RemoteID = String
	
	public static func predicate(forRemoteID remoteID: RemoteID) -> NSPredicate {
		let remoteIDKeyPath = #keyPath(RemoteObject.remoteID)
		return NSPredicate(format: "%K = %@", remoteIDKeyPath, remoteID)
	}
	
	public typealias ConfigureObjectBlock<T> = (T) -> Void
	
	/// Busca en el contexto el objeto con el identificador remoto provisto
	///
	/// - Parameters:
	///   - context: contexto en el que buscar
	///   - remoteID: identificador remoto a buscar
	/// - Returns: El objeto encontrado o nulo
	public static func findOrFetch<T>(in context: NSManagedObjectContext, remoteID: RemoteID) -> T? where T: RemoteObject, T: NSManagedObject {
		return T.findOrFetch(in: context, matching: T.predicate(forRemoteID: remoteID))
	}
	
	/// Busca o crea el objeto en el contexto con el identificador remoto provisto por el `RemoteObjectInfoProvider`
	///
	/// - Parameters:
	///   - context: contexto en el que buscar
	///   - remoteObjectInfo: información del objeto remoto
	///   - configure: bloque para configurar el objeto recuperado o creado
	/// - Returns: El objeto recuperado o creado
	public static func findOrCreate<T>(in context: NSManagedObjectContext, remoteObjectInfo: RemoteObjectInfoProvider, configure: ConfigureObjectBlock<T>) -> T where T: RemoteObject, T: NSManagedObject {
		guard let remoteID = remoteObjectInfo.remoteID else { preconditionFailure() }
		
		let localObject: T = T.findOrCreate(in: context, matching: predicate(forRemoteID: remoteID)) {
			$0.remoteID = remoteID
			$0.createdAt = remoteObjectInfo.createdAt
			$0.updatedAt = remoteObjectInfo.updatedAt
		}
		
		configure(localObject)
		
		return localObject
	}
	
	public static var defaultSortDescriptors: [NSSortDescriptor] {
		return [NSSortDescriptor(key: #keyPath(RemoteObject.updatedAt), ascending: false)]
	}
	
	public static var defaultPredicate: NSPredicate {
		return NSPredicate(value: true)
	}
}
