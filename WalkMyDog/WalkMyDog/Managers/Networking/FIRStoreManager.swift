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
        document = db.document(ref.path)
        do {
            let json = try encodableObject.toJson()
            document = db.document(ref.path)
            if document != nil {
                document!.setData(json) { error in
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
    func fetchAllPuppyInfo<T: Decodable>(from ref: FIRStoreRef, returning encodableObject: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
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
    
    /// 하나의 강쥐 정보 읽기
    func fetchOnePuppyInfo<T: Decodable>(id: String, from ref: FIRStoreRef, returning encodableObject: T.Type, completion: @escaping (T) -> Void) {
        
        document = db.document(ref.path)
        document?.getDocument { (snapshot, error) in
            
            if error != nil {
                print("Puppy Docs does not exist: \(error!.localizedDescription)")
            } else {
                do {
                    let object: T = try snapshot!.decode(as: encodableObject.self)
                    completion(object)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    /// 강쥐 정보 수정
    func updatePuppyInfo(for data: [String: Any], with ref: FIRStoreRef) {
        document = db.document(ref.path)
        document?.updateData(data) { error in
            if let error = error {
                print("Error writing docs: \(error)")
            } else {
                print("Updating Succeded")
            }
        }
    }
    /// 강쥐 정보 삭제
    func deletePuppyInfo(with ref: FIRStoreRef) {
        document = db.document(ref.path)
        document?.delete() { error in
            if let error = error {
                print("Error writing docs: \(error)")
            } else {
                print("Deleting Succeded")
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
}
