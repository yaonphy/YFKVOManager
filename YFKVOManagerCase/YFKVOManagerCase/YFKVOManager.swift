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
    
    convenience init(obsever:NSObject,isOwn:Bool) {
        self.init()
        self.own = isOwn
        
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
            }
            return YFKVOManager.init(obsever: self, isOwn: false)
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.KVOManagerKey,newValue,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var UnOwnKVOManager: YFKVOManager? {
        get {
            if let managager = objc_getAssociatedObject(self, &NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey) {
                return managager as? YFKVOManager
            }
            return YFKVOManager.init(obsever: self, isOwn: true)
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey,newValue,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    
}

