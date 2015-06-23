//
//  PlayerBullet.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/13.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import UIKit
import SpriteKit

class PlayerBullet: Bullet {

    override init(imageName: String, bulletSound:String?,scene: SKScene, bulletName: String?){
        super.init(imageName: imageName, bulletSound: bulletSound,scene:scene, bulletName: bulletName)
        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.restitution = 0.5;
     //   self.physicsBody?.mass = 0
        self.physicsBody?.friction = 0.0;
        self.physicsBody?.linearDamping = 0.0;
        self.physicsBody?.angularDamping = 0.0;
        self.physicsBody?.categoryBitMask = CollisionCategories.PlayerBullet
        self.physicsBody?.contactTestBitMask = CollisionCategories.floor | CollisionCategories.Invader 
        self.physicsBody?.collisionBitMask = CollisionCategories.floor  | CollisionCategories.Invader
        self.name = bulletName
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}