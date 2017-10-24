//
//  DataManager.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import RealmSwift

class DataManager {
    fileprivate static var realm: Realm?
    
    fileprivate static var dataModel: DataModel? {
        didSet {
//            magic("Created dataModel: \(self.dataModel))")
        }
    }
    
    static var model: DataModel {
        return self.dataModel ?? DataModel()
    }
    
    static var needLoginTransition = true
    static var imageCache = NSCache<NSString, UIImage>()
    
    static func startupInit(_ completion: () -> Void) {
        if let model = self.getRealm().objects(DataModel.self).first {
            self.dataModel = model
        } else {
            let model = DataModel()
            try! self.getRealm().write {
                self.getRealm().add(model)
            }
            self.dataModel = model
        }
        completion()
    }
    
    
    
    static func write(_ block: () -> ()) {
        do {
            try DataManager.getRealm().write {
                block()
            }
        } catch {
            magic("Error saving data: \(error)")
        }
    }
    
    static func clearAll() {
        self.write {
            self.getRealm().deleteAll()
        }
    }
    
    static func getRealm() -> Realm {
        if let r = self.realm {
            return r
        } else {
            func getDocsDir() -> NSURL {
                let fm = FileManager.default
                return fm.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            }
            
            let encryptionKey = "yourEncryptionKey".data(using: String.Encoding.ascii)
            
            let dbPath = getDocsDir().appendingPathComponent("model.realm")
            var schemaVersion: UInt64 = 1
            do {
                schemaVersion = try schemaVersionAtURL(dbPath!, encryptionKey: encryptionKey)
            } catch {
                
            }
            
            var config = Realm.Configuration()

            
            do {
                let r = try Realm(configuration: config)
                self.realm = r
                return r
            } catch {
                do {
                    config.schemaVersion += 1
                    let r = try Realm(configuration: config)
                    self.realm = r
                    return r
                } catch {
                    return try! Realm()
                }
            }
        }
    }
}

extension Object {
    func getRealm() -> Realm {
        return DataManager.getRealm()
    }
    
    class func getRealm() -> Realm {
        return DataManager.getRealm()
    }
    
    func write(_ block: () -> ()) {
        DataManager.write(block)
    }
    
    class func write(_ block: () -> ()) {
        DataManager.write(block)
    }
}

extension Object {
    class func getObject(_ id: String) -> Self? {
        let a = self.getRealm().object(ofType: self, forPrimaryKey: id as AnyObject)
        return a
    }
    
}

