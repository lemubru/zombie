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
    let flameNode = ScenePiece(pieceName: "flamenode", textTureName: "floor", dynamic: false, scale: 0.6,x : 2,y: 2)
    let floor = SKSpriteNode(imageNamed: "floor")
    var weapon = 0
    var trap = 0
    var canFire = true
    var flamerOn = false
    var machineGunMode = false
    var enableTrapDoor = false
    var autoCrossBow = false
    var autoShottie = false
    var points = 0
    var shotgunround  = 0

    let timer = Timer() // the timer calculates the time step value dt for every frame
    let scheduler = Scheduler() // an event scheduler
    let scheduleHeavy = Scheduler() // an event scheduler
    let weaponLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.darkGrayColor()
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1000, height: 10), center: CGPoint(x:self.size.width/2,y:0))
        self.physicsBody?.dynamic = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = true
        self.physicsBody?.mass = 10000000
        self.physicsBody?.categoryBitMask = CollisionCategories.floor
        self.physicsBody?.contactTestBitMask = CollisionCategories.PlayerBullet | CollisionCategories.Invader | CollisionCategories.ScenePiece
        self.physicsBody?.collisionBitMask = CollisionCategories.PlayerBullet | CollisionCategories.Invader | CollisionCategories.ScenePiece
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
      let background = SKSpriteNode(imageNamed: "night")
       background.anchorPoint = CGPointMake(0, 1)
       background.position = CGPointMake(0, size.height)
      background.zPosition = 1
       background.size = CGSize(width: self.view!.bounds.size.width, height:self.view!.bounds.size.height)
       addChild(background)

        let rain = SKEmitterNode(fileNamed: "ash.sks")
        rain.position.x = self.size.width/2
        rain.position.y = self.size.height
        rain.zPosition = 2
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
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-64
        tempInvader.physicsBody?.velocity = CGVectorMake(-40, 0)
        tempInvader.physicsBody?.mass = 10000
        
    }
    
    func setupHeavyEnemy(){
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"heavy", name:"heavy")
        tempInvader.zPosition = 9
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-54
        tempInvader.physicsBody?.velocity = CGVectorMake(-20, 0)
        tempInvader.physicsBody?.mass = 10000
        
    }
    
    func startSchedulers(){
        scheduleHeavy.every(5.5).perform(self=>GameScene.setupHeavyEnemy)
        scheduleHeavy.start()
        scheduler.every(2.0).perform(self=>GameScene.setupEnemy)
        let wait = SKAction.waitForDuration(10)
        let startnormal  = SKAction.runBlock(){
            self.scheduler.start()
            self.scheduleHeavy.stop()
        }
        let startHeavy  = SKAction.runBlock(){
            self.scheduler.stop()
            self.scheduleHeavy.every(5.5).perform(self=>GameScene.setupHeavyEnemy)
            self.scheduleHeavy.start()
            
           
        }
        self.runAction(SKAction.sequence([wait,startnormal]))
        //scheduler.start()
        

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
        nextWeaponButton.zPosition = 2
        self.addChild(nextWeaponButton)
        // nextWeaponButton.AddPhysics(self, dynamic: false)
        
        let trapButton = ScenePiece(pieceName: "trapbtn", textTureName: "trapbtn", dynamic: false, scale: 0.4,x : self.size.width - 300,y: self.size.height - 20)
        self.addChild(trapButton)
        trapButton.zPosition = 2
        let nextTrapButton = ScenePiece(pieceName: "nexttrap", textTureName: "nxttrapbtn", dynamic: false, scale: 0.4,x : self.size.width - 250,y: self.size.height - 20)
        nextTrapButton.zPosition = 2
        self.addChild(nextTrapButton)
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        let touch = touches.first as! UITouch
        touching = true
        var weaponCap  = 7 //meaning 6 weapons - it starts at 1
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
                autoShottie = false
               
               
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
                flameEmmiter.zPosition = 3
                
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
            if(weapon == 6){
                weaponLabel.text = "auto-crossbow"
                machineGunMode = false
                autoCrossBow = true
            }
            if(weapon == 7){
                weaponLabel.text = "auto-shotgun"
                autoCrossBow = false
                autoShottie = true
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
                var bulletScale = 0.05
                speedMultiplier = CGFloat(0.001)
                bulletSound = "shotgunsound.mp3"
                canFireWait = 2
                multiShot = true
            }
            if(!flamerOn && !machineGunMode && !autoCrossBow && !autoShottie){
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
         floor.position = CGPointMake(size.width/2,size.height/2 - 160)
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
            self.fireMachineGun("machinegun.wav", scale: 0.4, bulletTexture: "ball", bulletName: "ball", speedMulti: 0.001, multiShot: false,canFireWait: 0.2)
        }
        if(autoCrossBow){
            self.fireMachineGun("arrowfire.mp3", scale: 0.3, bulletTexture: "ArrowTexture", bulletName: "arrow", speedMulti: 0.003, multiShot: false, canFireWait: 0.2)
        }
        if(autoShottie){
         
            self.fireMachineGun("shotgunsound.mp3", scale: 0.2, bulletTexture: "ball", bulletName: "ball", speedMulti: 0.001, multiShot: true, canFireWait: 0.7)

        }
    }
    
    func fireMachineGun(sound: String, scale: CGFloat, bulletTexture: String, bulletName: String,speedMulti: CGFloat,multiShot: Bool,canFireWait: Double){
        if(touching){
            var bulletName = bulletName
            var bulletTexture = bulletTexture
            var bulletScale = scale
            var speedMultiplier = speedMulti
            var bulletSound = sound
            var canFireWait = canFireWait
            var multiShot = multiShot
            player.fireBullet(self, touchX:touchx, touchY:touchy, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName)
        }
        
    }
    
     func swingingSpikeBall(){
        
        let anchor = ScenePiece(pieceName: "rock", textTureName: "saw3", dynamic: true, scale: 0.2,x : self.size.width/2,y: self.size.height + 40)
        
        anchor.AddPhysics(self, dynamic: false)
        
        
        let rock1 = ScenePiece(pieceName: "spikeball", textTureName: "spikeball", dynamic: true, scale: 0.4,x : 30,y: self.size.height - 40)
        rock1.AddPhysics(self, dynamic: true)
        rock1.zRotation = rock1.zRotation - 180 * DegreesToRadians
        
        let myJoint = SKPhysicsJointLimit.jointWithBodyA(anchor.physicsBody, bodyB: rock1.physicsBody, anchorA: anchor.position, anchorB: rock1.position)
        self.physicsWorld.addJoint(myJoint)
        
    }
    
    
    func spikeFall(){
      
        var scale = CGFloat(randRange(2, upper: 7))
        let floatScale = CGFloat(scale/10)
        
         let rock1 = ScenePiece(pieceName: "rocks", textTureName: "rock1", dynamic: true, scale: randRangeFrac(4, upper: 8),x : CGFloat( randRange(30, upper: 400)),y: self.size.height - 40)
        rock1.zPosition = 10
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
    

    

    

    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    func randRangeFrac (lower: UInt32 , upper: UInt32) -> CGFloat {
        var scale = CGFloat(randRange(lower, upper: upper))
        return CGFloat(scale/10)
    }
    


    

   
    
    func moveInvaders(){
        enumerateChildNodesWithName("invader") { node, stop in
            self.invaders++
           // NSLog(String(self.invaders))
            
            let invader = node as! SKSpriteNode

            if(invader.position.x < 0){
                //self.setupEnemy()
                self.playerDead = false
                invader.removeFromParent()
                self.gameOver()
                
               
            }
    }
        
    
    }
    func gameOver(){
        let scene = GameOver(size: self.size, points: self.pointsLabel.text)
        let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
        self.view?.presentScene(scene, transition: transitionType)
        
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
                  if(secondBody.node?.name == "arrow"){
                let waitToRemoveBullet = SKAction.waitForDuration(2)
                runAction(waitToRemoveBullet,completion:{
                    //self.physicsWorld.removeAllJoints()
                    secondBody.node?.removeFromParent()
                })
                  }else{
                    let waitToRemoveBullet = SKAction.waitForDuration(0.02)
                    runAction(waitToRemoveBullet,completion:{
                        //self.physicsWorld.removeAllJoints()
                        secondBody.node?.removeFromParent()
                    })
                    
                }
                
             // NSLog("enemy hit by"+String(stringInterpolationSegment: secondBody.node?.name))
            // firstBody.node?.removeFromParent()
                
              
                self.hits++
                NSLog(String(hits))
                if(hits == 1){
                    let contactPoint = contact.contactPoint
       
                    
                 
               if(firstBody.node?.name == "invader"){
                  runAction(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
                let sparkEmmiter = SKEmitterNode(fileNamed: "blood.sks")
                let invaderObj = firstBody.node as! Invader
                let bullet = secondBody.node as! PlayerBullet
                invaderObj.hit(invaderObj.gethit()+1)
                sparkEmmiter.zPosition = 3
                self.addChild(sparkEmmiter)
                sparkEmmiter.position.x = contactPoint.x - 10
                sparkEmmiter.position.y = contactPoint.y
              
                if(secondBody.node?.name == "arrow"){
   
                    let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                    self.physicsWorld.addJoint(myJoint)
                    if(contactPoint.y > invaderObj.position.y){
                         invaderObj.hit(invaderObj.gethit()+6)
                    }
                    bullet.texture = SKTexture(imageNamed: "ArrowHitTexture")
                   
                }
                
                let waitToEnableFire = SKAction.waitForDuration(0.3)
                runAction(waitToEnableFire,completion:{
                    sparkEmmiter.removeFromParent()
                })
                    if(invaderObj.gethit() > 5){
                        firstBody.categoryBitMask = CollisionCategories.Player
                        let deadlabel = SKLabelNode(fontNamed: "COPPERPLATE")
                        deadlabel.fontColor = SKColor .yellowColor()
                        deadlabel.text = "+5";
                        self.points = self.points + 5
                        deadlabel.position.x = invaderObj.position.x
                        deadlabel.position.y = invaderObj.position.y + invaderObj.size.height*0.25
                        deadlabel.zPosition = 10
                        deadlabel.fontSize = 17
                        self.addChild(deadlabel)
                        
                        let fadein = SKAction.fadeInWithDuration(0.2)
                        let fadeout = SKAction.fadeOutWithDuration(0.3)
                        let wait = SKAction.waitForDuration(0.2)
                        let flash = SKAction.sequence([fadein,wait,fadeout])
                        
                        
                        deadlabel.runAction(flash,completion:{
                            deadlabel.removeFromParent()
                        })
                      
                        //animate
                        //var playerTextures:[SKTexture] = []
                        //for i in 0...14 {
                      
                          //  playerTextures.append(SKTexture(imageNamed: "deadsoldier\(i)"))
                       // }
                        //let playerAnimation = SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1)
                        //firstBody.node?.runAction(playerAnimation)
                       // let waitForDead = SKAction.waitForDuration(0.2)
                       // firstBody.node?.setScale(2.2)
                        let setHidden = SKAction.runBlock(){
                            firstBody.node?.hidden = true
                        }
                        let setVisible = SKAction.runBlock(){
                            firstBody.node?.hidden = false
                        }
                        let waitAbit = SKAction.waitForDuration(0.06)
                        let seq = SKAction.sequence([setHidden,waitAbit,setVisible,waitAbit,setHidden,waitAbit,setVisible,waitAbit])
                       firstBody.node?.runAction(seq,completion:{
                            firstBody.node?.removeFromParent()
                            // self.playerDead = true
                        })
                    }
                    }
                    if(firstBody.node?.name == "heavy"){
                          runAction(SKAction.playSoundFileNamed("punch.wav", waitForCompletion: false))
                        
                        let sparkEmmiter = SKEmitterNode(fileNamed: "spark.sks")
                        let invaderObj = firstBody.node as! Invader
                        invaderObj.hit(invaderObj.gethit()+1)
                        sparkEmmiter.zPosition = 3
                        self.addChild(sparkEmmiter)
                        sparkEmmiter.position.x = contactPoint.x
                        sparkEmmiter.position.y = contactPoint.y
               
                        
                        let waitToEnableFire = SKAction.waitForDuration(0.3)
                        runAction(waitToEnableFire,completion:{
                            sparkEmmiter.removeFromParent()
                        })
                        
                        if(invaderObj.gethit() == 10){
                            
                            let deadlabel = SKLabelNode(fontNamed: "COPPERPLATE")
                            deadlabel.fontColor = SKColor .yellowColor()
                            deadlabel.text = "+10";
                            self.points = self.points + 10
                            deadlabel.position.x = invaderObj.position.x
                            deadlabel.position.y = invaderObj.position.y + invaderObj.size.height*0.25
                            deadlabel.zPosition = 10
                            self.addChild(deadlabel)
                            // invader.removeFromParent()
                            
                            
                            
                            deadlabel.fontSize = 17
                            let fadein = SKAction.fadeInWithDuration(0.1)
                            let fadeout = SKAction.fadeOutWithDuration(0.3)
                            let wait = SKAction.waitForDuration(0.1)
                            let flash = SKAction.sequence([fadein,wait,fadeout])
                            
                            
                            deadlabel.runAction(flash,completion:{
                                deadlabel.removeFromParent()
                            })
                            
                            let setHidden = SKAction.runBlock(){
                                firstBody.node?.hidden = true
                            }
                            let setVisible = SKAction.runBlock(){
                                firstBody.node?.hidden = false
                            }
                            let waitAbit = SKAction.waitForDuration(0.07)
                            let seq = SKAction.sequence([setHidden,waitAbit,setVisible,waitAbit,setHidden,waitAbit,setVisible,waitAbit])
                            firstBody.node?.runAction(seq,completion:{
                                firstBody.node?.removeFromParent()
                                // self.playerDead = true
                            })
                         
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
                
                if(secondBody.node?.name == "rocks"){
                    runAction(SKAction.playSoundFileNamed("smash.wav", waitForCompletion: false))
                    //firstBody.node?.removeFromParent()
                    let contactPoint = contact.contactPoint
                    let sparkEmmiter = SKEmitterNode(fileNamed: "blood.sks")
                  //  NSLog(String(stringInterpolationSegment: firstBody.node?.children))
                    self.addChild(sparkEmmiter)
                    sparkEmmiter.position.x = contactPoint.x
                    sparkEmmiter.position.y = contactPoint.y
                    firstBody.node?.removeFromParent()
                    
                    let waitToEnableFire = SKAction.waitForDuration(0.3)
                    runAction(waitToEnableFire,completion:{
                        sparkEmmiter.removeFromParent()
                       // secondBody.node?.removeFromParent()
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
