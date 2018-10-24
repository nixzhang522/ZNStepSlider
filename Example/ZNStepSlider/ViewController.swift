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
    
    lazy var noramlSlider: ZNStepSlider = {
        var slider = ZNStepSlider.init(frame: CGRect(x: 30, y: 150, width: UIScreen.main.bounds.width - 60, height: 30))
        slider.scales = [0.3, 0.45, 0.8, 0.9]
        slider.isSliderScale = true
        slider.tintColor = UIColor.red
        return slider
    }()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.noramlSlider)
        
        slider.scales = [0, 0.1, 0.5, 0.9]
        slider.index = 2
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

