//
//  ResultsControllerDataSource.swift
//  ATCoreData
//
//  Created by Nicolás Landa on 17/9/18.
//  Copyright © 2018 Aratech. All rights reserved.
//
// https://www.swiftbysundell.com/posts/reusable-data-sources-in-swift

import UIKit
import CoreData
import Foundation

open class ResultsControllerDataSource<Model: NSManagedObject>: NSObject, UITableViewDataSource {
	
	public typealias CellConfigurator = (Model, UITableViewCell) -> Void
	
	fileprivate let resultsController: NSFetchedResultsController<Model>
	fileprivate let reuseIdentifier: String
	fileprivate let configurator: CellConfigurator
	
	public init(resultsController: NSFetchedResultsController<Model>, reuseIdentifier: String, configurator: @escaping CellConfigurator) {
		self.resultsController = resultsController
		self.reuseIdentifier = reuseIdentifier
		self.configurator = configurator
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.resultsController.fetchedObjects?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let model = self.resultsController.fetchedObjects?[indexPath.row] else { preconditionFailure() }
		
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		configurator(model, cell)
		
		return cell
	}
}

open class SectionedResultsControllerDataSource<Model: NSManagedObject>: ResultsControllerDataSource<Model> {
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return self.resultsController.sections?.count ?? 0
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.resultsController.sections?[section].numberOfObjects ?? 0
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = self.resultsController.object(at: indexPath)
		
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		configurator(model, cell)
		
		return cell
	}
}
