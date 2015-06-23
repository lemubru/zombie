//
//  Mummy.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/16.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//
import UIKit
import SpriteKit

class Mummy: SKSpriteNode {

    
    init(scene: SKScene) {
        let texture = SKTexture(imageNamed: "soldierrun2")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        scene.addChild(self)
        self.name = "invader"
        animate()
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
    
    internal func animate(){
        var playerTextures:[SKTexture] = []
        for i in 0...8 {
            playerTextures.append(SKTexture(imageNamed: "soldierrun\(i)"))
        }
        let playerAnimation = SKAction.repeatActionForever( SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1))
        self.runAction(playerAnimation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
}
