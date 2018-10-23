//
//  ViewController.swift
//  ZNStepSlider
//
//  Created by Nix on 10/23/2018.
//  Copyright (c) 2018 Nix. All rights reserved.
//

import UIKit
import ZNStepSlider

class ViewController: UIViewController {

    @IBOutlet weak var slider: ZNStepSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.scales = [0, 0.1, 0.5, 0.9]
        slider.value = 0.33
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

