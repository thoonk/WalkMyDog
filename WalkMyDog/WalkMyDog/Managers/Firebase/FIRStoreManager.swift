//
//  FIRStoreManager.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/17.
//

import Foundation
import FirebaseFirestore
import RxSwift

final class FIRStoreManager {
    
    static let shared = FIRStoreManager()
    
    private var db = Firestore.firestore()
    private var collection: CollectionReference?
    private var document: DocumentReference?
    
    private init() { }
    
    /// 사용자 등록 메서드
    func registerUserInfo(data: [String:Any], with ref: FIRStoreRef) {
        
        document = db.document(ref.path)
        if document != nil {
            document!.setData(data) { error in
                if let error = error {
                    print("Error writing docs: \(error)")
                } else {
                    print("Writing Succeded")
                }
            }
        }
    }
    
    /// 사용자 탈퇴시 정보 삭제 메서드
    func deleteUserInfo(with ref: FIRStoreRef) {
        document = db.document(ref.path)
        document?.delete() { error in
            if let error = error {
                print("Error writing docs: \(error)")
            } else {
                print("Deleting Succeded")
            }
        }
    }
    // MARK: - About PuppyInfo
    /// 강쥐 정보 등록
    func registerPuppyInfo(for puppy: Puppy, with ref: FIRStoreRef) {
        createDocument(for: puppy, with: ref)
    }
    
    /// 모든 강아지 정보 읽기
    func fetchAllPuppyInfo() -> Observable<[Puppy]> {
        return Observable.create() { emitter in
            self.readAllDocument(returning: Puppy.self, with: .puppies) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
        
    /// 강쥐 정보 수정
    func updatePuppyInfo(for puppy: Puppy, with ref: FIRStoreRef, docId: Int, completion: @escaping (Bool, Error?) -> Void) {
        updateDocument(for: puppy, with: ref, docId: docId, completion: completion)
    }
    
    /// 강쥐 정보 삭제
    func deletePuppyInfo(with ref: FIRStoreRef, docId: Int, completion: @escaping (Bool, Error?) -> Void) {
        deleteDocument(with: ref, docId: docId, completion: completion)
    }
    
    /// Puppy documentID 부여 메서드
    func incrementPuppyId(with ref: FIRStoreRef) -> Observable<Int> {
        return Observable.create() { emitter in
            self.getMaxId(with: ref, returning: Puppy.self) { (result) in
                switch result {
                case .success(let data):
                    if data != nil {
                        emitter.onNext(data!.id+1)
                    } else {
                        emitter.onNext(1)
                    }
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: - About RecordInfo
    /// 산책 기록 등록
    func createRecordInfo(for record: Record, with ref: FIRStoreRef, puppyId: Int) {
        collection = db.collection(ref.path)
        let query = collection?.whereField("id", isEqualTo: puppyId)
        query?.getDocuments(completion: { (querySnapshot, error) in
            if error != nil {
                print("Puppy Docs does not exist: \(error!.localizedDescription)")
            } else {
                for doc in querySnapshot!.documents {
                    do {
                        let json = try record.toJson()
                        self.collection?.document(doc.documentID).collection("record").addDocument(data: json) { error in
                            if let error = error {
                                print("Error writing docs: \(error)")
                            } else {
                                print("Writing Succeded")
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
        
    func fetchAllRecordInfo(from ref: FIRStoreRef) -> Observable<[Record]> {
        return Observable.create() { emitter in
            self.fetchRecordInfo(returning: Record.self, from: ref) { (result) in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    /// 산책 기록 읽기
    private func fetchRecordInfo<T: Decodable>(returning encodableObject: T.Type, from ref: FIRStoreRef, completion: @escaping  (Result<[T], Error>) -> Void) {
        collection = db.collection(ref.path)
        collection!.getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Rcord Docs does not exist: \(error!.localizedDescription)")
            } else {
                do {
                    var objects = [T]()
                    for doc in querySnapshot!.documents {
                        let object: T = try doc.decode(as: encodableObject.self)
                        print(object)
                        objects.append(object)
                    }
                    completion(.success(objects))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
    }

    /// 산책 기록 삭제
    func deleteRcordInfo(with ref: FIRStoreRef) {
        document = db.document(ref.path)
        if document != nil {
            document!.delete() { error in
                if let error = error {
                    print("Error writing docs: \(error)")
                } else {
                    print("Deleting Succeded")
                }
            }
        }
    }
    
    /// Record documentID 부여 메서드
    func incrementRecordId(with ref: FIRStoreRef) -> Observable<Int> {
        return Observable.create() { emitter in
            self.getMaxId(with: ref, returning: Record.self) { (result) in
                switch result {
                case .success(let data):
                    if data != nil {
                        emitter.onNext(data!.id+1)
                    } else {
                        emitter.onNext(1)
                    }
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: - CRUD
    private func createDocument<T: Encodable>(for newObject: T, with ref: FIRStoreRef) {
        collection = db.collection(ref.path)
        do {
            let json = try newObject.toJson()
            if collection != nil {
                collection!.addDocument(data: json) { error in
                    if let error = error {
                        print("Error writing docs: \(error)")
                    } else {
                        print("Writing Succeded")
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func readAllDocument<T: Decodable>(returning type: T.Type, with ref: FIRStoreRef, completion: @escaping (Result<[T], Error>) -> Void) {
        collection = db.collection(ref.path)
        let query = collection?.order(by: "id", descending: false)
        query?.getDocuments(completion: { (querySnapshot, error) in

            if error != nil {
                print("Puppy Docs does not exist: \(error!.localizedDescription)")
            } else {
                do {
                    var objects = [T]()
                    for doc in querySnapshot!.documents {
                        let object: T = try doc.decode(as: type.self)
                        objects.append(object)
                    }
                    completion(.success(objects))
                } catch {
                    print("Read Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        })
    }
    
    private func updateDocument<T: Encodable>(for newObject: T, with ref: FIRStoreRef, docId: Int, completion: @escaping (Bool, Error?) -> Void) {
        collection = db.collection(ref.path)
        let query = collection?.whereField("id", isEqualTo: docId)
        
        do {
            let json = try newObject.toJson()
            query?.getDocuments { (querySnapshot, err) in
                for doc in querySnapshot!.documents {
                    self.collection?.document(doc.documentID)
                        .setData(json) { err in
                            if err != nil {
                                print("Error updating docs: \(err!.localizedDescription)")
                                completion(false, err!)
                            } else {
                                print("Updating Succeded")
                                completion(true, nil)
                            }
                        }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteDocument(with ref: FIRStoreRef, docId: Int, completion: @escaping (Bool, Error?) -> Void) {
        collection = db.collection(ref.path)
        let query = collection?.whereField("id", isEqualTo: docId)
        
        query?.getDocuments { (querySnapshot, err) in
            for doc in querySnapshot!.documents {
                self.collection?.document(doc.documentID)
                    .delete() { err in
                        if err != nil {
                            print("Error writing docs: \(err!.localizedDescription)")
                            completion(false, err!)
                        } else {
                            print("Deleting Succeded")
                            completion(true, nil)
                        }
                    }
            }
        }
    }
        
    /// 컬렉션에서 제일 큰 id 가져오는 메서드
    func getMaxId<T: Decodable>(with ref: FIRStoreRef, returning type: T.Type, completion: @escaping (Result<T?, Error>) -> Void) {
        
        collection = db.collection(ref.path)
        let query = collection?.order(by: "id", descending: true).limit(to: 1)
        
        query?.getDocuments { querySnapshot, err in
            if err != nil {
                print("Error fetch docs: \(err!.localizedDescription)")
            } else {
                do {
                    for doc in querySnapshot!.documents {
                        let object = try doc.decode(as: type.self)
                        completion(.success(object))
                    }
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
    }
}
