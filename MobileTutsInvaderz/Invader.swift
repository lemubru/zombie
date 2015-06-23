//
//  Invader.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/13.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import UIKit
import SpriteKit

class Invader: SKSpriteNode {
    
    var invaderRow = 0
    var invaderColumn = 0
    var invaderSpeed = 3
    var invaderhit = UInt32()
    
    init(scene: SKScene, scale: CGFloat, invaderhit: UInt32, animprefix:String?, name:String?) {
        let texture = SKTexture(imageNamed: "soldierrun2")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.setScale(scale)
        scene.addChild(self)
        self.name = name
        var hits = 0
        self.invaderhit = invaderhit
        animate(animprefix)
        self.physicsBody =
            SKPhysicsBody(texture: self.texture, size: self.size)
        self.physicsBody?.dynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.mass = 10.0;
        self.physicsBody?.friction = 0.0;
        self.physicsBody?.linearDamping = 0.0;
        self.physicsBody?.angularDamping = 0.0;
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = CollisionCategories.Invader
        self.physicsBody?.contactTestBitMask = CollisionCategories.floor | CollisionCategories.PlayerBullet
        self.physicsBody?.collisionBitMask = CollisionCategories.floor | CollisionCategories.PlayerBullet
    }
    
    internal func animate(animprefix: String?){
        var playerTextures:[SKTexture] = []
        for i in 0...8 {
            playerTextures.append(SKTexture(imageNamed: animprefix!+"\(i)"))
        }
        let playerAnimation = SKAction.repeatActionForever( SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1))
        self.runAction(playerAnimation)
    }
    
    func hit(hit: UInt32){
        self.invaderhit = hit
    }
    
    func gethit() -> UInt32{
        return self.invaderhit
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}