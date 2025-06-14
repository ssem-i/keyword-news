//
//  SummaryEntity+CoreDataProperties.swift
//  KeyNews
//
//  Created by ssem on 6/15/25.
//
//

import Foundation
import CoreData


extension SummaryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SummaryEntity> {
        return NSFetchRequest<SummaryEntity>(entityName: "SummaryEntity")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: Date?
    @NSManaged public var keyword: String?

}

extension SummaryEntity : Identifiable {

}
