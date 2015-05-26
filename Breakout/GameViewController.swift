//
//  GameViewController.swift
//  Breakout
//
//  Created by Julien Hémono on 26/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

struct Paddle: BoundaryItem {
    let key = "Paddle"
    var view: UIView
    var frame: CGRect { return view.frame }
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.gameView!) }()
    
    let breakoutBehavior = BreakoutBehavior()
    
    lazy var paddle: UIView = {
        let gameView = self.gameView!
        let paddle = UIView(frame: CGRect(x: gameView.frame.midX, y: gameView.frame.maxY - 30, width: 30, height: 10))
        paddle.backgroundColor = UIColor.orangeColor()
        gameView.addSubview(paddle)
        return paddle
    }()
    
    lazy var ball: UIView = {
        let paddle = self.paddle
        let ball = UIView(frame: CGRect(x: paddle.frame.midX, y: paddle.frame.minY-20.0, width: 20.0, height: 20.0))
        ball.backgroundColor = UIColor.purpleColor()
        return ball
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator.addBehavior(breakoutBehavior)
        
        breakoutBehavior.updatePaddle(Paddle(view: paddle))
        breakoutBehavior.addBall(ball)
    }
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        breakoutBehavior.pushBall(ball)
    }
}

