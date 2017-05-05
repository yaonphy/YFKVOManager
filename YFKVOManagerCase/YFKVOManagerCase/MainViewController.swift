//
//  MainViewController.swift
//  YFKVOManagerCase
//
//  Created by yaonphy on 17/5/5.
//  Copyright © 2017年 YF. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nextButton = UIButton.init(type: UIButtonType.custom)
        nextButton.addTarget(self, action: #selector(self.nextButtonTouched(button:)), for: UIControlEvents.touchUpInside)
        nextButton.setTitle("Next", for: UIControlState.normal)
        nextButton.backgroundColor = UIColor.orange
        nextButton.frame = CGRect.init(x: 30, y: 80, width: 100, height: 40)
        view.addSubview(nextButton);
        
        
        
    }

    func nextButtonTouched(button: UIButton) -> Void {
        
        let testCtr = TestController()
        self.navigationController?.pushViewController(testCtr, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
