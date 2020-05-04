//
//  Data.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-04.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import CoreData
import UIKit

class UserData {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func newNote() -> Note {
        let newNote = Note(context:context)
        newNote.text = ""
        newNote.id = UUID()
        newNote.sortDate = Date()
        self.save()
        return newNote
    }
    
    func save() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
    
    func delete(note: Note) {
        context.delete(note)
        self.save()
    }
    
    func deleteAllNotes() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print ("error with deleteAllNotes: \(error)")
        }
    }
    
    func storeUIImage(image: UIImage) -> String {
        // return the reference name
        // https://fluffy.es/store-image-coredata/
        return ""
    }
}
