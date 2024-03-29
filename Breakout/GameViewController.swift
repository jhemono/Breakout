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
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var ballsLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    //MARK: - Display
    
    func updateBallsLabel() {
        ballsLabel.text = "Ball \(ballNumber + 1)/\(numberOfTries)"
    }
    
    func upDateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    //MARK: - BreakoutBehaviorDelegate
    
    func breakoutBehavior(breakoutBehavior: BreakoutBehavior, ballHitBoundaryWithIdentifier identifier: NSCopying) {
        if let counter = identifier as? Int {
            removeBrickWithCounter(counter, animated: true)
            score += 10
            if bricks.isEmpty {
                let alert = UIAlertController(title: "You win!", message: "You broke all the bricks and finished with a score of \(score).", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Start over", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.resetGame()
                }))
                presentViewController(alert, animated: true, completion: nil)
            }
        } else if let name = identifier as? String {
            if name == BreakoutBehavior.Constants.paddleIdentifier {
                score -= 1
            }
        }
    }
    
    func breakoutBehavior(breakoutBehavior: BreakoutBehavior, ballFellOff: UIView) {
        makeBall()
        ballNumber++
        if ballNumber >= numberOfTries {
            resetGame()
            let alert = UIAlertController(title: "Game over", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .Default, handler: { (_) -> Void in
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Physiscs
    
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.gameView!) }()
    
    let breakoutBehavior = BreakoutBehavior()
    
    //MARK: - Objects
    
    //MARK: Bricks
    
    func makeBricks() {
        let brickWidth = (gameView!.frame.size.width - (CGFloat(Constants.brickGrid.columns + 1) * Constants.spacing)) / CGFloat(Constants.brickGrid.columns)
        let brickSize = CGSize(width: brickWidth, height: Constants.brickHeight)
        
        var counter = 0
        for i in 0..<Constants.brickGrid.rows {
            let y = Constants.spacing + ((Constants.spacing + Constants.brickHeight) * CGFloat(i))
            for j in 0..<Constants.brickGrid.columns {
                let x = Constants.spacing + ((Constants.spacing + brickWidth) * CGFloat(j))
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
    
    private func removeBrickWithCounter(counter: Int, animated: Bool) {
        if let brick = bricks[counter] {
            if animated {
                UIView.animateWithDuration(0.25, delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: { () -> Void in
                        brick.alpha = CGFloat(0.0)
                        brick.transform = CGAffineTransformScale(CGAffineTransformRotate(brick.transform, CGFloat(M_PI_4)), 0.1, 0.1)
                    },
                    completion: { (bool) -> Void in
                        brick.removeFromSuperview()
                })
            } else {
                brick.removeFromSuperview()
            }
            breakoutBehavior.removeBrickforIdentifier(counter)
            bricks[counter] = nil
        }
    }
    
    var bricks: [Int:UIView] = [:]
    
    //MARK: Paddle
    
    lazy var paddle: UIView = {
        let gameView = self.gameView!
        let paddle = UIView()
        paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - Constants.distanceFromPaddleToBottom)
        paddle.frame.size = Constants.paddleSize
        paddle.backgroundColor = UIColor.orangeColor()
        gameView.addSubview(paddle)
        return paddle
    }()
    
    //MARK: Ball
    
    let numberOfTries = 3
    var ballNumber = 0 {
        didSet { updateBallsLabel() }
    }
    
    func makeBall() -> UIView {
        let paddle = self.paddle
        let ball = UIView()
        ball.center = CGPoint(x: paddle.frame.midX, y: paddle.frame.minY - Constants.ballSize.height)
        ball.frame.size = Constants.ballSize
        ball.backgroundColor = UIColor.purpleColor()
        breakoutBehavior.addBall(ball)
        return ball
    }
    
    lazy var ball: UIView = makeBall(self)()
    
    //MARK: - GamePlay
    
    var score = 0 {
        didSet { upDateScoreLabel() }
    }
    
    func resetGame() {
        for (counter, _) in bricks {
            removeBrickWithCounter(counter, animated: false)
        }
        makeBricks()
        ballNumber = 0
        score = 0
    }
    
    //MARK: - Lifecyle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        breakoutBehavior.hitDelegate = self
        animator.addBehavior(breakoutBehavior)
        
        breakoutBehavior.updatePaddle(paddle.frame)
        makeBricks()
        updateBallsLabel()
        upDateScoreLabel()
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
    
    //MARK: - Constants
    
    private struct Constants {
        // Grid
        static let brickGrid = Grid(rows: 3, columns: 5)
        static let spacing: CGFloat = 21
        static let brickHeight: CGFloat = 20
        // Paddle
        static let paddleSize = CGSize(width: 60, height: 30)
        static let distanceFromPaddleToBottom:CGFloat = 60.0
        // Ball
        static let ballSize = CGSize(width: 20.0, height: 20.0)
    }
}

