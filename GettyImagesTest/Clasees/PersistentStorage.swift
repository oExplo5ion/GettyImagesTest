//
//  PersistentStorage.swift
//  GettyImagesTest
//
//  Created by Mac on 3/21/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public class GettyData:Object{
    @objc dynamic var collectionID:String = ""
    @objc dynamic var imageUri:String = ""
    @objc dynamic var phrase:String = ""
}

public final class PersistentStorage{
    
    enum PersistentStorageKeys:String {
        case token              = "token"
        case tokenExpires       = "tokenExpires"
    }
    
    static let sharedStorage = PersistentStorage()
    
    public var token:String?{
        set{ setValueForKey(key: PersistentStorageKeys.token.rawValue, value: newValue) }
        get{ return getStringForKey(key: PersistentStorageKeys.token.rawValue) }
    }
    
    public var tokenExpires:Date?{
        set{ setValueForKey(key: PersistentStorageKeys.tokenExpires.rawValue, value: newValue) }
        get{ return getValueFor(key: PersistentStorageKeys.tokenExpires.rawValue) as? Date }
    }
    
    
    public func saveGettyData(data:GettyData, image:UIImage, complition:(_:Bool)->Void){
            if let realm = try? Realm(){
                do{
                    try realm.write {
                        realm.add(data)
                    }
                    self.saveImageToDisk(image: image, imageName: data.collectionID, complition: {
                        complition(true)
                    })
                }catch{
                    complition(false)
                }
            }
    }
    
    public func getSearchHistory()->Results<GettyData>?{
        if let realm = try? Realm(){
            return realm.objects(GettyData.self)
        }else{
            return nil
        }
    }
    
    private func saveImageToDisk(image:UIImage, imageName:String, complition:()->Void){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = documentsDirectory.appendingPathComponent(imageName + ".jpg")
        if let imgData = UIImageJPEGRepresentation(image, 1.0){
            if !FileManager.default.fileExists(atPath: imageUrl.path){
                do{
                    try imgData.write(to: imageUrl)
                    complition()
                }catch{
                    complition()
                }
            }else{
                complition()
            }
        }
    }
    
    private func getIMagesFromDisk() -> [UIImage]?{
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do{
            let files = try FileManager.default.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)
            let filteredFiles = files.filter({ $0.pathExtension == ".jpg" || $0.pathExtension == ".png" })
            var imgFiles = [UIImage]()
            for file in filteredFiles{
                let img = try? UIImage(data: Data.init(contentsOf: file))
                guard img != nil else { return nil }
                imgFiles.append(img!!)
            }
            return imgFiles
        }catch{ return nil }
    }
    
    private func setValueForKey(key: String, value: Any?) {
        if (value != nil){
            let defaults = UserDefaults.standard
            defaults.set(value!, forKey: key)
            defaults.synchronize()
        }
    }
    
    private func getStringForKey(key: String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: key)
    }
    
    private func getIntForKey(key: String) -> Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: key)
    }
    
    private func getValueFor(key:String)->Any?{
        return UserDefaults.standard.value(forKey: key) ?? nil
    }
    
}






















