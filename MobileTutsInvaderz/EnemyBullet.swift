//
//  EnemyBullet.swift
//  Zombie Attack
//
//  Created by Frank du Plessis on 2015/06/27.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import UIKit
import SpriteKit

class EnemyBullet: Bullet {
    
    var hasHit = false
    
    override init(imageName: String, bulletSound:String?,scene: SKScene, bulletName: String?){
        hasHit = false
        super.init(imageName: imageName, bulletSound: bulletSound,scene:scene, bulletName: bulletName)
        self.zPosition = CGFloat(5)
        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)
        self.physicsBody?.dynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.usesPreciseCollisionDetection = false
        self.physicsBody?.restitution = 0.5;
        //   self.physicsBody?.mass = 0
        self.physicsBody?.friction = 0.0;
        self.physicsBody?.linearDamping = 0.0;
        self.physicsBody?.angularDamping = 0.0;
        self.physicsBody?.categoryBitMask = CollisionCategories.EnemyBullet
        self.physicsBody?.contactTestBitMask = CollisionCategories.floor | CollisionCategories.Player | CollisionCategories.PlayerBullet | CollisionCategories.Gfield
        self.physicsBody?.collisionBitMask = CollisionCategories.floor  | CollisionCategories.Player | CollisionCategories.PlayerBullet | CollisionCategories.Gfield
        self.name = bulletName
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func hit(){
        self.hasHit = true
    }
    
    func getHasHit() -> Bool{
        return self.hasHit
    }
   
}
