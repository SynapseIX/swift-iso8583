//
//  ViewController.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/14/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func goToWebsite(sender: AnyObject) {
        if let jorgeURL = NSURL(string: "http://jorgetapia.net") {
            UIApplication.sharedApplication().openURL(jorgeURL)
        }
    }
    
    @IBAction func goToRepoWebsite(sender: AnyObject) {
        if let repoURL = NSURL(string: "https://github.com/georgetapia/Swift-ISO8583") {
            UIApplication.sharedApplication().openURL(repoURL)
        }
    }
}

