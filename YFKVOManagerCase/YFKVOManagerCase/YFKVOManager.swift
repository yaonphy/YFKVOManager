//
//  NSObject+YFKVOManager.swift
//  YFKVOManager
//
//  Created by yaonphy on 17/4/10.
//  Copyright © 2017  YF. All rights reserved.
//

import Foundation

typealias YFKVOCallBackClosure = (_ theObserver: Any?, _ theObject: Any?, _ change: Dictionary<NSKeyValueChangeKey,Any>?) -> Void

enum YFKVOInfoState: Int {
    case YFKVOInfoStateInitial = 0,YFKVOInfoStateObserving,YFKVOInfoStateUnObserving
    
}




class YFKVOManager {
    
    var own: Bool?
    weak var kvoObserver: NSObject?
    var observedObjects: NSMapTable<AnyObject,NSMutableSet>?
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
        if let theInfos = self.observedObjects?.object(forKey: object) {
            if theInfos.member(infoObject) != nil {
                pthread_mutex_unlock(&lock!)
                return
            }else{
                let addedSet = NSMutableSet()
                addedSet .add(infoObject)
                self.observedObjects?.setObject(addedSet, forKey: object)
                pthread_mutex_unlock(&lock!)
                YFKVORouter.sharedInstance.observe(object: object, infoObject: infoObject)
            }
        }
    }
    func unObserve(object: NSObject, infoObject: NSObject) -> Void {
        
        pthread_mutex_lock(&lock!)
        if let theInfos = self.observedObjects?.object(forKey: object) {
            if let curInfo = theInfos.member(infoObject) {
                theInfos.remove(curInfo)
            }
            if theInfos.count == 0{
                self.observedObjects?.removeObject(forKey: object)
            }
        }
        pthread_mutex_unlock(&lock!)
        YFKVORouter.sharedInstance.unObserve(object: object, infoObject: infoObject)
    }
    
    func unObserve(object: NSObject) -> Void {
        
        pthread_mutex_lock(&lock!)
        if let theInfos = self.observedObjects?.object(forKey: object) {
 
            self.observedObjects?.removeObject(forKey: object)
            YFKVORouter.sharedInstance.unObserve(object: object, infoObject: theInfos)
        }
        pthread_mutex_unlock(&lock!)

    }
    
    func observe(object: Any, keyPath:String, options: NSKeyValueObservingOptions, block: @escaping YFKVOCallBackClosure ,context: UnsafeMutableRawPointer) -> Void {
        let newInfo = YFKVOInfo.init(manager: self, keyPath: keyPath, options: options, action: nil, callBack: block, context: context)
        observe(object: object as! NSObject , infoObject: newInfo)
        
    }
    
    
}


class YFKVOInfo: NSObject{
    weak var manager: YFKVOManager?
    var keyPath: String?
    var options: NSKeyValueObservingOptions?
    var action: Selector?
    var context: UnsafeMutableRawPointer?
    var state: YFKVOInfoState?
    var callBack: YFKVOCallBackClosure?
    
    convenience init(manager: YFKVOManager?, keyPath: String?, options: NSKeyValueObservingOptions?, action: Selector?, callBack: YFKVOCallBackClosure? ,context: UnsafeMutableRawPointer?) {
        self.init()
        
        self.manager = manager;
        self.keyPath = keyPath;
        self.action = action;
        self.callBack = callBack;
        self.options = options;
        self.context = context;
        
    }
    
    func keyPathHash() -> Int? {
        return self.keyPath?.hash
    }
    
    
    
}

class YFKVORouter: NSObject{
    
    var kvoInfos: NSHashTable<AnyObject>?
    var rMutex: pthread_mutex_t?
    static var YFKVOKeyPahth:String = "YFKVOKeyPahth"
    
    class var sharedInstance: YFKVOManager{
        struct Singleton{
            static let instance = YFKVOManager()
        }
        return Singleton.instance
    }
    
    override init() {
        self.kvoInfos = NSHashTable.init(options: NSPointerFunctions.Options.init(rawValue: (NSPointerFunctions.Options.weakMemory.rawValue | NSPointerFunctions.Options.objectPersonality.rawValue)), capacity: 0)
        pthread_mutex_init(&rMutex!,nil)
    }
    
    func observe(object: NSObject?, kvoInfo: YFKVOInfo!) -> Void {
        
        pthread_mutex_lock(&rMutex!)
        self.kvoInfos?.add(kvoInfo)
        pthread_mutex_unlock(&rMutex!)
        if kvoInfo.state == YFKVOInfoState.YFKVOInfoStateInitial{
            var theInfo = kvoInfo
            object?.addObserver(self, forKeyPath: kvoInfo.keyPath!, options: kvoInfo.options!, context: &theInfo)

        }else if kvoInfo.state == YFKVOInfoState.YFKVOInfoStateUnObserving{
            var theInfo = kvoInfo
            object?.removeObserver(self, forKeyPath: kvoInfo.keyPath!, context: &theInfo)
        }
        
        
    }
    func unObserve(object: NSObject?, kvoInfo: YFKVOInfo!) -> Void {
        
        pthread_mutex_lock(&rMutex!)
        self.kvoInfos?.remove(kvoInfo)
        pthread_mutex_unlock(&rMutex!)
        
        if kvoInfo.state == YFKVOInfoState.YFKVOInfoStateObserving{
            var theInfo = kvoInfo
            object?.removeObserver(self, forKeyPath: kvoInfo.keyPath!, context: &theInfo)
        }
        
        kvoInfo.state = YFKVOInfoState.YFKVOInfoStateUnObserving
    }
    func unObserve(object: NSObject?, kvoInfos: Set<YFKVOInfo>) -> Void {
        
        pthread_mutex_lock(&rMutex!)
        for kvoInfo in kvoInfos {
            if kvoInfo.state == YFKVOInfoState.YFKVOInfoStateObserving {
                var theInfo = kvoInfo
                object?.removeObserver(self, forKeyPath: kvoInfo.keyPath!, context: &theInfo)
            }
            kvoInfo.state = YFKVOInfoState.YFKVOInfoStateUnObserving
        }
        pthread_mutex_unlock(&rMutex!)
        
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        var info: YFKVOInfo?
        pthread_mutex_lock(&rMutex!)
        info =  self.kvoInfos?.member(context?.load(as: YFKVOInfo.self)) as! YFKVOInfo?
        pthread_mutex_unlock(&rMutex!)
        
        if let curInfo = info {
            
            if let theManager = curInfo.manager {
                
                if let observer = theManager.kvoObserver {
                    if let theCallBack = curInfo.callBack{
                        theCallBack(observer,object,change)
                    }
                    if let theSelector = curInfo.action{
                        observer.perform(theSelector, with: change, with: curInfo.context)
                    }
                }
            
            }
            
        
            
        }

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

