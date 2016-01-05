//
//  GameViewController.swift
//  Break
//
//  Created by Joe E. on 10/8/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit
import AVFoundation

enum BoundaryType:String {
    case Floor, LeftWall, RightWall, Ceiling
    
}

class GameViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, AVAudioPlayerDelegate {
    
    //MARK: - ViewController Properties
    
    var animator:UIDynamicAnimator!

    let ballBehavior = UIDynamicItemBehavior()
    let brickBehavior = UIDynamicItemBehavior()
    let paddleBehavior = UIDynamicItemBehavior()
    
    var attachment: UIAttachmentBehavior?
    
    let gravity = UIGravityBehavior()
    let collision = UICollisionBehavior()
    
    let topBar = TopBarView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
    let paddle = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
    var players = [AVAudioPlayer]()
    
    let nextLevelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    let ballsBustedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let bricksBustedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    // MARK: - ALL Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        playSound("KnightRider")
        
        nextLevelButton.setTitle("next level", forState: .Normal)
        nextLevelButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        nextLevelButton.titleLabel?.textColor = UIColor.blackColor()
        nextLevelButton.center = view.center
        
        bricksBustedLabel.hidden = true
        view.addSubview(bricksBustedLabel)
        view.bringSubviewToFront(bricksBustedLabel)
        
        ballsBustedLabel.hidden = true
        view.addSubview(ballsBustedLabel)
        view.bringSubviewToFront(ballsBustedLabel)
    
        view.addSubview(nextLevelButton)
        view.bringSubviewToFront(nextLevelButton)
        
        nextLevelButton.userInteractionEnabled = false
        nextLevelButton.hidden = true
        
        self.topBar.score = GameData.mainData().currentScore
        
        self.animator = UIDynamicAnimator(referenceView: view)
        
        setupBehavior()
        
//         MARK: Background
        
        let bg = UIImageView(image: UIImage(named: "background"))
        bg.frame = view.frame
        
        view.addSubview(bg)
        
        topBar.frame.size.width = view.frame.width
        view.addSubview(topBar)
        
        //run create game elemeents methods
        createPaddle()
        createBall()
        createBricks()
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        for brick in brickBehavior.items as! [UIView] {
            if brick === item1 || brick === item2 {
                
                playSound("Beep")
                
                brickBehavior.removeItem(brick)
                collision.removeItem(brick)
                brick.removeFromSuperview()
                
                if players.count > 2 {
                    players.removeAtIndex(1)
                }
                
                topBar.score += 100
                GameData.mainData().currentScore = topBar.score
                
            }
            
        }
        
        if brickBehavior.items.count == 0 {
            GameData.mainData().currentLevel++
            presentButton()
            removeBehavior()
            
        }

    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let idString = identifier as? String, let boundaryName = BoundaryType(rawValue: idString) {
            
            switch boundaryName {
                
            case .Ceiling : print("I can fly high")
            case .Floor :
                print("IT BURNS")
                
                if let ball = item as? UIView {
                    ballBehavior.removeItem(ball)
                    collision.removeItem(ball)
                    ball.removeFromSuperview()
                    
                }
                
                if topBar.lives == 0 {
                    endGame()
                    
                } else {
                    topBar.lives--
                    createBall()
                }
            
            case .LeftWall : print("Lefty")
            case .RightWall : print("Correct")
            
            }
            
        }
        
    }
    
    // MARK: - 👆 Methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved(touches, withEvent: event)
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(view)
            attachment?.anchorPoint.x = point.x

        }
        
    }
    
    //MARK: Create Game Elements
    
    func createBricks() {
        let levelSetup = GameData.mainData().levels[GameData.mainData().currentLevel]
        
        let cols = levelSetup.0
        let rows = levelSetup.1
        
        let brickH = 30
        let brickSpacing = 5
        
        let totalSpacing = (cols + 1) * brickSpacing
        let brickW = (Int(view.frame.width) - totalSpacing) / cols
        
        for c in 0..<cols {
            for r in 0..<rows {
                
                let x = c * (brickW + brickSpacing) + brickSpacing
                let y = r * (brickH + brickSpacing) + brickSpacing + 60
                
                let brick = UIView(frame: CGRect(x: x, y: y, width: brickW, height: brickH))
                brick.backgroundColor = UIColor.blackColor()
                brick.layer.cornerRadius = 5
                
                view.addSubview(brick)
                
                collision.addItem(brick)
                brickBehavior.addItem(brick)
                
            }
            
        }
        
    }
    
    func createBall() {
        let ball = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ball.layer.cornerRadius = 10
        ball.backgroundColor = UIColor.whiteColor()
        view.addSubview(ball)
        
        ball.center.x = paddle.center.x
        ball.center.y = paddle.center.y - 20
        
        ballBehavior.addItem(ball)
        collision.addItem(ball)
        let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        push.pushDirection = CGVector(dx: 0.1, dy: -0.1)
        
        animator.addBehavior(push)
        
    }
    
    func createPaddle() {
        paddle.layer.cornerRadius = 5
        paddle.backgroundColor = UIColor.blackColor()
        paddle.center = CGPoint(x: view.center.x, y: view.frame.height - 35)
        view.addSubview(paddle)
        paddleBehavior.addItem(paddle)
        collision.addItem(paddle)
        
        attachment = UIAttachmentBehavior(item: paddle, attachedToAnchor: paddle.center)
        animator.addBehavior(attachment!)
        paddleBehavior.allowsRotation = false
        
    }
    
    // MARK: Setup World
    
    func setupBehavior() {
        animator.delegate = self
        
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(ballBehavior)
        animator.addBehavior(brickBehavior)
        animator.addBehavior(paddleBehavior)
        
        collision.collisionDelegate = self
        
        //ball bahavior
        
        ballBehavior.friction = 0
        ballBehavior.resistance = 0
        ballBehavior.elasticity = 1
        ballBehavior.allowsRotation = false
        
        //brick behavior
        
        brickBehavior.anchored = true
        
        //setup paddle behavior
        
        paddleBehavior.allowsRotation = false
        
        collision.translatesReferenceBoundsIntoBoundary = true
        
        collision.addBoundaryWithIdentifier(BoundaryType.Ceiling.rawValue, fromPoint: CGPoint(x: 0, y: 50), toPoint: CGPoint(x: view.frame.width, y: 50))
        collision.addBoundaryWithIdentifier(BoundaryType.Floor.rawValue, fromPoint: CGPoint(x: 0, y: view.frame.height - 10), toPoint: CGPoint(x: view.frame.width, y: view.frame.height - 10))
        
    }
    
    //MARK: - Game Over
    
    func endGame() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startVC = storyboard.instantiateViewControllerWithIdentifier("StartVC")
        navigationController?.viewControllers =  [startVC]
        GameData.mainData().currentScore = 0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.topBar.score = GameData.mainData().currentScore
    }
    
    //MARK: - Setup Next Level
    
    func presentButton() {
        
        let midX = self.view.center.x
        let midY = self.view.center.y
        
        view.bringSubviewToFront(nextLevelButton)
        
        nextLevelButton.setTitle("NEXT LEVEL", forState: .Normal)
        nextLevelButton.frame = CGRect(x: midX, y: midY, width: 100, height: 100)
        nextLevelButton.titleLabel?.textColor = UIColor.whiteColor()
        nextLevelButton.hidden = false
        nextLevelButton.userInteractionEnabled = true
        nextLevelButton.addTarget(self, action: "nextLevel", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func nextLevel() {
        let nextLevelVC = GameViewController()
        nextLevelVC.topBar.score = GameData.mainData().currentScore
        navigationController?.viewControllers = [nextLevelVC]
    }
    
    func removeBehavior() {
        animator.removeAllBehaviors()
        
    }
    
    func playSound(named: String) {
        if let fileData = NSDataAsset(name: named) {
            let data = fileData.data
            
            do {
                let player = try AVAudioPlayer(data: data)
                player.play()
                players.append(player)
                print(players.count)
                
            } catch {
                print(error)
                
            }
            
        }
        
    }

}