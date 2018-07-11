//
//  ATPersistentContainerTests.swift
//  ATCoreDataTests
//
//  Created by Nicolás Landa on 4/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import XCTest
@testable import ATCoreData

class ATPersistentContainerTests: XCTestCase {

	var dataController: ATDataControllerMock = {
		return ATDataControllerMock()
	}()
	
	var context: NSManagedObjectContext {
		return self.dataController.persistentContainerMock.viewContext
	}

    func testInsertObjectWithRelation() {
		// Given
		let userRequest: NSFetchRequest<ATCoreData.User> = ATCoreData.User.fetchRequest()
		var usersFetched = try? self.context.fetch(userRequest)
		XCTAssert(usersFetched != nil)
		XCTAssert(usersFetched?.count ?? 0 == 0)
		
		let user = insertUser(email: "prueba", in: self.context)
		_ = insertComment(owner: user, text: "Texto", in: self.context)
		
		do {
			// When
			try self.context.save()
			
			// Then
			usersFetched = try? self.context.fetch(userRequest)

			XCTAssert(usersFetched != nil)
			XCTAssert(usersFetched?.count ?? 0 == 1)
			XCTAssertEqual(usersFetched?.first?.comments?.count, 1)
			
		} catch {
			NSLog("%@", error.localizedDescription)
			XCTAssert(false)
		}
    }
}
