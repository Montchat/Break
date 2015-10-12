//
//  StatsViewController.swift
//  Break
//
//  Created by Joe E. on 10/11/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    
    @IBOutlet weak var bricksBusted: UILabel!
    @IBOutlet weak var ballsBusted: UILabel!
    
    @IBAction func back(sender: AnyObject) {
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("StartVC") as? StartViewController {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ballsCount = GameData.mainData().ballsBusted
        let bricksCount = GameData.mainData().bricksBusted
        
        ballsBusted?.text = "balls busted: \(ballsCount)"
        bricksBusted?.text = "bricks busted: \(bricksCount)"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
    }

}
