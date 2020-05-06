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
            let n0 = self.newNote()
            n0.text = "Jackdaw\nA fine grey and black bird with pale eyes, related to but smaller than the carrion crow.\nThough thievish and mischievous to the farmer, the jackdaw is a curious and intelligent bird. It has been observed using tools for complex problem solving, like its Corvid cousins.\nThe jackdaw collects and decorates its nest with bright objects. Owing to its fondness for picking up coins, Linnaeus gave it the binomial name Corvus monedula, mǒnēdŭla being derived from the Latin stem of \"money\".\nThe collective noun for a group is a \"clattering\" of jackdaws. The jackdaw call is a familiar hard 'tchack' from which it gets its name. They are gregarious and vocal birds and live in small groups with complex social structures. It will commonly nest in chimneys, buildings, rock crevices and tree holes."
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
