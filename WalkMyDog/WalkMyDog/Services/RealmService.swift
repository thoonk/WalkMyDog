//
//  RealmService.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/13.
//

import RealmSwift
import UIKit

enum RealmError: Error {
    case InstanceError
    case SavingError
    case MatchingError
    case UpdatingError
    case RemovingError
}

protocol RealmServiceProtocol {
    func saveObjects<T>(_ objects: [T]) throws where T: Object
    func saveObject<T>(_ object: T) throws where T: Object
    func fetchObjects(_ type: Object.Type) -> [Object]?
    func fetchObjects<T>(_ type: T.Type, predicate: NSPredicate) -> [T]? where T: Object
    func removeObjects<T>(_ objects: [T]) throws where T: Object
    func removeObject<T>(_ object: T) throws where T: Object
    func removeAll() throws
    func updateObjects<T>(_ objects: [T]) throws where T: Object
    func updateObject<T>(_ object: T) throws where T: Object
    func increamentID<T>(_ type: T.Type) throws -> Int? where T: Object
}

class RealmService<T>: RealmServiceProtocol {
    func getRealm() -> Realm? {
        return try? Realm()
    }
    
    func saveObjects<T>(_ objects: [T]) throws where T: Object  {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }
        
        do {
            try realm.write {
                realm.add(objects)
            }
        } catch {
            throw RealmError.SavingError
        }
    }
    
    func saveObject<T>(_ object: T) throws where T: Object {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }

        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            throw RealmError.SavingError
        }
    }
    
    func fetchObjects(_ type: Object.Type) -> [Object]? {
        guard let realm = try? Realm() else { return nil }
        let results = realm.objects(type)
        return Array(results)
    }
    
    func fetchObjects<T>(_ type: T.Type, predicate: NSPredicate) -> [T]? where T: Object {
        guard let realm = try? Realm() else { return  nil}
        let results = realm.objects(type)
        return Array(results)
    }
    
    func removeObjects<T>(_ objects: [T]) throws where T: Object {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }
        
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            throw RealmError.RemovingError
        }
    }
    
    func removeObject<T>(_ object: T) throws where T: Object {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }
        
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            throw RealmError.RemovingError
        }
    }
    
    func removeAllObjectsOfType<T>(_ type: T.Type) throws where T: Object {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }
        
        do {
            try realm.write {
                realm.delete(realm.objects(T.self))
            }
        } catch {
            throw RealmError.RemovingError
        }
    }
    
    func removeAll() throws {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            throw RealmError.RemovingError
        }
    }
    
    func updateObjects<T>(_ objects: [T]) throws where T: Object {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }

        do {
            let primaryKey = objects.map ({ element -> Any in
                element.value(forKey: T.primaryKey()!) as Any
            })
            
            let response = realm.objects(T.self).filter("%@ IN %@", T.primaryKey()!, primaryKey)
            
            if response.count != objects.count {
                throw RealmError.MatchingError
            }
            
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            throw RealmError.UpdatingError
        }
    }
    
    func updateObject<T>(_ object: T) throws where T: Object {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }

        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            throw RealmError.UpdatingError
        }
    }
    
    func increamentID<T>(_ type: T.Type) throws -> Int? where T: Object {
        guard let realm = self.getRealm()
        else {
            throw RealmError.InstanceError
        }
        
        return (realm.objects(T.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
