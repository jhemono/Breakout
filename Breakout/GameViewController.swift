//
//  GameViewController.swift
//  Breakout
//
//  Created by Julien Hémono on 26/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

struct Grid {
    var rows: Int
    var columns: Int
}

class GameViewController: UIViewController, BreakoutBehaviorDelegate {
    
    @IBOutlet weak var gameView: GameView!
    
    //MARK: - BreakoutBehaviorDelegate
    
    func breakoutBehavior(breakoutBehavior: BreakoutBehavior, ballHitBoundaryWithIdentifier identifier: NSCopying) {
        if let counter = identifier as? Int {
            if let brick = bricks[counter] {
                UIView.animateWithDuration(0.25, delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: { () -> Void in
                        brick.alpha = CGFloat(0.0)
                        brick.transform = CGAffineTransformScale(CGAffineTransformRotate(brick.transform, CGFloat(M_PI_4)), 0.1, 0.1)
                    },
                    completion: { (bool) -> Void in
                        brick.removeFromSuperview()
                    })
                breakoutBehavior.removeBrickforIdentifier(counter)
            }
        }
    }
    
    //MARK: - Physiscs
    
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.gameView!) }()
    
    let breakoutBehavior = BreakoutBehavior()
    
    //MARK: - Objects
    
    //MARK: Bricks
    
    let brickGrid = Grid(rows: 3, columns: 5)
    let spacing: CGFloat = 20
    let brickHeight: CGFloat = 20
    
    func makeBricks() {
        let brickWidth = (gameView!.frame.size.width - (CGFloat(brickGrid.columns + 1) * spacing)) / CGFloat(brickGrid.columns)
        let brickSize = CGSize(width: brickWidth, height: brickHeight)
        
        var counter = 0
        for i in 0..<brickGrid.rows {
            let y = spacing + ((spacing + brickHeight) * CGFloat(i))
            for j in 0..<brickGrid.columns {
                let x = spacing + ((spacing + brickWidth) * CGFloat(j))
                let origin = CGPoint(x: x, y: y)
                let brick = UIView(frame: CGRect(origin: origin, size: brickSize))
                brick.backgroundColor = UIColor.blackColor()
                breakoutBehavior.addBrick(brick.frame, forIdentifier: counter)
                gameView!.addSubview(brick)
                bricks[counter] = brick
                counter++
            }
        }
    }
    
    var bricks: [Int:UIView] = [:]
    
    //MARK: Paddle
    
    let paddleSize = CGSize(width: 60, height: 30)
    
    let distanceFromPaddleToBottom:CGFloat = 60.0
    
    lazy var paddle: UIView = {
        let gameView = self.gameView!
        let paddle = UIView()
        paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - self.distanceFromPaddleToBottom)
        paddle.frame.size = self.paddleSize
        paddle.backgroundColor = UIColor.orangeColor()
        gameView.addSubview(paddle)
        return paddle
    }()
    
    //MARK: Ball
    
    let ballSize = CGSize(width: 20.0, height: 20.0)
    
    lazy var ball: UIView = {
        let paddle = self.paddle
        let ball = UIView()
        ball.center = CGPoint(x: paddle.frame.midX, y: paddle.frame.minY - self.ballSize.height)
        ball.frame.size = self.ballSize
        ball.backgroundColor = UIColor.purpleColor()
        return ball
    }()
    
    //MARK: - Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        breakoutBehavior.hitDelegate = self
        animator.addBehavior(breakoutBehavior)
        
        breakoutBehavior.updatePaddle(paddle.frame)
        breakoutBehavior.addBall(ball)
        makeBricks()
    }
    
    //MARK: - Gestures
    
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        breakoutBehavior.pushBall(ball)
    }
    
    @IBAction func panPaddle(sender: UIPanGestureRecognizer) {
        let x = sender.locationInView(gameView).x
        paddle.center.x = x
        breakoutBehavior.updatePaddle(paddle.frame)
    }
}

