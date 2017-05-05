//
//  NSObject+YFKVOManager.swift
//  YFKVOManager
//
//  Created by yaonphy on 17/4/10.
//  Copyright © 2017  YF. All rights reserved.
//

import Foundation

public typealias YFKVOCallBackClosure = (_ observedObject: Any?, _ change: Dictionary<NSKeyValueChangeKey,Any>?) -> Void

enum YFKVOInfoState: Int {
    case YFKVOInfoStateInitial = 0,YFKVOInfoStateObserving,YFKVOInfoStateUnObserving
    
}



//
//class YFKVOManager {
//    
//    var own: Bool?
//    weak var kvoObserver: NSObject?
//    var observedObjects: NSMapTable<AnyObject,NSMutableSet>?
//    var lock: pthread_mutex_t?
//    convenience init(obsever: NSObject,isOwn: Bool) {
//        self.init()
//        self.own = isOwn
//        self.kvoObserver = obsever
//        
//        let keyOptions = isOwn ? (NSPointerFunctions.Options.strongMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue) : (NSPointerFunctions.Options.weakMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue)
//        self.observedObjects = NSMapTable.init(keyOptions: NSPointerFunctions.Options.init(rawValue: keyOptions), valueOptions:NSPointerFunctions.Options.init(rawValue: ((NSPointerFunctions.Options.strongMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue))), capacity: 0)
//        pthread_mutex_init(&lock!, nil)
//
//    }
//
//    deinit {
//        pthread_mutex_destroy(&lock!)
//    }
//    
//    func observe(object: NSObject, infoObject: NSObject) -> Void {
//        
//        pthread_mutex_lock(&lock!)
//        if let theInfos = self.observedObjects?.object(forKey: object) {
//            if theInfos.member(infoObject) != nil {
//                pthread_mutex_unlock(&lock!)
//                return
//            }else{
//                let addedSet = NSMutableSet()
//                addedSet .add(infoObject)
//                self.observedObjects?.setObject(addedSet, forKey: object)
//                pthread_mutex_unlock(&lock!)
//                YFKVORouter.sharedInstance.observe(object: object, infoObject: infoObject)
//            }
//        }
//    }
//    func unObserve(object: NSObject, infoObject: NSObject) -> Void {
//        
//        pthread_mutex_lock(&lock!)
//        if let theInfos = self.observedObjects?.object(forKey: object) {
//            if let curInfo = theInfos.member(infoObject) {
//                theInfos.remove(curInfo)
//            }
//            if theInfos.count == 0{
//                self.observedObjects?.removeObject(forKey: object)
//            }
//        }
//        pthread_mutex_unlock(&lock!)
//        YFKVORouter.sharedInstance.unObserve(object: object, infoObject: infoObject)
//    }
//    
//    func unObserve(object: NSObject) -> Void {
//        
//        pthread_mutex_lock(&lock!)
//        if let theInfos = self.observedObjects?.object(forKey: object) {
// 
//            self.observedObjects?.removeObject(forKey: object)
//            YFKVORouter.sharedInstance.unObserve(object: object, infoObject: theInfos)
//        }
//        pthread_mutex_unlock(&lock!)
//
//    }
//    
//    func observe(object: Any, keyPath:String, options: NSKeyValueObservingOptions, block: @escaping YFKVOCallBackClosure ,context: UnsafeMutableRawPointer) -> Void {
//        let newInfo = YFKVOInfo.init(manager: self, keyPath: keyPath, options: options, action: nil, callBack: block, context: context)
//        observe(object: object as! NSObject , infoObject: newInfo)
//        
//    }
//    
//    
//}


class YFKVOItem: NSObject{
    
    var keyPath: String!
    var options: NSKeyValueObservingOptions!
    var state: YFKVOInfoState!
    var callBack: YFKVOCallBackClosure!
    
    convenience init(with keyPath: String!, and options: NSKeyValueObservingOptions!, and callBack: YFKVOCallBackClosure!) {
        self.init()
        
        self.keyPath = keyPath;
        self.callBack = callBack;
        self.options = options;
        
    }
    

}

class YFSharedObserver: NSObject{
    
    var observedObjects: NSMapTable<NSObject,NSMutableSet>?
//    var rMutex: pthread_mutex_t?
    
    class var sharedInstance: YFSharedObserver{
        struct Singleton{
            static let instance = YFSharedObserver()
        }
        return Singleton.instance
    }
    
    override init() {
        
        self.observedObjects = NSMapTable.init(keyOptions:[.strongMemory], valueOptions: [.strongMemory])
//        pthread_mutex_init(&rMutex!,nil)
    }
    
    func observe(observedObj: NSObject!, for keyPath:String!, with options:NSKeyValueObservingOptions!, and callBack:YFKVOCallBackClosure!) -> Bool {
        
        let curKVOItem = YFKVOItem.init(with: keyPath, and: options, and: callBack)
        
        if let existedSet = self.observedObjects?.object(forKey: observedObj){
            
            for existedKVOItem in existedSet {
                
                if let itrItem = existedKVOItem as? YFKVOItem {
                    
                    if itrItem.keyPath == keyPath {
                        return false
                    }
                    
                }
            }
            existedSet.add(curKVOItem)
            
        }else{
            
            let newSet = NSMutableSet.init()
            newSet.add(curKVOItem)
            self.observedObjects?.setObject(newSet, forKey: observedObj)
        }
        
        observedObj.addObserver(self, forKeyPath: keyPath, options: options, context: nil)
        return true
    }
    
    func unObserve(observedObj: NSObject!, for keyPath:String!) -> Bool {
        
        if let existedSet = self.observedObjects?.object(forKey: observedObj){
            
            for existedKVOItem in existedSet {
                
                if let itrItem = existedKVOItem as? YFKVOItem {
                    
                    if itrItem.keyPath == keyPath {
                        existedSet.remove(itrItem)
                        observedObj.removeObserver(self, forKeyPath: keyPath)
                        if existedSet.count == 0{
                            self.observedObjects?.removeObject(forKey: observedObj)
                        }
                        
                        return true
                    }
                    
                }
            }
            
        }
        return false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let existedSet = self.observedObjects?.object(forKey: object as! NSObject?){
            
            for existedKVOItem in existedSet {
                
                if let itrItem = existedKVOItem as? YFKVOItem {
                    
                    if itrItem.keyPath == keyPath {
                        
                        itrItem.callBack(object,change)
                    }
                    
                }
            }
            
        }
    }
    
    
    deinit {
//        pthread_mutex_destroy(&rMutex!)
    }
    
    
}






//extension NSObject{
//    
//    private struct NSObjectYFKVOManagerAssociatedKeys{
//        static var KVOManagerKey = "NSObjectYFKVOManagerKey"
//        static var unOwnKVOManagerKey = "NSObjectYFUnOwnKVOManagerKey"
//
//    }
//    
//    
//    var KVOManager: YFKVOManager? {
//        get {
//            
//            if let managager = objc_getAssociatedObject(self, &NSObjectYFKVOManagerAssociatedKeys.KVOManagerKey) {
//                return managager as? YFKVOManager
//            }else{
//                let curManager = YFKVOManager.init(obsever: self, isOwn: false)
//                self.KVOManager = curManager
//                return curManager
//            }
//            
//        }
//        set {
//            if (newValue != nil) {
//                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.KVOManagerKey,newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//    
//    var UnOwnKVOManager: YFKVOManager? {
//        get {
//            if let managager = objc_getAssociatedObject(self, &NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey) {
//                return managager as? YFKVOManager
//            }else{
//                let curManager = YFKVOManager.init(obsever: self, isOwn: true)
//                self.UnOwnKVOManager = curManager
//                return curManager
//            }
//        }
//        set {
//            if (newValue != nil) {
//                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey,newValue,
//                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//    

    
//}

