//
//  Note+CoreDataProperties.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-04-30.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//
//

import Foundation
import CoreData


extension Note: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var text: String
    @NSManaged public var id: UUID
    
}
