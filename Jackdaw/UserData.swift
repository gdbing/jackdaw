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
    
    func fakePreviewData() {
        if self.entityIsEmpty(entity: "Note") {
            let n1 = self.newNote()
            n1.text = "A thousand bees\nfilling your mouth and nostrils\netc etc"
            let n2 = self.newNote()
            n2.text = "hamboning"
            let n3 = self.newNote()
            n3.text = "ONE two THREE four"
        }
    }
    
    func entityIsEmpty(entity: String) -> Bool
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        var count = -1
        do {
            try self.context.fetch(request)
            count = try context.count(for: request)
        } catch {
            print("Error: \(error)")
        }
        
        if count == 0 {
            return true
        } else {
            return false
        }
    }
    
}
