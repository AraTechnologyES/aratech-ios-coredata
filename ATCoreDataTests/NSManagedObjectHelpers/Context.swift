//
//  Context.swift
//  ATCoreDataTests
//
//  Created by Nicolás Landa on 11/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import CoreData
@testable import ATCoreData

var testDataController: ATDataControllerMock {
	return ATDataControllerMock()
}

var testContext: NSManagedObjectContext {
	return testDataController.persistentContainerMock.viewContext
}

extension ATManaged where Self: ATCoreData.User {
	public static var managedEntityDescription: NSEntityDescription {
		return NSEntityDescription.entity(forEntityName: "User", in: testContext)!
	}
}

extension ATManaged where Self: ATCoreData.Commentary {
	public static var managedEntityDescription: NSEntityDescription {
		return NSEntityDescription.entity(forEntityName: "Commentary", in: testContext)!
	}
}
