//
//  ViewController.swift
//  YFKVOManagerCase
//
//  Created by yaonphy on 17/4/10.
//  Copyright © 2017年 YF. All rights reserved.
//

import UIKit


//class PersonModel: NSObject {
//    dynamic var name = ""
//    dynamic var test = ""
//}
//
//class PersonModel22: NSObject {
//    dynamic var name = ""
//    dynamic var test = ""
//}

class ViewController: UIViewController {
    
    var kvoContext:String = "kvoContext"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let thePerson: PersonModel = PersonModel.init()
//        let thePerson22: PersonModel22 = PersonModel22.init()
//        for i in 0...2{
//            
//            //        thePerson.addObserver(self, forKeyPath: "name", options: NSKeyValueObservingOptions([.new,.old]), context: &kvoContext)
//            let _ =  YFSharedObserver.sharedInstance.observe(observedObj: thePerson, for: "name", with: NSKeyValueObservingOptions([.new,.old]), and: {
//                (observedObj: Any?, change: Dictionary<NSKeyValueChangeKey,Any>?) -> Void in
//                print(i,observedObj ?? "null",change?[NSKeyValueChangeKey.newKey] ?? "null",change?[NSKeyValueChangeKey.oldKey] ?? "null", separator: "====")
//                
//            })
//            
//            let _ =  YFSharedObserver.sharedInstance.observe(observedObj: thePerson, for: "test", with: NSKeyValueObservingOptions([.new,.old]), and: {
//                (observedObj: Any?, change: Dictionary<NSKeyValueChangeKey,Any>?) -> Void in
//                print(i,observedObj ?? "null",change?[NSKeyValueChangeKey.newKey] ?? "null",change?[NSKeyValueChangeKey.oldKey] ?? "null", separator: "====")
//                
//            })
//            
//            let _ =  YFSharedObserver.sharedInstance.observe(observedObj: thePerson22, for: "name", with: NSKeyValueObservingOptions([.new,.old]), and: {
//                (observedObj: Any?, change: Dictionary<NSKeyValueChangeKey,Any>?) -> Void in
//                print(i,observedObj ?? "null",change?[NSKeyValueChangeKey.newKey] ?? "null",change?[NSKeyValueChangeKey.oldKey] ?? "null", separator: "====")
//                
//            })
//            
//            let _ =  YFSharedObserver.sharedInstance.observe(observedObj: thePerson22, for: "test", with: NSKeyValueObservingOptions([.new,.old]), and: {
//                (observedObj: Any?, change: Dictionary<NSKeyValueChangeKey,Any>?) -> Void in
//                print(i,observedObj ?? "null",change?[NSKeyValueChangeKey.newKey] ?? "null",change?[NSKeyValueChangeKey.oldKey] ?? "null", separator: "====")
//                
//            })
//            
//            print(YFSharedObserver.sharedInstance.observedObjects ?? "null", separator: "------")
//
//            
//            thePerson.name = "haha"
//            thePerson.test = "test"
//            thePerson.name = "hahahahahahahahahaha"
//            thePerson.test = "sfsafsoagag"
//            
//            thePerson22.name = "haha22222"
//            thePerson22.test = "test22222"
//            thePerson22.name = "hahahahahahahahahaha22222"
//            thePerson22.test = "sfsafsoagag22222"
//            
//            let _ = YFSharedObserver.sharedInstance.unObserve(observedObj: thePerson, for: "name")
//            let _ = YFSharedObserver.sharedInstance.unObserve(observedObj: thePerson, for: "test")
//            
//            let _ = YFSharedObserver.sharedInstance.unObserve(observedObj: thePerson22, for: "name")
//            let _ = YFSharedObserver.sharedInstance.unObserve(observedObj: thePerson22, for: "test")
//            
//            print(YFSharedObserver.sharedInstance.observedObjects ?? "null", separator: "------")
//
//
//        }
        
        let navCtr = UINavigationController.init(rootViewController: MainViewController())
        self.view.addSubview(navCtr.view)
        self .addChildViewController(navCtr)
        

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let theChage = change {
            print(theChage[NSKeyValueChangeKey.newKey] ?? "null",theChage[NSKeyValueChangeKey.oldKey] ?? "null", separator: "====")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

