//
//  Note+CoreDataClass.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-04-30.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//
//

import CoreData
import SwiftUI

@objc(Note)
public class Note: NSManagedObject, Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var text: String
    @NSManaged public var id: UUID
    @NSManaged public var sortDate: Date
    
    @NSManaged public var imageData: Data?
    @NSManaged public var thumbnailData: Data?

    func addImage(uiImage: UIImage) {
        self.imageData = uiImage.pngData()
        self.thumbnailData = uiImage.pngData()
    }
}
