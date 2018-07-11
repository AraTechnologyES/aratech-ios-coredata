//
//  ATManagedTests.swift
//  ATCoreDataTests
//
//  Created by Nicolás Landa on 11/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

import XCTest
@testable import ATCoreData

extension ATCoreData.User: ATManaged {
	public static var defaultSortDescriptors: [NSSortDescriptor] {
		return [NSSortDescriptor(keyPath: \ATCoreData.User.email, ascending: true)]
	}
	public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
}

class ATManagedTests: XCTestCase {

    func testDefaultSortedFetchRequest() {
		// Given
		let context = testContext
		
		let user1 = insertUser(email: "abcd@at.es", in: context)
		_ = insertUser(email: "bcd@at.es", in: context)
		
		let request = ATCoreData.User.sortedFetchRequest
		
		// When
		do {
			let sortedUsersFetchRequestResult = try context.fetch(request)
			XCTAssertEqual(sortedUsersFetchRequestResult.first, user1)
		} catch {
			let nsError = error as NSError
			XCTAssert(false, nsError.localizedDescription)
		}
    }
	
	func testDefaultSortedFetchRequestWithPredicate() {
		// Given
		let context = testContext
		
		let user1 = insertUser(email: "abcd@at.es", in: context)
		_ = insertUser(email: "bcd@at.es", in: context)
		_ = insertUser(email: "abc@at.es", in: context)
		
		let bcdPredicate = ATCoreData.User.predicate(format: "email CONTAINS %@", "bcd")
		let request = ATCoreData.User.sortedFetchRequest(with: bcdPredicate)
		
		// When
		do {
			let sortedUsersFetchRequestResult = try context.fetch(request)
			XCTAssertEqual(sortedUsersFetchRequestResult.count, 2)
			XCTAssertEqual(sortedUsersFetchRequestResult.first, user1)
		} catch {
			let nsError = error as NSError
			XCTAssert(false, nsError.localizedDescription)
		}
	}
	
	func testFindOrCreateCreatesNewObjectWhenNotFound() {
		// Given
		let context = testContext
		
		let userPredicate = ATCoreData.User.predicate(format: "email CONTAINS %@", "created")
		let userRequest = ATCoreData.User.sortedFetchRequest(with: userPredicate)
		
		do {
			
			let emptyRequestResults = try context.fetch(userRequest)
			XCTAssertEqual(emptyRequestResults.count, 0)
			
			// When
			let user = ATCoreData.User.findOrCreate(in: context, matching: userPredicate) { user in
				user.email = "created@find.or"
			}
			
			// Then
			let userFetchRequestResult = try context.fetch(userRequest)
			XCTAssertEqual(userFetchRequestResult.count, 1)
			XCTAssertEqual(userFetchRequestResult.first, user)
			
		} catch {
			let nsError = error as NSError
			XCTAssert(false, nsError.localizedDescription)
		}
	}
	
	func testFindOrCreateFindsObjectWhenExisting() {
		// Given
		let context = testContext
		
		let userPredicate = ATCoreData.User.predicate(format: "email CONTAINS %@", "created")
		let userRequest = ATCoreData.User.sortedFetchRequest(with: userPredicate)
		let user = insertUser(email: "created@find.or", in: context)
		
		do {
			
			let emptyRequestResults = try context.fetch(userRequest)
			XCTAssertEqual(emptyRequestResults.count, 1)
			
			// When
			let newUser = ATCoreData.User.findOrCreate(in: context, matching: userPredicate, configure: { _ in })
			
			// Then
			let userFetchRequestResult = try context.fetch(userRequest)
			XCTAssertEqual(userFetchRequestResult.count, 1)
			XCTAssertEqual(newUser, user)
			
		} catch {
			let nsError = error as NSError
			XCTAssert(false, nsError.localizedDescription)
		}
	}
}
