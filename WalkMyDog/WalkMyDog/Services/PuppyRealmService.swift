//
//  PuppyRealmService.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/14.
//

protocol PuppyRealmServiceProtocol {
    func insert(
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String?
    ) -> Bool
    func fetchPuppies() -> [Puppy]?
    func update(
        with prev: Puppy?,
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String?
    ) -> Bool
    func remove(with puppy: Puppy) -> Bool
}

final class PuppyRealmService: RealmService<Puppy>, PuppyRealmServiceProtocol {
    func insert(
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String? = nil
    ) -> Bool {
        do {
            if let id = try increamentID(Puppy.self) {
                let puppy = Puppy(
                    id: id,
                    name: name,
                    age: age,
                    gender: gender,
                    weight: weight,
                    species: species,
                    imageURL: imageURL
                )
                try saveObject(puppy)
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    func fetchPuppies() -> [Puppy]? {
        guard let puppies = fetchObjects(Puppy.self) as? [Puppy] else {
            return nil
        }
        return puppies
    }
    
    func update(
        with prev: Puppy?,
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String? = nil
    ) -> Bool {
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
                
                try updateObject(puppy)
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    func remove(with puppy: Puppy) -> Bool {
        do {
            try removeObject(puppy)
            return true
        } catch {
            return false
        }
    }
}
