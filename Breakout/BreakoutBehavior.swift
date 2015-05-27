//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Julien Hémono on 26/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

protocol BreakoutBehaviorDelegate {
    func breakoutBehavior(breakoutBehavior: BreakoutBehavior, ballHitBoundaryWithIdentifier indentifier: NSCopying)
}

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    private lazy var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    private lazy var ballBehavior: UIDynamicItemBehavior = {
        let ballBehavior = UIDynamicItemBehavior()
        ballBehavior.elasticity = 0.5
        ballBehavior.allowsRotation = false
        return ballBehavior
    }()
    
    private lazy var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior()
        gravity.magnitude = 1.0
        return gravity
    }()
    
    private var paddlePush: UIPushBehavior?
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        if let identifier = identifier {
            if let stringIdentifier = identifier as? String {
                if stringIdentifier == Constants.PaddleIdentifier {
                    println("paddlepush")
                    paddlePush?.active = true
                }
            }
            hitDelegate?.breakoutBehavior(self, ballHitBoundaryWithIdentifier: identifier)
        }
    }
    
    var hitDelegate: BreakoutBehaviorDelegate?
    
    override init() {
        super.init()
        addChildBehavior(collider)
        collider.collisionDelegate = self
        addChildBehavior(ballBehavior)
        addChildBehavior(gravity)
    }
    
    func addBrick(brick: CGRect, forIdentifier key: NSCopying) {
        let path = UIBezierPath(rect: brick)
        collider.addBoundaryWithIdentifier(key, forPath: path)
    }
    
    func removeBrickforIdentifier(key: NSCopying) {
        collider.removeBoundaryWithIdentifier(key)
    }
    
    func updatePaddle(paddleRect: CGRect) {
        collider.removeBoundaryWithIdentifier(Constants.PaddleIdentifier)
        let path = UIBezierPath(ovalInRect: paddleRect)
        collider.addBoundaryWithIdentifier(Constants.PaddleIdentifier, forPath: path)
    }
    
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        ballBehavior.addItem(ball)
        collider.addItem(ball)
        gravity.addItem(ball)
        if let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous) {
            pushBehavior.magnitude = 0.2
            pushBehavior.angle = CGFloat(-M_PI_2)
            pushBehavior.active = false
            addChildBehavior(pushBehavior)
            paddlePush = pushBehavior
        }
    }
    
    func pushBall(ball: UIView) {
        if let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous) {
            pushBehavior.magnitude = CGFloat.randomRatio
            pushBehavior.angle = CGFloat(2 * M_PI) * CGFloat.randomRatio
            pushBehavior.action = { [unowned pushBehavior] in
                pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
            }
            dynamicAnimator?.addBehavior(pushBehavior)
        }
    }
    
    private struct Constants {
        static let PaddleIdentifier = "Paddle"
    }
}

extension CGFloat {
    static var randomRatio: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
