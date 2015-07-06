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
    private var canFire = true
    var invaderRow = 0
    var invaderColumn = 0
    var invaderSpeed = 3
    var invaderhit = UInt32()
    var lockedOn = false
    var gunner = false

    
    init(scene: SKScene, scale: CGFloat, invaderhit: UInt32, animprefix:String?, name:String?,gunner: Bool,atlas: SKTextureAtlas) {
       
        let texture = atlas.textureNamed("soldierrun0")
        
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.setScale(scale)
        scene.addChild(self)
        self.name = name
        self.lockedOn = false
        self.gunner = gunner
        var hits = 0
        self.invaderhit = invaderhit
        animate(animprefix, atlas: atlas)
        if(name == "heavy"){
            self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width*0.35, center: CGPoint(x: self.position.x , y: self.position.y-10))
        }else{
            self.physicsBody =
                SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width*0.2, height: self.size.height*0.8), center: CGPoint(x:self.position.x,y:self.position.y-10))
        }
        
        self.physicsBody?.dynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.mass = 10.0;
        self.physicsBody?.friction = 0.0;
        self.physicsBody?.linearDamping = 0.0;
        self.physicsBody?.angularDamping = 0.0;
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = CollisionCategories.Invader
        self.physicsBody?.contactTestBitMask = CollisionCategories.floor | CollisionCategories.PlayerBullet | CollisionCategories.ScenePiece | CollisionCategories.Player | CollisionCategories.Spikes
        self.physicsBody?.collisionBitMask = CollisionCategories.floor | CollisionCategories.PlayerBullet  | CollisionCategories.Player
        self.physicsBody?.fieldBitMask = 0
    }
    func isGunner() -> Bool{
        return gunner
    }
    
    
    internal func animate(animprefix: String?, atlas: SKTextureAtlas){
        
        var soldieratlas = atlas
        if(self.name == "heavy"){
              soldieratlas = SKTextureAtlas(named: "heavy")
        }else if(self.name == "zombie"){
              soldieratlas = SKTextureAtlas(named: "zombie")
        }
        
        var playerTextures:[SKTexture] = []
        
        let numImages = soldieratlas.textureNames.count-1
        for i in 0...numImages {
            let texture = animprefix!+"\(i)"
            playerTextures.append(soldieratlas.textureNamed(texture))
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
    
    func getLock() -> Bool{
        return lockedOn
    }
    func setLocked(){
        
        self.lockedOn = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func fireBullet(scene: SKScene, touchX: CGFloat, touchY: CGFloat, bulletTexture: String,bulletScale: CGFloat, speedMultiplier: CGFloat, bulletSound: String, canFireWait: Double, multiShot: Bool, bulletName: String, atlas: SKTextureAtlas){
        if(!canFire){
            return
        }else{
          
            let projectileSpeedMultiplier = speedMultiplier
            //"ArrowTexture"
            canFire = false
            let bullet = EnemyBullet(imageName: bulletTexture,bulletSound: bulletSound,scene: scene, bulletName: bulletName, atlas: atlas)
            
            let opposite = touchY -  self.position.y
            let adjacent = touchX - self.position.x
            let Pi = CGFloat(M_PI)
            let spread = CGFloat(2)
            let DegreesToRadians = Pi / 180
            let RadiansToDegrees = 180 / Pi
            let angle = atan2(opposite,adjacent)
            let newY = sin(angle)*1000
            let newX = cos(angle)*1000
            let newY1 = sin(angle - spread * DegreesToRadians)*2000
            let newX1 = cos(angle - spread * DegreesToRadians)*2000
            let newY2 = sin(angle + spread * DegreesToRadians)*2000
            let newX2 = cos(angle + spread * DegreesToRadians)*2000
            
            bullet.position.x = self.position.x
            bullet.position.y = self.position.y
            bullet.setScale(bulletScale)
            bullet.zRotation = angle
          
            
            
            //self.zRotation = angle - 90 * DegreesToRadians
            
            
            //bullet.zRotation = self.zRotation
            bullet.physicsBody?.applyImpulse(CGVectorMake(newX*projectileSpeedMultiplier,
                newY*projectileSpeedMultiplier))
            
            if(multiShot){
                let bullet1 = EnemyBullet(imageName: bulletTexture,bulletSound: bulletSound,scene: scene, bulletName: bulletName, atlas: atlas)
                bullet1.position.x = self.position.x
                bullet1.position.y = self.position.y
                bullet1.setScale(bulletScale)
                bullet1.zRotation = angle - spread * DegreesToRadians
                bullet1.physicsBody?.applyImpulse(CGVectorMake(newX1*projectileSpeedMultiplier, newY1*projectileSpeedMultiplier))
                let bullet2 = PlayerBullet(imageName: bulletTexture,bulletSound: bulletSound,scene: scene, bulletName: bulletName, atlas: atlas)
                bullet2.position.x = self.position.x
                bullet2.position.y = self.position.y
                bullet2.setScale(bulletScale)
                bullet2.zRotation = angle + spread * DegreesToRadians
                bullet2.physicsBody?.applyImpulse(CGVectorMake(newX2*projectileSpeedMultiplier, newY2*projectileSpeedMultiplier))
            }
            if(bulletSound == "shotgunsound.mp3"){
                let wait  = SKAction.waitForDuration(1)
                let reloadsound = SKAction.playSoundFileNamed("shotgunreload.mp3", waitForCompletion: true)
                runAction(SKAction.sequence([wait,reloadsound]))
            }
            let waitToEnableFire = SKAction.waitForDuration(canFireWait)
            runAction(waitToEnableFire,completion:{
                self.canFire = true
            })
        }
    }
    
    

}