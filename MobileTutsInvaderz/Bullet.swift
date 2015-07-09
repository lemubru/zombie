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
    
    
    init(imageName: String, bulletSound: String?, scene: SKScene, bulletName: String?, atlas: SKTextureAtlas, bulletSoundAction: SKAction) {
        
        let texture = atlas.textureNamed(imageName)
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        scene.addChild(self)
        self.zPosition = 20
        if(bulletSound != nil){
            runAction(bulletSoundAction)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
