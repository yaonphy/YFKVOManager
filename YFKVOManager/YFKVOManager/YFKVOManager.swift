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
    
    init(obsever:NSObject,isOwn:Bool) {
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
            var managager = objc_getAssociatedObject(self, &NSObjectYFKVOManagerAssociatedKeys.KVOManagerKey)
            if managager == nil {
                managager = YFKVOManager.init(self, false)
            }
            return managager
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.KVOManagerKey,newValue?,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var UnOwnKVOManager: YFKVOManager? {
        get {
            return  objc_getAssociatedObject(self, &NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey)

        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&NSObjectYFKVOManagerAssociatedKeys.unOwnKVOManagerKey,newValue?,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    
}

