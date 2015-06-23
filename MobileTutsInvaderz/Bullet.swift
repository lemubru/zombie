//
//  Bullet.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/13.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//
import UIKit
import SpriteKit

class Bullet: SKSpriteNode {
    
    
    init(imageName: String, bulletSound: String?, scene: SKScene, bulletName: String?) {
        
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        scene.addChild(self)
        self.zPosition = 20
        if(bulletSound != nil){
            runAction(SKAction.playSoundFileNamed(bulletSound!, waitForCompletion: false))
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
