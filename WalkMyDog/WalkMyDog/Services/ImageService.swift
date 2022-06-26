//
//  ImageService.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/06/26.
//

import Foundation
import UIKit

protocol ImageServiceProtocol {
    func save(image: UIImage, name: String) -> Bool
    func loadImage(with name: String) -> UIImage?
    @discardableResult func removeImage(with name: String) -> Bool
}

final class ImageService: ImageServiceProtocol {
    func save(image: UIImage, name: String) -> Bool {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        
        let fileURL = documentDirectory.appendingPathComponent(name)
        
        guard self.removeImageFromDocumentDirectory(with: fileURL) else { return false }
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return false }
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            debugPrint("Save file Failed: \(error.localizedDescription)")
            return false
        }
    }
    
    func loadImage(with name: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = paths.first {
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(name)
            let image = UIImage(contentsOfFile: imageURL.path)
            
            return image
        }
        
        return nil
    }
    
    func removeImage(with name: String) -> Bool {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        
        let fileURL = documentDirectory.appendingPathComponent(name)
        
        return removeImageFromDocumentDirectory(with: fileURL)
    }
    
    private func removeImageFromDocumentDirectory(with fileURL: URL) -> Bool {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                debugPrint("Remove file Failed: \(error.localizedDescription)")
                return false
            }
        }
        
        return true
    }
}
