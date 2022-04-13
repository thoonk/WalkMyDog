//
//  RealmService.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/13.
//

import RealmSwift

protocol RealmServiceProtocol {
    func insertPuppy(
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String?
    ) -> Bool
    
    func updatePuppy(
        with prev: Puppy?,
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String?
    ) -> Bool
    
    func deletePuppy(with puppy: Puppy) -> Bool
    func incrementID() -> Int?
}

final class RealmService: RealmServiceProtocol {
    private func getRealm() -> Realm {
        return try! Realm()
    }
    
    func insertPuppy(
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String? = nil
    ) -> Bool {
        let realm = self.getRealm()
        do {
            if let id = self.incrementID() {
                let puppy = Puppy(
                    id: id,
                    name: name,
                    age: age,
                    gender: gender,
                    weight: weight,
                    species: species,
                    imageURL: imageURL
                )
                
                try realm.write {
                    realm.add(puppy)
                }
                return true
            }
            return false
        } catch {
            print(error)
            return false
        }
    }
    
    func updatePuppy(
        with prev: Puppy?,
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String? = nil
    ) -> Bool {
        let realm = self.getRealm()
        
        do {
            if var puppy = prev {
                puppy = Puppy(
                    id: puppy.id,
                    name: name,
                    age: age,
                    gender: gender,
                    weight: weight,
                    species: species,
                    imageURL: imageURL
                )
                
                try realm.write {
                    realm.add(puppy, update: .modified)
                }
                return true
            }
            return false
        } catch {
            print(error)
            return false
        }
    }
    
    func deletePuppy(with puppy: Puppy) -> Bool {
        let realm = self.getRealm()
        do {
            try realm.write {
                realm.delete(puppy)
            }
            
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func incrementID() -> Int? {
        let realm = self.getRealm()
        return (realm.objects(Puppy.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
