//
//  GameScene.swift
//  ShootingBallGame
//
//  Created by XingPengfei on 3/11/16.
//  Copyright (c) 2016 Pengfei Xing. All rights reserved.
//

import SpriteKit

let wallMask : UInt32 = 0x1 << 0
let ballMask : UInt32 = 0x1 << 1
let pegMask :UInt32 = 0x1 << 2
let squareMask : UInt32 = 0x1 << 3
let orangePegMask : UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var cannon : SKSpriteNode!
    var touchLocation : CGPoint = CGPointZero
    
    override func didMoveToView(view: SKView) {
        cannon = self.childNodeWithName("cannon") as! SKSpriteNode
        self.physicsWorld.contactDelegate = self
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        let ball : SKSpriteNode = SKScene(fileNamed:"Ball")!.childNodeWithName("ball")! as! SKSpriteNode
        ball.removeFromParent()
        self.addChild(ball)
        ball.zPosition = 0
        ball.position = cannon.position
        let angleInRadians = Float(cannon.zRotation)
        let speed = CGFloat(105.0)
        let vx : CGFloat = CGFloat(cosf(angleInRadians)) * speed
        let vy : CGFloat = CGFloat(sinf(angleInRadians)) * speed
        ball.physicsBody?.applyImpulse(CGVectorMake(vx, vy))
        
        ball.physicsBody?.collisionBitMask = wallMask | ballMask | pegMask | orangePegMask
        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask | squareMask
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let percent = touchLocation.x / size.width
        let newAngel = percent * 180 - 180
        cannon.zRotation = CGFloat(newAngel) * CGFloat(M_PI) / 180.0
    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        let ball = (contact.bodyA.categoryBitMask == ballMask) ? contact.bodyA : contact.bodyB
        let other = (ball == contact.bodyA) ? contact.bodyB : contact.bodyA
        if other.categoryBitMask == pegMask || other.categoryBitMask == orangePegMask{
                self.didHitPeg(other)
        }
        else if other.categoryBitMask == squareMask {
//            print("hit square!")
        }
        else if other.categoryBitMask == wallMask {
//            print("hit wall!")
        }
        else if other.categoryBitMask == ballMask {
//            print("hit ball!")
        }
    }
    
    func didHitPeg(peg : SKPhysicsBody) {
        let blue = UIColor(red: 0.16, green: 0.73, blue: 0.78, alpha: 1.0)
        let orange = UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        
        let spark : SKEmitterNode = SKEmitterNode(fileNamed: "SparkParticle")!
        print("===")
        spark.position = peg.node!.position
        spark.particleColor = (peg.categoryBitMask == orangePegMask) ? orange : blue
        
        self.addChild(spark)
        peg.node?.removeFromParent()
    }
    
    
}
