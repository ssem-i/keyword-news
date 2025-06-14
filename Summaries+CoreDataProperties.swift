//
//  Summaries+CoreDataProperties.swift
//  KeyNews
//
//  Created by ssem on 6/15/25.
//
//

import Foundation
import CoreData


extension KeyNews.Summaries {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Summaries> {
        return NSFetchRequest<Summaries>(entityName: "Summaries")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var keyword: String?

}

extension Summaries : Identifiable {

}
