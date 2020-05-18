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
    
    @NSManaged public var id: UUID?
    @NSManaged public var sortDate: Date
    @NSManaged public var text: String

    lazy var headline: String = String(text.trimmingCharacters(in: .whitespaces).split(separator: "\n").first ?? "")
    
    var body: String {
        get {
            guard let newlineIndex = text.trimmingCharacters(in: .whitespaces).firstIndex(of: "\n") else {
                return ""
            }
            return String(text.trimmingCharacters(in: .whitespaces)[newlineIndex...].trimmingCharacters(in: .whitespaces))
        }
    }

}

// MARK: - images

extension Note {
    @NSManaged public var imageData: Data?
    @NSManaged private var thumbnailData: Data?
    
    var image: UIImage? {
        set {
            guard let newValue = newValue else {
                self.imageData = nil
                self.thumbnailData = nil
                return
            }
            self.imageData = newValue.pngData()
            
            let size = newValue.size
            let maxHeight: CGFloat = 90
            let maxWidth: CGFloat = 90
            let widthRatio = maxWidth / size.width
            let heightRatio = maxHeight / size.height
            
            if heightRatio > 1 && widthRatio > 1 {
                self.thumbnailData = newValue.pngData()
                return
            }
            
            var newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            newValue.draw(in: rect)
            let smallImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.thumbnailData = smallImage!.pngData()
        }
        get {
            return imageData != nil ? UIImage(data:imageData!) : nil
        }
    }
    
    var thumbnail: UIImage? {
        get { return thumbnailData != nil ? UIImage(data:thumbnailData!) : nil }
    }
}
