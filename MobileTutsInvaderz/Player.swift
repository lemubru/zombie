//
//  Player.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/13.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//
import UIKit
import SpriteKit


class Player: SKSpriteNode {
    private var canFire = true
    
    init() {
        let texture = SKTexture(imageNamed: "turret")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())

        //animate()
        
        
        self.name = "player"
        
    }
    //LOLOLOLOL
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func animate(){
        var playerTextures:[SKTexture] = []
        for i in 1...2 {
            playerTextures.append(SKTexture(imageNamed: "player\(i)"))
        }
        let playerAnimation = SKAction.repeatActionForever( SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1))
        self.runAction(playerAnimation)
    }
    
    
    func die (){
        
    }
    
    func kill(){
        
    }
    
    func respawn(){
        
    }
    
    func fireBullet(scene: SKScene, touchX: CGFloat, touchY: CGFloat, bulletTexture: String,bulletScale: CGFloat, speedMultiplier: CGFloat, bulletSound: String, canFireWait: Double, multiShot: Bool, bulletName: String){
        if(!canFire){
            return
        }else{
            
            let projectileSpeedMultiplier = speedMultiplier
            //"ArrowTexture"
            canFire = false
            let bullet = PlayerBullet(imageName: bulletTexture,bulletSound: bulletSound,scene: scene, bulletName: bulletName)
           
            let opposite = touchY -  self.position.y
            let adjacent = touchX - self.position.x
            let Pi = CGFloat(M_PI)
            let spread = CGFloat(2)
            let DegreesToRadians = Pi / 180
            let RadiansToDegrees = 180 / Pi
            let angle = atan2(opposite,adjacent)
            let newY = sin(angle)*2000
            let newX = cos(angle)*2000
            let newY1 = sin(angle - spread * DegreesToRadians)*2000
            let newX1 = cos(angle - spread * DegreesToRadians)*2000
            let newY2 = sin(angle + spread * DegreesToRadians)*2000
            let newX2 = cos(angle + spread * DegreesToRadians)*2000
         
            bullet.position.x = self.position.x
            bullet.position.y = self.position.y
            bullet.setScale(bulletScale)
            bullet.zRotation = angle
            
      
            self.zRotation = angle - 90 * DegreesToRadians
            
            
           //bullet.zRotation = self.zRotation
            bullet.physicsBody?.applyImpulse(CGVectorMake(newX*projectileSpeedMultiplier,
                newY*projectileSpeedMultiplier))
            
            if(multiShot){
                let bullet1 = PlayerBullet(imageName: bulletTexture,bulletSound: bulletSound,scene: scene, bulletName: bulletName)
                    bullet1.position.x = self.position.x
                    bullet1.position.y = self.position.y
                    bullet1.setScale(bulletScale)
                    bullet1.zRotation = angle - spread * DegreesToRadians
                    bullet1.physicsBody?.applyImpulse(CGVectorMake(newX1*projectileSpeedMultiplier, newY1*projectileSpeedMultiplier))
                let bullet2 = PlayerBullet(imageName: bulletTexture,bulletSound: bulletSound,scene: scene, bulletName: bulletName)
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
