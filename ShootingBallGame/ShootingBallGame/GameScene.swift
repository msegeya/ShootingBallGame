//
//  GameScene.swift
//  SpriteKitCourse
//
//  Created by LDC on 12/8/15.
//  Copyright (c) 2015 LDC. All rights reserved.
//

import SpriteKit
import AVFoundation

let wallMask:UInt32 = 0x1 << 0 // 1
let ballMask:UInt32 = 0x1 << 1 // 2
let pegMask:UInt32 = 0x1 << 2 // 4
let squareMask:UInt32 = 0x1 << 3 // 8
let orangePegMask:UInt32 = 0x1 << 4 // 16

class GameScene: SKScene, SKPhysicsContactDelegate {
    var cannon:SKSpriteNode!
    var block:SKSpriteNode!
//    var bucket:SKSpriteNode!
    var touchLocation:CGPoint = CGPointZero
    var background : SKAudioNode!
    
    var light : SKLightNode!
    var nodeToFollow : SKNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        cannon = self.childNodeWithName("cannon") as! SKSpriteNode
        block = self.childNodeWithName("block") as! SKSpriteNode
        light = self.childNodeWithName("light") as! SKLightNode
//        bucket = self.childNodeWithName("bucket") as! SKSpriteNode
        self.physicsWorld.contactDelegate = self
        
        let degrees = 90.0
        let rads = degrees * M_PI / 180
        let action = SKAction.rotateByAngle(CGFloat(rads), duration: 3)
//        block.runAction(action)
        block.runAction(SKAction.repeatActionForever(action))
        
//        let a1 = SKAction.moveByX(840.0, y: 0.0, duration: 3.0)
//        a1.timingMode = .EaseInEaseOut
//        let a2 = SKAction.moveByX(-840.0, y: 0.0, duration: 3.0)
//        a2.timingMode = .EaseInEaseOut
//        let seq = SKAction.sequence([a1, a2])
//        bucket.runAction(SKAction.repeatActionForever(seq))
        
//        background = SKAudioNode(fileNamed : "bg.mp3")
//        self.addChild(background)
        do {
            let sounds = ["cannon", "hit"]
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "wav")!))
                player.prepareToPlay()
            }
        } catch {
            
        }
    }
    
    func createFrameAnimation() {
        var frames : [SKTexture] = []
        for var i : Int = 1; i <= 10; i++ {
            let tex : SKTexture  = SKTexture(imageNamed: "\(i).png")
            frames.append(tex)
        }
        //run animation
        //object.runAction(SKAction.animateWithTextures(frames, timePerFrame:0.03))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let ball:SKSpriteNode = SKScene(fileNamed: "Ball")!.childNodeWithName("ball")! as! SKSpriteNode
        ball.removeFromParent()
        self.addChild(ball)
        ball.zPosition = 0
        ball.position = cannon.position
        let angleInRadians = Float(cannon.zRotation)
        let speed = CGFloat(100.0)
        let vx:CGFloat = CGFloat(cosf(angleInRadians)) * speed
        let vy:CGFloat = CGFloat(sinf(angleInRadians)) * speed
        ball.physicsBody?.applyImpulse(CGVectorMake(vx, vy))
        ball.physicsBody?.collisionBitMask = wallMask | ballMask | pegMask | orangePegMask | squareMask
        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
        
        self.runAction(SKAction.playSoundFileNamed("cannon.wav", waitForCompletion: true))
//        background.runAction(SKAction.stop())
        nodeToFollow = ball
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let percent = touchLocation.x / size.width
        let newAngle = percent * 180 - 180
        cannon.zRotation = CGFloat(newAngle) * CGFloat(M_PI) / 180.0
        
        if nodeToFollow != nil {
            light.position = nodeToFollow.position
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let ball = (contact.bodyA.categoryBitMask == ballMask) ? contact.bodyA : contact.bodyB
        let other = (ball == contact.bodyA) ? contact.bodyB : contact.bodyA
        if other.categoryBitMask == pegMask || other.categoryBitMask == orangePegMask {
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
    
    func didHitPeg(peg:SKPhysicsBody) {
        let blue = UIColor(red: 0.16, green: 0.73, blue: 0.78, alpha: 1.0)
        let orange = UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        
        let spark:SKEmitterNode = SKEmitterNode(fileNamed: "SparkParticle")!
        spark.position = peg.node!.position
        spark.particleColor = (peg.categoryBitMask == orangePegMask) ? orange : blue
        self.addChild(spark)
        peg.node?.removeFromParent()
        
        self.runAction(SKAction.playSoundFileNamed("hit.wav", waitForCompletion: true))
    }
}
