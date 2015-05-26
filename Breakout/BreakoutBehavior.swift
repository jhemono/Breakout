//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Julien Hémono on 26/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

protocol BoundaryItem {
    var key: String { get }
    var frame: CGRect { get }
}

class BreakoutBehavior: UIDynamicBehavior {
    lazy var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let ballBehavior = UIDynamicItemBehavior()
        ballBehavior.elasticity = 1.0
        ballBehavior.allowsRotation = false
        return ballBehavior
    }()
    
    lazy var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior()
        gravity.magnitude = 0.3
        return gravity
    }()
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        addChildBehavior(gravity)
    }
    
    func addBrick(brick: BoundaryItem) {
        let path = UIBezierPath(rect: brick.frame)
        collider.addBoundaryWithIdentifier(brick.key, forPath: path)
    }
    
    func updatePaddle(paddle: BoundaryItem) {
        collider.removeBoundaryWithIdentifier(paddle.key)
        let path = UIBezierPath(ovalInRect: paddle.frame)
        collider.addBoundaryWithIdentifier(paddle.key, forPath: path)
    }
    
    func removeBoundaryItem(boundaryItem: BoundaryItem) {
        collider.removeBoundaryWithIdentifier(boundaryItem.key)
    }
    
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        ballBehavior.addItem(ball)
        collider.addItem(ball)
        gravity.addItem(ball)
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
}

extension CGFloat {
    static var randomRatio: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
