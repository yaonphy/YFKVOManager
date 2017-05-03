//
//  ViewController.swift
//  YFKVOManagerCase
//
//  Created by yaonphy on 17/4/10.
//  Copyright © 2017年 YF. All rights reserved.
//

import UIKit


class PersonModel: NSObject {
    dynamic var name = ""

}


class ViewController: UIViewController {
    
    var kvoContext:String = "kvoContext"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let thePerson: PersonModel = PersonModel.init()
    
        thePerson.addObserver(self, forKeyPath: "name", options: NSKeyValueObservingOptions([.new,.old]), context: &kvoContext)
        
        
        thePerson.name = "haha"

        thePerson.name = "hahahahahahahahahaha"

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let theChage = change {
            print(theChage[NSKeyValueChangeKey.newKey] ?? "null")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

