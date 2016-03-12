//
//  GameScene.swift
//  ShootingBallGame
//
//  Created by XingPengfei on 3/11/16.
//  Copyright (c) 2016 Pengfei Xing. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var cannon : SKSpriteNode!
    var touchLocation : CGPoint = CGPointZero
    
    override func didMoveToView(view: SKView) {
        cannon = self.childNodeWithName("cannon") as! SKSpriteNode
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let percent = touchLocation.x / size.width
        let newAngel = percent * 180 - 180
        cannon.zRotation = CGFloat(newAngel) * CGFloat(M_PI) / 180.0
    }
}
