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
    
    /// 강쥐 정보 등록
    func registerPuppyInfo<T: Encodable>(for encodableObject: T, with ref: FIRStoreRef) {
        collection = db.collection(ref.path)
        do {
            let json = try encodableObject.toJson()
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
    
    /// 뷰모델로 넘기는 메서드
    func fetchAllPuppyInfo() -> Observable<[Puppy]> {
        return Observable.create() { emitter in
            self.fetchAllPuppyInfo(from: .puppies, returning: Puppy.self) { result in
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
    
    /// 모든 강쥐 정보 읽기
    private func fetchAllPuppyInfo<T: Decodable>(from ref: FIRStoreRef, returning encodableObject: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        collection = db.collection(ref.path)
        collection?.getDocuments(completion: { (querySnapshot, error) in

            if error != nil {
                print("Puppy Docs does not exist: \(error!.localizedDescription)")
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
        })
    }
        
    /// 강쥐 정보 수정
    func updatePuppyInfo<T: Encodable>(for newObject: T, with ref: FIRStoreRef, docId: Int, completion: @escaping (Bool, Error?) -> Void) {
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
    
    /// 강쥐 정보 삭제
    func deletePuppyInfo(with ref: FIRStoreRef, docId: Int, completion: @escaping (Bool, Error?) -> Void) {
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
    
    /// 산책 기록 등록
    func addRecordInfo(data: [String: Any], with ref: FIRStoreRef) {
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
    // FIRTimestamp -> Date 변환 방법 찾아야 함
    /// 산책 기록 읽기
    func fetchRecordInfo<T: Decodable>(from ref: FIRStoreRef, returning encodableObject: T.Type, completion: @escaping ([T]) -> Void) {
        collection = db.collection(ref.path)
        collection?.getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Rcord Docs does not exist: \(error!.localizedDescription)")
            } else {
                do {
                    var objects = [T]()
                    for doc in querySnapshot!.documents {
                        let object: T = try doc.decode(as: encodableObject.self)
                        objects.append(object)
                    }
                    completion(objects)
                } catch {
                    print(error.localizedDescription)
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
        
    /// documentID 부여 메서드
    func incrementID(with ref: FIRStoreRef) -> Observable<Int> {
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
    
    /// 컬렉션에서 제일 큰 id 가져오는 메서드
    private func getMaxId<T: Decodable>(with ref: FIRStoreRef, returning newObject: T.Type, completion: @escaping (Result<T?, Error>) -> Void) {
        
        collection = db.collection(ref.path)
        let query = collection?.order(by: "id", descending: true).limit(to: 1)
        
        query?.getDocuments { querySnapshot, err in
            if err != nil {
                print("Error fetch docs: \(err!.localizedDescription)")
            } else {
                do {
                    for doc in querySnapshot!.documents {
                        let object = try doc.decode(as: newObject.self)
                        print(object)
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
