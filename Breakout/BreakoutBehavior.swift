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
    
    //MARK: - Dynamic Behaviors
    
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
    
    private var tapPush: UIPushBehavior?
    
    //MARK: - UICollisionBehaviorDelegate
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        if let identifier = identifier {
            if let stringIdentifier = identifier as? String {
                if stringIdentifier == Constants.paddleIdentifier {
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
    
    //MARK: - Interface
    
    func addBrick(brick: CGRect, forIdentifier key: NSCopying) {
        let path = UIBezierPath(rect: brick)
        collider.addBoundaryWithIdentifier(key, forPath: path)
    }
    
    func removeBrickforIdentifier(key: NSCopying) {
        collider.removeBoundaryWithIdentifier(key)
    }
    
    func updatePaddle(paddleRect: CGRect) {
        collider.removeBoundaryWithIdentifier(Constants.paddleIdentifier)
        let path = UIBezierPath(ovalInRect: paddleRect)
        collider.addBoundaryWithIdentifier(Constants.paddleIdentifier, forPath: path)
    }
    
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        
        ballBehavior.addItem(ball)
        collider.addItem(ball)
        gravity.addItem(ball)
        
        if let push = UIPushBehavior(items: [ball], mode: .Instantaneous) {
            push.magnitude = Constants.paddlePushMagnitude
            push.angle = CGFloat(-M_PI_2)
            push.active = false
            addChildBehavior(push)
            paddlePush = push
        }
        
        if let push = UIPushBehavior(items: [ball], mode: .Instantaneous) {
            push.magnitude = Constants.tapPushMagnitude
            push.active = false
            addChildBehavior(push)
            tapPush = push
        }
    }
    
    func pushBall(ball: UIView) {
        tapPush?.angle = CGFloat(-M_PI) * CGFloat.randomRatio
        tapPush?.active = true
    }
    
    //MARK: Constants
    
    struct Constants {
        static let paddleIdentifier = "Paddle"
        private static let paddlePushMagnitude: CGFloat = 0.25
        private static let tapPushMagnitude: CGFloat = 0.5
    }
}

extension CGFloat {
    static var randomRatio: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
