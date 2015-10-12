//
//  StartViewController.swift
//  Break
//
//  Created by Joe E. on 10/8/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBAction func play(sender: AnyObject) {
        let gameVc = GameViewController()
        navigationController?.viewControllers = [gameVc]

        
    }
    
    override func viewDidLoad() {
        let topScore = GameData.mainData().topScore
        highScoreLabel.text = "HIGH SCORE: \(topScore)"
        
    }
    
}