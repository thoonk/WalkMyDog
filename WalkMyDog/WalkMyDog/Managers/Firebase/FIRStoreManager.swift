//
//  FIRStoreManager.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/17.
//

import Foundation
import FirebaseFirestore
import RxSwift

/// FireStore 관리 클래스
final class FIRStoreManager {
    // MARK: - Properties
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
    /// 반려견 정보 등록하는 함수
    func createPuppyInfo(
        for puppy: Puppy,
        with ref: FIRStoreRef,
        completion: @escaping (Bool, String?, Error?) -> Void) {
        createDocument(for: puppy, with: ref, completion: completion)
    }
    
    /// 모든 반려견의 정보 읽는 함수
    func fetchAllPuppyInfo() -> Observable<[Puppy]> {
        return Observable.create() { emitter in
            self.readAllDocByAge(returning: Puppy.self, with: .puppies) { result in
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
    
    /// 반려견의 정보 수정하는 함수
    func updatePuppyInfo(for puppy: Puppy, completion: @escaping (Bool, Error?) -> Void) {
        updateDocument(for: puppy, with: .puppies, completion: completion)
    }
    
    /// 반려견의 정보 삭제하는 함수
    func deletePuppyInfo(for object: Puppy, completion: @escaping (Bool, Error?) -> Void) {
        deleteDocument(with: .puppies, deleteObject: object, completion: completion)
    }
    
    // MARK: - About RecordInfo
    /// 반려견의 산책 기록을 생성하는 함수
    func createRecordInfo(
        for record: Record,
        with ref: FIRStoreRef,
        completion: @escaping (Bool, String?, Error?) -> Void) {
        createDocument(for: record, with: ref, completion: completion)
    }
    /// 모든 반려견의 산책 기록을 읽는 함수
    func fetchAllRecordInfo(from ref: FIRStoreRef) -> Observable<[Record]> {
        return Observable.create() { emitter in
            self.readAllDocByTime(returning: Record.self, from: ref) { (result) in
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
    /// 모든 반려견의 산책 기록 삭제하는 함수
    func deleteRcordInfo(
        for object: Record,
        with ref: FIRStoreRef,
        completion: @escaping (Bool, Error?) -> Void) {
       deleteDocument(with: ref, deleteObject: object, completion: completion)
    }
    
    // MARK: - CRUD Template
    /// 문서를 생성하는 함수
    private func createDocument<T: Encodable>(
        for newObject: T,
        with ref: FIRStoreRef,
        completion: @escaping (Bool, String?, Error?) -> Void) {
        collection = db.collection(ref.path)
        do {
            let json = try newObject.toJson(excluding: ["id"])
            if collection != nil {
                document = collection!.addDocument(data: json) { error in
                    if error != nil {
                        print("Error writing docs: \(error!)")
                        completion(false, nil, error)
                    } else {
                        print("Writing doc Succeded")
                        completion(true, self.document!.documentID, nil)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 반려견의 정보를 나이 오름차순으로 읽는 함수
    private func readAllDocByAge<T: Decodable>(
        returning type: T.Type,
        with ref: FIRStoreRef,
        completion: @escaping (Result<[T], Error>) -> Void) {
        collection = db.collection(ref.path)
        let query = collection?.order(by: "age", descending: false)
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
    /// 반려견의 산책 기록을 최근순으로 읽는 함수
    private func readAllDocByTime<T: Decodable>(
        returning encodableObject: T.Type,
        from ref: FIRStoreRef,
        completion: @escaping  (Result<[T], Error>) -> Void) {
        collection = db.collection(ref.path)
        let query = collection?.order(by: "timeStamp", descending: true)
        query?.getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Record Docs does not exist: \(error!.localizedDescription)")
            } else {
                do {
                    var objects = [T]()
                    for doc in querySnapshot!.documents {
                        let object: T = try doc.decode(as: encodableObject.self)
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
    
    /// 문서를 업데이트하는 함수
    private func updateDocument<T: Encodable & Identifiable>(
        for newObject: T,
        with ref: FIRStoreRef,
        completion: @escaping (Bool, Error?) -> Void) {
        collection = db.collection(ref.path)
        
        do {
            let json = try newObject.toJson(excluding: ["id"])
            guard let id = newObject.id else { throw FIRError.encodingError }
            
            collection?.document(id)
                .setData(json) { err in
                    if err != nil {
                        print("Error updating doc: \(err!.localizedDescription)")
                        completion(false, err!)
                    } else {
                        print("Updating doc Succeded")
                        completion(true, nil)
                    }
                }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 문서를 삭제하는 함수
    private func deleteDocument<T: Identifiable>(
        with ref: FIRStoreRef,
        deleteObject: T,
        completion: @escaping (Bool, Error?) -> Void) {
        collection = db.collection(ref.path)
        do {
        guard let id = deleteObject.id else { throw FIRError.encodingError }
        
        collection?.document(id)
            .delete() { err in
                if err != nil {
                    print("Error deleting doc: \(err!.localizedDescription)")
                    completion(false, err!)
                } else {
                    print("Deleting doc Succeded")
                    completion(true, nil)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
