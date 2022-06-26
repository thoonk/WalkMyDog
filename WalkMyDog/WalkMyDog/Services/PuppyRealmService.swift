//
//  PuppyRealmService.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/14.
//

import RxSwift

protocol PuppyRealmServiceProtocol {
    @discardableResult
    func insert(
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String?
    ) -> Puppy?
    func fetchAllPuppies() -> Observable<[Puppy]>
    @discardableResult
    func update(
        with prev: Puppy?,
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String?
    ) -> Bool
    @discardableResult
    func remove(with puppy: Puppy) -> Bool
}

final class PuppyRealmService: RealmService<Puppy>, PuppyRealmServiceProtocol {
    
    @discardableResult
    func insert(
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String? = nil
    ) -> Puppy? {
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
                return puppy
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func fetchAllPuppies() -> Observable<[Puppy]> {
        return Observable.create() { [weak self] emitter in
            if let puppies = self?.fetchObjects(Puppy.self) as? [Puppy] {
                emitter.onNext(puppies)
            } else {
                emitter.onNext([])
            }
            return Disposables.create()
        }
//        guard let puppies = fetchObjects(Puppy.self) as? [Puppy] else {
//            return nil
//        }
//        return puppies
    }
    
    @discardableResult
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
                var newImageURL = imageURL
                if imageURL == nil {
                    newImageURL = prev?.imageURL
                }
                puppy = Puppy(
                    id: puppy.id,
                    name: name,
                    age: age,
                    gender: gender,
                    weight: weight,
                    species: species,
                    imageURL: newImageURL
                )
                
                try updateObject(puppy)
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    @discardableResult
    func remove(with puppy: Puppy) -> Bool {
        do {
            try removeObject(puppy)
            return true
        } catch {
            return false
        }
    }
}
