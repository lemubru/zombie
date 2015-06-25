//
//  ScenePiece.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/17.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import UIKit
import SpriteKit

class ScenePiece: SKSpriteNode {
    
    init(pieceName: String?, textTureName: String?, dynamic: Bool, scale: CGFloat, x: CGFloat, y: CGFloat) {
        let texture = SKTexture(imageNamed: textTureName!)
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.name = pieceName
        self.position.x = x
        self.position.y = y
        self.setScale(scale)
        
    }
    
    func AddPhysics(scene: SKScene, dynamic: Bool){
        
        scene.addChild(self)
        if(self.name == "rocks" || self.name == "saw"){
            
            self.physicsBody =
                SKPhysicsBody(circleOfRadius: self.size.width/2)
        }else if(self.name == "turretRad"){
            self.physicsBody =
                SKPhysicsBody(circleOfRadius: self.size.width)
        }else{
            self.physicsBody =
                SKPhysicsBody(texture: self.texture, size: self.size)
        }
        self.physicsBody?.dynamic = dynamic
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.mass = 10.0;
        self.physicsBody?.friction = 30;
        self.physicsBody?.linearDamping = 0.0;
        self.physicsBody?.angularDamping = 0.0;
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = CollisionCategories.ScenePiece
        self.physicsBody?.contactTestBitMask = CollisionCategories.Invader | CollisionCategories.PlayerBullet | CollisionCategories.floor
        self.physicsBody?.collisionBitMask = CollisionCategories.floor
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
}
