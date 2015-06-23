//
//  GameScene.swift
//  MobileTutsInvaderz
//
//  Created by James Tyner on 2/11/15.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import SpriteKit

var invaderNum = 1
struct CollisionCategories{
    static let Invader : UInt32 = 0x1 << 0
    static let Player: UInt32 = 0x1 << 1
    static let InvaderBullet: UInt32 = 0x1 << 2
    static let PlayerBullet: UInt32 = 0x1 << 3
    static let floor: UInt32 = 0x1 << 4
    static let ScenePiece: UInt32 = 0x1 << 5
}
let Pi = CGFloat(M_PI)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi
class GameScene: SKScene ,SKPhysicsContactDelegate{
    let rowsOfInvaders = 4 //final variable
    var invaderSpeed = 0.2
    var movingRight = false
    var hits = 0
    var invaders = 0
    var playerDead = false
    var movingLeft = false
    var touching = false
    var touchx = CGFloat(1)
    var touchy = CGFloat(1)
    let leftBounds = CGFloat(30) //used to create a margin on the left and right parts of the screen
    var rightBounds = CGFloat(0)
    var invadersWhoCanFire:[Invader] = []
    var invaderArr:[Invader] = []//array of the invaders who can fire.
    let player:Player = Player()
    let flameEmmiter = SKEmitterNode(fileNamed: "flamer.sks")
    let flameNode = ScenePiece(pieceName: "flamenode", textTureName: "floor", dynamic: false, scale: 0.35,x : 2,y: 2)
    let floor = SKSpriteNode(imageNamed: "floor")
    var weapon = 0
    var trap = 0
    var flamerOn = false
    var machineGunMode = false
    var enableTrapDoor = false
    var points = 0

    let timer = Timer() // the timer calculates the time step value dt for every frame
    let scheduler = Scheduler() // an event scheduler
    let scheduleHeavy = Scheduler() // an event scheduler
    let weaponLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        self.physicsWorld.gravity = CGVectorMake(0, -2)
        self.physicsWorld.contactDelegate = self
       loadBG()

        weapon = 0
        trap = 0
        setupPlayer()
        loadHud()
        startSchedulers()
    }
    
    func loadBG(){
        floor.position = CGPointMake(size.width/2,size.height/2 - 130)
        floor.name = "floor" //add reference to the button.
        floor.zPosition = 1
        addChild(floor)
        
        floor.physicsBody = SKPhysicsBody(texture: floor.texture, size: floor.size)
        floor.physicsBody?.dynamic = false
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.allowsRotation = false
        floor.physicsBody?.usesPreciseCollisionDetection = true
        
        
        floor.physicsBody?.categoryBitMask = CollisionCategories.floor
        floor.physicsBody?.contactTestBitMask = CollisionCategories.PlayerBullet | CollisionCategories.Invader | CollisionCategories.ScenePiece
        floor.physicsBody?.collisionBitMask = CollisionCategories.PlayerBullet | CollisionCategories.Invader | CollisionCategories.ScenePiece

        let rain = SKEmitterNode(fileNamed: "ash.sks")
        rain.position.x = self.size.width/2
        rain.position.y = self.size.height
        self.addChild(rain)
        
        
    }
    
    
    func setupPlayer(){
        player.position.x = -self.size.width/2+300
        player.position.y = self.size.height/2
        player.zPosition = 7
        addChild(player)
    }
    
    func setupEnemy(){
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"soldierrun", name:"invader")
        tempInvader.zPosition = 6
        tempInvader.position.x = self.size.width-10
        tempInvader.position.y = self.size.height/2-54
        tempInvader.physicsBody?.velocity = CGVectorMake(-40, 0)
        tempInvader.physicsBody?.mass = 100
        
    }
    
    func setupHeavyEnemy(){
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"heavy", name:"heavy")
        tempInvader.zPosition = 9
        tempInvader.position.x = self.size.width-10
        tempInvader.position.y = self.size.height/2-54
        tempInvader.physicsBody?.velocity = CGVectorMake(-20, 0)
        tempInvader.physicsBody?.mass = 100
        
    }
    
    func startSchedulers(){
        scheduler.every(2.0).perform(self=>GameScene.setupEnemy).end()
        scheduler.start()
        scheduleHeavy.every(5.5).perform(self=>GameScene.setupHeavyEnemy).end()
        scheduleHeavy.start()
        
        
    }
    func loadHud(){
        weaponLabel.text = "pistol";
        weaponLabel.position.x = self.size.width*0.84
        weaponLabel.position.y = self.size.height - 20
        weaponLabel.zPosition = 2
        weaponLabel.fontSize = 17
        pointsLabel.text = String(points)
        pointsLabel.position = CGPoint(x: 30,y: self.size.height-20)
        pointsLabel.fontSize = 30
        pointsLabel.zPosition = 3
        self.addChild(pointsLabel)
        self.addChild(weaponLabel)
        
        
        
        let nextWeaponButton = ScenePiece(pieceName: "nwbutton", textTureName: "nwbutton", dynamic: false, scale: 0.4,x : self.size.width - 20,y: self.size.height - 20)
        
        self.addChild(nextWeaponButton)
        // nextWeaponButton.AddPhysics(self, dynamic: false)
        
        let trapButton = ScenePiece(pieceName: "trapbtn", textTureName: "trapbtn", dynamic: false, scale: 0.4,x : self.size.width - 200,y: self.size.height - 20)
        self.addChild(trapButton)
        
        let nextTrapButton = ScenePiece(pieceName: "nexttrap", textTureName: "nxttrapbtn", dynamic: false, scale: 0.4,x : self.size.width - 150,y: self.size.height - 20)
        self.addChild(nextTrapButton)
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        let touch = touches.first as! UITouch
        touching = true
        var weaponCap  = 5 //meaning 6 weapons - it starts at 1
        var trapCap = 1
        let touchLocation = touch.locationInNode(self)
        touchx = touchLocation.x
        touchy = touchLocation.y
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        
        if(touchedNode.name == "nexttrap"){
            trap++
            if(trap > trapCap){
                trap = 0
            }
        }
        
       else if(touchedNode.name == "nwbutton"){
            runAction(SKAction.playSoundFileNamed("beep.mp3", waitForCompletion: false))
            //let flameNode = PlayerBullet(imageName: "floor", bulletSound: nil, scene: self, bulletName: "floornode")
            weapon++
            if(weapon > weaponCap)
            {
                machineGunMode = false
                weaponLabel.text = "pistol"
                weapon = 0
            }
            if(weapon == 1){
                weaponLabel.text = "fastpistol"
            }
            if(weapon == 2){
               weaponLabel.text = "bow"
            }
           
            if(!flamerOn && weapon == 3){
                runAction(SKAction.playSoundFileNamed("flamersound.mp3", waitForCompletion: false))
                
                let playFlameOngoing = SKAction.playSoundFileNamed("flamergoing.wav", waitForCompletion: true)
                self.runAction(SKAction.repeatActionForever(playFlameOngoing), withKey: "flamer")
                flameNode.hidden = true
                flameNode.position.x = player.position.x
                flameNode.position.y = player.position.y
                flameNode.AddPhysics(self, dynamic: false)
                
                self.addChild(flameEmmiter)
                flameEmmiter.position.x = player.position.x
                flameEmmiter.position.y = player.position.y
                flamerOn = true
                weaponLabel.text = "flamer"
            }
         
            if(weapon == 4){
                weaponLabel.text = "shotgun"
                removeActionForKey("flamer")
                flameEmmiter.removeFromParent()
                flameNode.removeFromParent()
                flamerOn = false
                
                //shotgun
            }
            if(weapon == 5){
               weaponLabel.text = "machinegun"
                machineGunMode = true
            }
            NSLog("buttonpressed"+String(weapon))
        }else if(touchedNode.name == "trapbtn"){
            enableTrapDoor = true
            if(trap == 0){
                spikeFall()
            }else{
                swingingSpikeBall()
            }
        } else{
            var bulletName = "bullet"
            var bulletTexture = "ball"
            var bulletScale = CGFloat(0.4)
            var speedMultiplier = CGFloat(0.002)
            var bulletSound = "gunshot.mp3"
            var canFireWait = 0.1
            var multiShot = false
            if(weapon == 0){
               multiShot = false
                bulletName = "bullet"
                bulletTexture = "ball"
                var bulletScale = 0.4
                speedMultiplier = CGFloat(0.001)
                bulletSound = "gunshot.mp3"
                canFireWait = 0.8
            }
            if(weapon == 2){
                bulletName = "arrow"
                bulletTexture = "ArrowTexture"
                var bulletScale = 0.2
                speedMultiplier = CGFloat(0.003)
                bulletSound = "arrowfire.mp3"
                canFireWait = 0.4
            }
            if(weapon == 4){
                //shotgun
                bulletTexture = "ball"
                var bulletScale = 0.4
                speedMultiplier = CGFloat(0.001)
                bulletSound = "shotgunsound.mp3"
                canFireWait = 0.5
                multiShot = true
            }
            if(!flamerOn && !machineGunMode){
                player.fireBullet(self, touchX:touchLocation.x, touchY:touchLocation.y, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName)
            }
            hits = 0
            let opposite = touchLocation.y - player.position.y
            let adjacent = touchLocation.x - player.position.x
            let Pi = CGFloat(M_PI)
            let DegreesToRadians = Pi / 180
            let RadiansToDegrees = 180 / Pi
            let angle = atan2(opposite,adjacent)
            let newY = sin(angle)*700
            let newX = cos(angle)*700
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        touching = true
        var weaponCap  = 4
        let touchLocation = touch.locationInNode(self)
        touchx = touchLocation.x
        touchy = touchLocation.y
        
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        touching = false
        
    }
    
    override func update(currentTime: CFTimeInterval) {
         floor.position = CGPointMake(size.width/2,size.height/2 - 130)
        floor.physicsBody?.allowsRotation = false
        
        pointsLabel.text = String(points)
        hits = 0
        timer.advance()
        scheduler.update(timer.dt)
        scheduleHeavy.update(timer.dt)
       moveInvaders()
        if(touching){
            rotateGunToTouch()
        }
        if(machineGunMode){
            fireMachineGun()
        }
       // collisionDetection()
        /* Called before each frame is rendered */
    }
    
     func swingingSpikeBall(){
        
        let anchor = ScenePiece(pieceName: "rock", textTureName: "spikes1", dynamic: true, scale: 0.2,x : self.size.width/2,y: self.size.height + 40)
        
        anchor.AddPhysics(self, dynamic: false)
        
        
        let rock1 = ScenePiece(pieceName: "spikeball", textTureName: "spikeball", dynamic: true, scale: 0.4,x : 30,y: self.size.height - 40)
        rock1.AddPhysics(self, dynamic: true)
        rock1.zRotation = rock1.zRotation - 180 * DegreesToRadians
        
        let myJoint = SKPhysicsJointLimit.jointWithBodyA(anchor.physicsBody, bodyB: rock1.physicsBody, anchorA: anchor.position, anchorB: rock1.position)
        self.physicsWorld.addJoint(myJoint)
        
    }
    
    
    func spikeFall(){
      
     
        
         let rock1 = ScenePiece(pieceName: "spikes", textTureName: "spikes1", dynamic: true, scale: 0.2,x : CGFloat( randRange(30, upper: 400)),y: self.size.height - 40)
        rock1.AddPhysics(self, dynamic: true)
        rock1.zRotation = rock1.zRotation - 180 * DegreesToRadians
        
       
    }
    
    func rotateGunToTouch(){
        let opposite = touchy - player.position.y
        let adjacent = touchx - player.position.x
        let Pi = CGFloat(M_PI)
        let DegreesToRadians = Pi / 180
        let RadiansToDegrees = 180 / Pi
        let angle = atan2(opposite,adjacent)
        let newY = sin(angle)*700
        let newX = cos(angle)*700
        
        enumerateChildNodesWithName("flamenode") { node, stop in
            
            
            let invader = node as! SKSpriteNode
            invader.zRotation = angle - 180 * DegreesToRadians
        }
        player.zRotation = angle - 90 * DegreesToRadians
        flameEmmiter.zRotation = angle - 90 * DegreesToRadians
        
    }
    
    func fireMachineGun(){
        if(touching){
        var bulletName = "bullet"
        var bulletTexture = "ball"
        var bulletScale = CGFloat(0.4)
        var speedMultiplier = CGFloat(0.002)
        var bulletSound = "machinegun.wav"
        var canFireWait = 0.09
        var multiShot = false
     player.fireBullet(self, touchX:touchx, touchY:touchy, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName)
        }
        
    }
    

    

    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    

    

   
    
    func moveInvaders(){
        enumerateChildNodesWithName("invader") { node, stop in
            self.invaders++
           // NSLog(String(self.invaders))
            
            let invader = node as! SKSpriteNode
            if(invader.userData?.objectForKey("c") != nil){
                invader.physicsBody?.velocity = CGVectorMake(0, 0)
            }else{
                invader.physicsBody?.velocity = CGVectorMake(-40, 0)
            }
       let invaderObj = invader as! Invader
           // NSLog(String(invaderObj.gethit()))
            if(invaderObj.gethit() == 4){
              
                
     
         
                
                
                
            }

            if(invader.position.x < 0){
                //self.setupEnemy()
                self.playerDead = false
                invader.removeFromParent()
                let scene = GameOver(size: self.size, points: self.pointsLabel.text)
                let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
                self.view?.presentScene(scene, transition: transitionType)
                
               
            }
            
          
            //invader.position.x -= CGFloat(self.invaderSpeed)
    }
        
    
    }
    

    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.PlayerBullet != 0)){
                //secondBody.node?.removeFromParent()
                let waitToRemoveBullet = SKAction.waitForDuration(0.04)
                runAction(waitToRemoveBullet,completion:{
                    //self.physicsWorld.removeAllJoints()
                    secondBody.node?.removeFromParent()
                })
                
              NSLog("enemy hit by"+String(stringInterpolationSegment: secondBody.node?.name))
            // firstBody.node?.removeFromParent()
                
                runAction(SKAction.playSoundFileNamed("punch.wav", waitForCompletion: false))
                self.hits++
                NSLog(String(hits))
                if(hits == 1){
                    let contactPoint = contact.contactPoint
       
                    
                 
               if(firstBody.node?.name == "invader"){
                let sparkEmmiter = SKEmitterNode(fileNamed: "blood.sks")
                let invaderObj = firstBody.node as! Invader
                invaderObj.hit(invaderObj.gethit()+1)
                self.addChild(sparkEmmiter)
                sparkEmmiter.position.x = contactPoint.x
                sparkEmmiter.position.y = contactPoint.y
                if(secondBody.node?.name == "arrow"){
                    
                    let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                    self.physicsWorld.addJoint(myJoint)
                    secondBody.node?.runAction(SKAction.setTexture(SKTexture(imageNamed: "ArrowHitTexture")))
                    invaderObj.hit(UInt32(invaderObj.gethit()+2))
                    
                    
                }
                
                let waitToEnableFire = SKAction.waitForDuration(0.3)
                runAction(waitToEnableFire,completion:{
                    sparkEmmiter.removeFromParent()
                })
                    if(invaderObj.gethit() == 4){
                        firstBody.categoryBitMask = CollisionCategories.Player
                        let deadlabel = SKLabelNode(fontNamed: "COPPERPLATE")
                        deadlabel.fontColor = SKColor .yellowColor()
                        deadlabel.text = "+5";
                        self.points = self.points + 5
                        deadlabel.position.x = invaderObj.position.x
                        deadlabel.position.y = invaderObj.position.y + invaderObj.size.height/2
                        self.addChild(deadlabel)
                        // invader.removeFromParent()
                        
                        
                        
                        deadlabel.fontSize = 17
                        let fadein = SKAction.fadeInWithDuration(0.2)
                        let fadeout = SKAction.fadeOutWithDuration(0.3)
                        let wait = SKAction.waitForDuration(0.2)
                        let flash = SKAction.sequence([fadein,wait,fadeout])
                        
                        
                        deadlabel.runAction(flash,completion:{
                            deadlabel.removeFromParent()
                        })
                      
                        //animate
                        var playerTextures:[SKTexture] = []
                        for i in 0...14 {
                      
                            playerTextures.append(SKTexture(imageNamed: "deadsoldier\(i)"))
                        }
                        let playerAnimation = SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1)
                        //firstBody.node?.runAction(playerAnimation)
                       // let waitForDead = SKAction.waitForDuration(0.2)
                       // firstBody.node?.setScale(2.2)
                       firstBody.node?.runAction(playerAnimation,completion:{
                            firstBody.node?.removeFromParent()
                            // self.playerDead = true
                        })
                    }
                    }
                    if(firstBody.node?.name == "heavy"){
                        
                        let sparkEmmiter = SKEmitterNode(fileNamed: "spark.sks")
                        let invaderObj = firstBody.node as! Invader
                        invaderObj.hit(invaderObj.gethit()+1)
                        self.addChild(sparkEmmiter)
                        sparkEmmiter.position.x = contactPoint.x
                        sparkEmmiter.position.y = contactPoint.y
                        if(secondBody.node?.name == "arrow"){
                            
                            let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                            self.physicsWorld.addJoint(myJoint)
                            secondBody.node?.runAction(SKAction.setTexture(SKTexture(imageNamed: "ArrowHitTexture")))
                            invaderObj.hit(UInt32(invaderObj.gethit()+2))
                            
                            
                        }
                        
                        let waitToEnableFire = SKAction.waitForDuration(0.3)
                        runAction(waitToEnableFire,completion:{
                            sparkEmmiter.removeFromParent()
                        })
                        
                        if(invaderObj.gethit() == 10){
                           // firstBody.categoryBitMask = CollisionCategories.Player
                            let deadlabel = SKLabelNode(fontNamed: "COPPERPLATE")
                            deadlabel.fontColor = SKColor .yellowColor()
                            deadlabel.text = "+5";
                            self.points = self.points + 5
                            deadlabel.position.x = invaderObj.position.x
                            deadlabel.position.y = invaderObj.position.y + invaderObj.size.height/2
                            self.addChild(deadlabel)
                            // invader.removeFromParent()
                            
                            
                            
                            deadlabel.fontSize = 17
                            let fadein = SKAction.fadeInWithDuration(0.2)
                            let fadeout = SKAction.fadeOutWithDuration(0.3)
                            let wait = SKAction.waitForDuration(0.2)
                            let flash = SKAction.sequence([fadein,wait,fadeout])
                            
                            
                            deadlabel.runAction(flash,completion:{
                                deadlabel.removeFromParent()
                            })
                            
                            firstBody.node?.removeFromParent()
                         
                        }
                        
                        
                    }

              
                
       
                   // firstBody.node?.name = "dead"
                    let waitForDead = SKAction.waitForDuration(0.2)
                    self.runAction(waitForDead,completion:{
                        //firstBody.node?.removeFromParent()
                       // self.playerDead = true
                    })
   
                }
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.floor != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.ScenePiece != 0)) {
              //  NSLog("Bullet hit floor")
                let waitToEnableFire = SKAction.waitForDuration(0.3)
                runAction(waitToEnableFire,completion:{
                    secondBody.node?.removeFromParent()
                    //sparkEmmiter.removeFromParent()
                   // secondBody.node?.removeFromParent()
                })
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.ScenePiece != 0)) {
                if(secondBody.node?.name == "flamenode"){
                    firstBody.categoryBitMask = CollisionCategories.Player
                    let invaderObj = firstBody.node as! Invader
                    invaderObj.hit(invaderObj.gethit()+10)
               
                    var playerTextures:[SKTexture] = []
                    for i in 0...19 {
                    
                        playerTextures.append(SKTexture(imageNamed: "flamedeath\(i)"))
                    }
                    let playerAnimation = SKAction.animateWithTextures(playerTextures, timePerFrame: 0.05)
                    //firstBody.node?.runAction(playerAnimation)
                    // let waitForDead = SKAction.waitForDuration(0.2)
                    // firstBody.node?.setScale(2.2)
                    firstBody.node?.runAction(playerAnimation,completion:{
                        firstBody.node?.removeFromParent()
                        // self.playerDead = true
                    })
                
                
                
                
                
                
                
                
                }
                
                if(secondBody.node?.name == "spikes"){
                    //firstBody.node?.removeFromParent()
                    let invaderObj = firstBody.node as! Invader
                    invaderObj.hit(invaderObj.gethit()+10)
                    let contactPoint = contact.contactPoint
                    let sparkEmmiter = SKEmitterNode(fileNamed: "blood.sks")
                    NSLog(String(stringInterpolationSegment: firstBody.node?.children))
                    
                    
                    self.addChild(sparkEmmiter)
                    sparkEmmiter.position.x = contactPoint.x
                    sparkEmmiter.position.y = contactPoint.y
                 
                    
                    let waitToEnableFire = SKAction.waitForDuration(0.3)
                    runAction(waitToEnableFire,completion:{
                        sparkEmmiter.removeFromParent()
                        secondBody.node?.removeFromParent()
                    })
                }
                //NSLog("Invader and Player Collision Contact")
        }
        
    }

}

extension GameScene {
    func pause() {
        self.paused = true
        timer.advance(paused: true)
    }
    
    func unpause() {
        self.paused = false
        timer.advance(paused: false)
    }
}
