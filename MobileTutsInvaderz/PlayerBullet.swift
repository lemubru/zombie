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
    
    var hasHit = false

    override init(imageName: String, bulletSound:String?,scene: SKScene, bulletName: String?, atlas: SKTextureAtlas, bulletSoundAction: SKAction){
        hasHit = false
        super.init(imageName: imageName, bulletSound: bulletSound,scene:scene, bulletName: bulletName, atlas: atlas, bulletSoundAction: bulletSoundAction)
        self.zPosition = CGFloat(5)
        if(bulletName == "arrow"){
            //self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width*0.1, center: CGPoint(x:self.size.width*0.2,y:0))
            self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)
        }else{
            self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width*0.35)
        }
        
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.restitution = 0.1;
     //   self.physicsBody?.mass = 0
        self.physicsBody?.friction = 0.0;
        self.physicsBody?.linearDamping = 0.0;
        self.physicsBody?.angularDamping = 0.0;
        self.physicsBody?.categoryBitMask = CollisionCategories.PlayerBullet
        self.physicsBody?.contactTestBitMask = CollisionCategories.floor | CollisionCategories.Invader | CollisionCategories.EnemyBullet
        self.physicsBody?.collisionBitMask = CollisionCategories.floor  | CollisionCategories.Invader | CollisionCategories.EnemyBullet
        self.name = bulletName
        self.physicsBody?.fieldBitMask = 0
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