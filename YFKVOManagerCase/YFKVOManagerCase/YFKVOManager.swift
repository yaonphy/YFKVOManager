//
//  NSObject+YFKVOManager.swift
//  YFKVOManager
//
//  Created by yaonphy on 17/4/10.
//  Copyright © 2017  YF. All rights reserved.
//

import Foundation





class YFKVOManager: NSObject {
    
    var own: Bool?
    weak var kvoObserver: NSObject?
    var observedObjects: NSMapTable<AnyObject, AnyObject>?
    var lock: pthread_mutex_t?
    
    convenience init(obsever: NSObject,isOwn: Bool) {
        self.init()
        self.own = isOwn
        self.kvoObserver = obsever
        
        let keyOptions = isOwn ? (NSPointerFunctions.Options.strongMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue) : (NSPointerFunctions.Options.weakMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue)
        self.observedObjects = NSMapTable.init(keyOptions: NSPointerFunctions.Options.init(rawValue: keyOptions), valueOptions:NSPointerFunctions.Options.init(rawValue: ((NSPointerFunctions.Options.strongMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue))), capacity: 0)
        pthread_mutex_init(&lock!, nil)

        
    }
    

    deinit {
        pthread_mutex_destroy(&lock!)
    }
    
    func observe(object: NSObject, infoObject: NSObject) -> Void {
        
        pthread_mutex_lock(&lock!)
        
        
        
        
        
    }
    
    
    
}


class YFKVOInfo: NSObject{

    weak var manager: YFKVOManager?
    var keyPath: String?
    var options: NSKeyValueObservingOptions?
    var action: Selector?
    var context: UnsafeMutableRawPointer?
    
    convenience init(manager: YFKVOManager?, keyPath: String?, options: NSKeyValueObservingOptions?, action: Selector!, context: UnsafeMutableRawPointer?) {
        self.init()
        
        self.manager = manager;
        self.keyPath = keyPath;
        self.action = action;
        self.options = options;
        self.context = context;
        
    }
    
    func keyPathHash() -> Int? {
        return self.keyPath?.hash
    }
    
    
    
}

class YFKVORouter: NSObject {
    
    var kvoInfos: NSHashTable<YFKVOInfo>?
    var rMutex: pthread_mutex_t?

    class var sharedInstance: YFKVOManager{
        struct Singleton{
            static let instance = YFKVOManager()
        }
        return Singleton.instance
    }
    
    override init() {
        self.kvoInfos = NSHashTable.init(options: NSPointerFunctions.Options.init(rawValue: (NSPointerFunctions.Options.weakMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue)), capacity: 0)
        pthread_mutex_init(&rMutex!,nil)
        super.init()
    }
    
    func observe(object: NSObject?, kvoInfo: YFKVOInfo!) -> Void {
        
        pthread_mutex_lock(&rMutex!)
        self.kvoInfos?.add(kvoInfo)
        pthread_mutex_unlock(&rMutex!)
        
        object?.addObserver(self, forKeyPath: kvoInfo.keyPath!, options: kvoInfo.options!, context: kvoInfo.context)
        
        
    }
    
    deinit {
        pthread_mutex_destroy(&rMutex!)
    }
    
    
}










extension NSObject{
    
    private struct NSObjectYFKVOManagerAssociatedKeys{
        static var KVOManagerKey = "NSObjectYFKVOManagerKey"
        static var unOwnKVOManagerKey = "NSObjectYFUnOwnKVOManagerKey"

    }
    
    
    var KVOManager: YFKVOManager? {
        get {
            
            if let managager = objc_getAssociatedObject(self, &NSObjectYFKVOManagerAssociatedKeys.KVOManagerKey) {
                return managager as? YFKVOManager
            }else{
                let curManager = YFKVOManager.init(obsever: self, isOwn: false)
                self.KVOManager = curManager
                return curManager
            }
            
        }
        set {
            if (newValue != nil) {
                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.KVOManagerKey,newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var UnOwnKVOManager: YFKVOManager? {
        get {
            if let managager = objc_getAssociatedObject(self, &NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey) {
                return managager as? YFKVOManager
            }else{
                let curManager = YFKVOManager.init(obsever: self, isOwn: true)
                self.UnOwnKVOManager = curManager
                return curManager
            }
        }
        set {
            if (newValue != nil) {
                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey,newValue,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    
}

