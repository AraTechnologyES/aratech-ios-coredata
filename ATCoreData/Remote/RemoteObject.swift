//
//  RemoteObject.swift
//  ATCoreData
//
//  Created by Nicolás Landa on 11/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import CoreData
import Foundation

/// Un objeto que puede ser identificado en un sistema remoto
@objc public protocol RemoteIdentificable {
	/// Identificador remoto
	var remoteID: String { get set }
}

/// Un objeto cuya creación y/o actualización puede ser ubicada en el tiempo
@objc public protocol TimeStampable {
	/// Creación del objeto
	var createdAt: Date? { get set }
	/// Última actualización del objeto
	var updatedAt: Date? { get set }
}

/// Un objeto remoto
public protocol RemoteObject: RemoteIdentificable { }
