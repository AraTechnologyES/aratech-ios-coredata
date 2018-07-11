//
//  Insertions.swift
//  ATCoreDataTests
//
//  Created by Nicolás Landa on 11/7/18.
//  Copyright © 2018 Aratech. All rights reserved.
//

@testable import ATCoreData

internal func insertUser(email: String, in context: NSManagedObjectContext) -> ATCoreData.User {
	let obj: ATCoreData.User = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! ATCoreData.User
	
	obj.setValue(email, forKey: "email")
	
	return obj
}

internal func insertComment(owner: ATCoreData.User, text: String, in context: NSManagedObjectContext) -> ATCoreData.Commentary {
	let comment: ATCoreData.Commentary = NSEntityDescription.insertNewObject(forEntityName: "Commentary", into: context) as! ATCoreData.Commentary
	
	comment.owner = owner
	comment.text = text
	
	return comment
}

internal func insertUsersWithComments(in context: NSManagedObjectContext) -> ([ATCoreData.User], [ATCoreData.Commentary]) {
	let user1 = insertUser(email: "user1", in: context)
	let user2 = insertUser(email: "user2", in: context)
	
	let comment1 = insertComment(owner: user1, text: "Comment 1", in: context)
	let comment2 = insertComment(owner: user1, text: "Comment 2", in: context)
	let comment3 = insertComment(owner: user2, text: "Comment 3", in: context)
	
	user1.addToComments(comment1)
	user1.addToComments(comment2)
	
	user2.addToComments(comment3)
	
	return ([user1, user2], [comment1, comment2, comment3])
}
