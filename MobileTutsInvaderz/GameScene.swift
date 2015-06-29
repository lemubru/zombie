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
    static let EnemyBullet: UInt32 = 0x1 << 2
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
    let player:Player = Player(name: "player")
    let turret:Player = Player(name: "turret")
    let flameEmmiter = SKEmitterNode(fileNamed: "flamer.sks")
    let flameNode = ScenePiece(pieceName: "flamenode", textTureName: "floor", dynamic: false, scale: 0.6,x : 2,y: 2)
    var weapon = 0
    var trap = 0
    var canFire = true
    var flamerOn = false
    var machineGunMode = false
    var enableTrapDoor = false
    var autoCrossBow = false
    var autoShottie = false
    var points = UInt32(0)
    var shotgunround  = 0
    var placeTurretMode = false
    var placeMudMode = false
    var numTurrets = 0
    let invaderLife = UInt32(6)
    var EnemyFreq = Double(3)

    let timer = Timer() // the timer calculates the time step value dt for every frame
    let scheduler = Scheduler() // an event scheduler
    let scheduleHeavy = Scheduler() // an event scheduler
    let weaponLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let levelLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let trapLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    var level = UInt32(0)
    var text = ""
    var movingR = false
    var movingL = false
    //Flying enemy
    //shooting enemy
    //
    
    init(size: CGSize, points: UInt32, ef: Double, level: UInt32){
        text = String(points)
        super.init(size: size)
        self.points = points
        self.EnemyFreq = ef
        self.level = level
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.darkGrayColor()
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1000, height: 10), center: CGPoint(x:self.size.width/2,y:40))
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
        
        
        //turret.position.x = -self.size.width/2+300
        //turret.position.y = self.size.height*0.75
        loadHud()
        startSchedulers()
    }
    
    func loadBG(){
        let background = SKSpriteNode(imageNamed: "night")
        background.name = "BG"
        background.anchorPoint = CGPointMake(0, 1)
        background.position = CGPointMake(0, size.height)
        background.zPosition = 1
        background.size = CGSize(width: self.view!.bounds.size.width, height:self.view!.bounds.size.height)
        addChild(background)
        let rain = SKEmitterNode(fileNamed: "ash.sks")
        rain.position.x = self.size.width/2
        rain.position.y = self.size.height
        rain.zPosition = 2
       // self.addChild(rain)
    }
    
    func setupPlayer(){
        player.position.x = -self.size.width/2+300
        player.position.y = self.size.height*0.8
        player.zPosition = 7
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.dynamic = false
        player.physicsBody?.categoryBitMask = CollisionCategories.Player
        player.physicsBody?.contactTestBitMask = CollisionCategories.EnemyBullet
        player.physicsBody?.collisionBitMask =  CollisionCategories.EnemyBullet
        addChild(player)
    }
    
    func setupTurret(x: CGFloat,y: CGFloat){
        let turret:Ally = Ally(scene: self,name: "turret",x: x,y: y)
        turret.zPosition = 20
    }
    
    func placeMud(x: CGFloat,y: CGFloat){
        let mud = ScenePiece(pieceName: "mud", textTureName: "floor", dynamic: false, scale: 0.1,x : 2,y: 2)
        mud.hidden = true
        mud.position.x = x
        mud.position.y = y
        mud.AddPhysics(self, dynamic: false)
        mud.zPosition = 3
    }
    
    func setupEnemy(){
        var random = randRange(0, upper: 2)
        NSLog(String(random))
        var gunner = false
        if(random == 0){
            gunner = true
        }
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"soldierrun", name:"invader", gunner: gunner)
        tempInvader.zPosition = 6
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-74
        tempInvader.physicsBody?.velocity = CGVectorMake(-40, 0)
        tempInvader.physicsBody?.mass = 10000
        tempInvader.physicsBody?.affectedByGravity = false
        
    }
    
    func setupHeavyEnemy(){
        let invaderFrame = SKNode()
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"heavy", name:"heavy", gunner: true)
        tempInvader.zPosition = 9
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-74
        tempInvader.physicsBody?.velocity = CGVectorMake(-20, 0)
        tempInvader.physicsBody?.mass = 10000
        tempInvader.physicsBody?.affectedByGravity = false
        
    }
    
    func startSchedulers(){
    
        let wait1 = SKAction.waitForDuration(2, withRange: 1)
        let wait2 = SKAction.waitForDuration(3, withRange: 1)
         let longwait = SKAction.waitForDuration(30)
        let spawnNormal = SKAction.runBlock(){
            self.setupEnemy()
        }
        let spawnHeavy = SKAction.runBlock(){
            self.setupHeavyEnemy()
        }
        let spawnAndWait = SKAction.sequence([spawnNormal,wait1])
        let spawnAndWaitHeavy = SKAction.sequence([spawnHeavy,wait2])
        self.runAction(SKAction.repeatActionForever(spawnAndWait), withKey:"spawnandwait")
        
       
        
       self.runAction(longwait,completion:{
         self.removeActionForKey("spawnandwait")
        self.runAction(SKAction.repeatActionForever(spawnAndWaitHeavy), withKey:"spawnandwaitheavy")
        self.runAction(longwait,completion:{
            self.removeActionForKey("spawnandwaitheavy")
            
            // self.playerDead = true
        })
            // self.playerDead = true
        })
     
       

    }
    func loadHud(){
        levelLabel.text = "level: " + String(level)
        levelLabel.position.x = self.size.width*0.6
        levelLabel.position.y = self.size.height*0.9
        levelLabel.zPosition = 2
        levelLabel.fontSize = 17
        
        
        
        weaponLabel.text = "pistol";
        weaponLabel.position.x = self.size.width*0.99
        weaponLabel.position.y = self.size.height - 55
        weaponLabel.zPosition = 2
        weaponLabel.fontSize = 17
        weaponLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        trapLabel.text = "rock fall";
        trapLabel.position.x = self.size.width*0.59
        trapLabel.position.y = self.size.height - 55
        trapLabel.zPosition = 2
        trapLabel.fontSize = 17
        trapLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        pointsLabel.text = String(points)
        pointsLabel.position = CGPoint(x: 7,y: 5)
        pointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        pointsLabel.fontSize = 30
        pointsLabel.zPosition = 3
        self.addChild(pointsLabel)
        self.addChild(trapLabel)
        self.addChild(weaponLabel)
        self.addChild(levelLabel)
        
        
        
        let dock = ScenePiece(pieceName: "dock", textTureName: "dock.png", dynamic: false, scale: 1, x: 10, y: self.size.height - 20)
        dock.zPosition = 18
        self.addChild(dock)
        
        let grass = ScenePiece(pieceName: "grass", textTureName: "grass2.png", dynamic: false, scale: 1, x: self.size.width/2, y:20)
        grass.zPosition = 20
        self.addChild(grass)
        
        let nextWeaponButton = ScenePiece(pieceName: "nwbutton", textTureName: "nwbutton", dynamic: false, scale: 0.4,x : self.size.width - 20,y: self.size.height - 20)
        nextWeaponButton.zPosition = 14
        self.addChild(nextWeaponButton)
        // nextWeaponButton.AddPhysics(self, dynamic: false)
        
        let trapButton = ScenePiece(pieceName: "trapbtn", textTureName: "trapbtn", dynamic: false, scale: 0.4,x : self.size.width - 300,y: self.size.height - 20)
        self.addChild(trapButton)
        trapButton.zPosition = 14
        let nextTrapButton = ScenePiece(pieceName: "nexttrap", textTureName: "nxttrapbtn", dynamic: false, scale: 0.4,x : self.size.width - 250,y: self.size.height - 20)
        nextTrapButton.zPosition = 14
        self.addChild(nextTrapButton)
        
        let moveR = ScenePiece(pieceName: "moveR", textTureName: "movebtn", dynamic: false, scale: 1,x : 100,y:  20)
        moveR.zPosition = 2
        //self.addChild(moveR)
        
        
        let moveL = ScenePiece(pieceName: "moveL", textTureName: "movebtn", dynamic: false, scale: 1,x : 20,y:  20)
        moveL.zPosition = 2
        //self.addChild(moveL)
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        let touch = touches.first as! UITouch
        touching = true
        var turretLimit = 4
        var weaponCap  = 7 //meaning +1 weapons - it starts at 1
        var trapCap = 3 //meaning +1 traps
        let touchLocation = touch.locationInNode(self)
        touchx = touchLocation.x
        touchy = touchLocation.y
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        //NSLog(touchedNode.name!)
        if(placeMudMode){
            trapLabel.text = "mud placed!";
            placeMud(touchx, y: touchy)
            placeMudMode  = false
        }else
        
        if(placeTurretMode && touchedNode.name == "dock"){
            trapLabel.text = "turret placed!";
            setupTurret(touchx, y: touchy)
            placeTurretMode = false
            numTurrets++
        }else if(touchedNode.name == "turret"){
            let turret = touchedNode as! Ally
            turret.removeFromParent()
            turret.removeTurRad()
            
        }else
        if(touchedNode.name == "nexttrap"){
            trap++
            
            if(trap == 3){
                placeTurretMode = false
               
             
                trapLabel.text = "press T to place mud";
                enumerateChildNodesWithName("flash") { node, stop in
                    
                    node.removeFromParent()
                }
                flashText("info: place mud on floor", x: self.size.width*0.2, y: 10, z: 6, waitDur: 3)
            }
            if(trap == 2){
               
                if(numTurrets < turretLimit){
                     trapLabel.text = "press T to place turret";
                    enumerateChildNodesWithName("flash") { node, stop in
                    
                            node.removeFromParent()
                        }
                    flashText("info: place turret on dock upper left corner", x: self.size.width*0.2, y: 10, z: 6, waitDur: 3)
                    
                    
                }else{
                    trapLabel.text = "turret Limit:" + String(turretLimit);
                }
              
              
            }
            if(trap == 1){
                trapLabel.text = "deathswing";
            }
        
          
            if(trap > trapCap){
                enumerateChildNodesWithName("flash") { node, stop in
                    
                    node.removeFromParent()
                }
                placeMudMode = false
                trapLabel.text = "rock fall";
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
           // NSLog("buttonpressed"+String(weapon))
        }else if(touchedNode.name == "trapbtn"){
            enableTrapDoor = true
            if(trap == 0){
                spikeFall()
            }else if(trap == 1){
                swingingSpikeBall()
            }else if(trap == 2){
                if(numTurrets < turretLimit){
                    trapLabel.text = "touch to place";
                    placeTurretMode = true
                    
                    
                }else{
                    trapLabel.text = "turret Limit:" + String(turretLimit);
                }
                
            }else if(trap == 3){
                trapLabel.text = "touch to place";
                placeMudMode = true
               
                
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
        
         if(touchedNode.name == "moveR"){
           // movingR = true
           // movingL = false
        }else if(touchedNode.name == "moveL"){
            //movingR = false
            //movingL = true
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        touching = true
        var weaponCap  = 4
        let touchLocation = touch.locationInNode(self)
        touchx = touchLocation.x
        touchy = touchLocation.y
    
        let touchedNode = self.nodeAtPoint(touchLocation)
        
        if(touchedNode.name == "moveR"){
          //  movingR = true
           // movingL = false
        }else if(touchedNode.name == "moveL"){
           // movingR = false
           // movingL = true
        }
        
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        touching = false
        movingR = false
        movingL = false
        
    }
    
    override func update(currentTime: CFTimeInterval) {

        
        pointsLabel.text = String(points)
        hits = 0
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
    
    func fireTurret(sound: String, scale: CGFloat, bulletTexture: String, bulletName: String,speedMulti: CGFloat,multiShot: Bool,canFireWait: Double, enemyx: CGFloat, enemyy: CGFloat){
        enumerateChildNodesWithName("turret") { node, stop in
            let turret = node as! Ally
            var bulletName = bulletName
            var bulletTexture = bulletTexture
            var bulletScale = scale
            var speedMultiplier = speedMulti
            var bulletSound = sound
            var canFireWait = canFireWait
            var multiShot = multiShot
            turret.fireBullet(self, touchX:enemyx, touchY:enemyy, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName)
        }
        
    }
    
     func swingingSpikeBall(){
        
        let anchor = ScenePiece(pieceName: "rock", textTureName: "saw3", dynamic: true, scale: 0.2,x : self.size.width*0.5,y: self.size.height + 20)
        
        anchor.AddPhysics(self, dynamic: false)
        
        
        let rock1 = ScenePiece(pieceName: "saw", textTureName: "saw3", dynamic: true, scale: 1,x : 0,y: self.size.height)
        rock1.AddPhysics(self, dynamic: true)
        rock1.physicsBody?.angularVelocity = 23
        rock1.zPosition = 13
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
            let invader = node as! Invader
            if(invader.getLock()){
                self.fireTurret("machinegun.wav", scale: 0.4, bulletTexture: "ball", bulletName: "playerbullet", speedMulti: 0.001, multiShot: false,canFireWait: 0.4, enemyx: invader.position.x - CGFloat(self.randRange(0, upper: 10)), enemyy: invader.position.y + CGFloat(self.randRange(0, upper: 80)))
            }
            if(invader.isGunner()){
           // invader.fireBullet(self, touchX: self.player.position.x, touchY: self.player.position.y + CGFloat(self.randRange(0, upper: 80)), bulletTexture: "ball", bulletScale: 0.5, speedMultiplier: CGFloat(0.002), bulletSound: "gunshot.mp3", canFireWait: 2, multiShot: false, bulletName: "invaderbullet")
            }
            if(self.movingL){
                self.player.position.x--
            }else if(self.movingR){
                 self.player.position.x++
            }
  
            
            if(self.points % 50 == 0 && self.points != 0){
                self.points++
               self.gameOver()
            }
           
            }
        // self.removeBullets()
  
        }
    
   
    
    override func didSimulatePhysics() {
        enumerateChildNodesWithName("invaderbullet") { node, stop in
            let bullet = node as! EnemyBullet
            if(bullet.position.y > self.size.height - 100 || bullet.position.y < 0 + 30 || bullet.position.x > self.size.width + 100){
                bullet.removeFromParent()
            }
            
        }
          enumerateChildNodesWithName("invader") { node, stop in
            let invader = node as! Invader
            if(invader.position.x < 5){
                //self.setupEnemy()
                self.playerDead = false
                invader.removeFromParent()
                // self.gameOver()
            }
            
        }
        
    
    }
    func flashText(text: String, x: CGFloat,y: CGFloat, z: CGFloat, waitDur: Double){
        let tempL = SKLabelNode(fontNamed: "COPPERPLATE")
        tempL.fontColor = SKColor .whiteColor()
        tempL.text = text;
        tempL.name = "flash"
        tempL.position.x = x
        tempL.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        tempL.position.y = y
        tempL.zPosition = z
        tempL.fontSize = 14
        self.addChild(tempL)
        let fadein = SKAction.fadeInWithDuration(0.1)
        let fadeout = SKAction.fadeOutWithDuration(0.4)
        let wait = SKAction.waitForDuration(waitDur)
        let flash = SKAction.sequence([fadein,wait,fadeout])
     
        
        tempL.runAction(flash,withKey:"flash")
        self.runAction(SKAction.waitForDuration(8),completion:{
            tempL.removeFromParent()
        })
       
      
        
    }
    

    func gameOver(){
        let scene = GameOver(size: self.size, points: self.points,ef: EnemyFreq, level: self.level)
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
              
                self.hits++
            
                if(hits == 1){
                    let contactPoint = contact.contactPoint
       
                    
                 
               if(firstBody.node?.name == "invader"){
                let sparkEmmiter = SKEmitterNode(fileNamed: "blood.sks")
                sparkEmmiter.zPosition = 14
                sparkEmmiter.position.x = contactPoint.x - 10
                sparkEmmiter.position.y = contactPoint.y
                self.addChild(sparkEmmiter)
                runAction(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
                let invaderObj = firstBody.node as! Invader
                let bullet = secondBody.node as! PlayerBullet
                invaderObj.hit(invaderObj.gethit()+2)
                let waitToEnableFire = SKAction.waitForDuration(0.2)
                runAction(waitToEnableFire,completion:{
                    sparkEmmiter.removeFromParent()
                })
                if(secondBody.node?.name == "arrow"){
   
                    let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                    self.physicsWorld.addJoint(myJoint)
                    if(contactPoint.y > invaderObj.position.y){
                        
                    }
                    bullet.texture = SKTexture(imageNamed: "ArrowHitTexture")
                   
                }
                
                if(contactPoint.y > invaderObj.position.y){
                    let deadlabel = SKLabelNode(fontNamed: "COPPERPLATE")
                    deadlabel.fontColor = SKColor .lightGrayColor()
                     invaderObj.hit(invaderObj.gethit()+2)
                    deadlabel.text = "headshot!";
                    self.points = self.points + 1
                    deadlabel.position.x = invaderObj.position.x
                    deadlabel.position.y = invaderObj.position.y + invaderObj.size.height*0.5
                    deadlabel.zPosition = 10
                    deadlabel.fontSize = 14
                    self.addChild(deadlabel)
                    let fadein = SKAction.fadeInWithDuration(0.1)
                    let fadeout = SKAction.fadeOutWithDuration(0.2)
                    let wait = SKAction.waitForDuration(0.1)
                    let flash = SKAction.sequence([fadein,wait,fadeout])
                    
                    
                    deadlabel.runAction(flash,completion:{
                        deadlabel.removeFromParent()
                    })
                    
                }
                
               
                    if(invaderObj.gethit() > self.invaderLife){
                        firstBody.categoryBitMask = CollisionCategories.Player
                        let deadlabel = SKLabelNode(fontNamed: "COPPERPLATE")
                        deadlabel.fontColor = SKColor .yellowColor()
                        deadlabel.text = "+5";
                        self.points = self.points + 1
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
                        
                          if(invaderObj.gethit() == 5){
                            
                            let smoke = SKEmitterNode(fileNamed: "smoke")
                         
                            smoke.zPosition = 3
                            firstBody.node?.addChild(smoke)
                           // smoke.position.y = parent!.position.y + 20
                           // smoke.targetNode = self.scene
                          
                            
                         
                            
                        }
               
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
                            firstBody.node?.removeAllChildren()
                            
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
                
                let contactPoint = contact.contactPoint
                let sparkEmmiter = SKEmitterNode(fileNamed: "dirt.sks")
                
                sparkEmmiter.zPosition = 3
                self.addChild(sparkEmmiter)
                sparkEmmiter.position.x = contactPoint.x
                sparkEmmiter.position.y = contactPoint.y
                
                
                let wait = SKAction.waitForDuration(1)
                runAction(wait,completion:{
                    sparkEmmiter.removeFromParent()
                })
                
                let waitToEnableFire = SKAction.waitForDuration(0.3)
                runAction(waitToEnableFire,completion:{
                    secondBody.node?.removeFromParent()
                    //sparkEmmiter.removeFromParent()
                   // secondBody.node?.removeFromParent()
                })
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Player != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Invader != 0)) {
                firstBody.node?.removeFromParent()
                
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.PlayerBullet != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.floor != 0)) {
                //  NSLog("Bullet hit floor")
                
                let contactPoint = contact.contactPoint
                let sparkEmmiter = SKEmitterNode(fileNamed: "dirt.sks")
              
                sparkEmmiter.zPosition = 3
                self.addChild(sparkEmmiter)
                sparkEmmiter.position.x = contactPoint.x
                sparkEmmiter.position.y = contactPoint.y+7
                
                
                let waitToEnableFire = SKAction.waitForDuration(0.2)
                runAction(waitToEnableFire,completion:{
                    sparkEmmiter.removeFromParent()
                })
                
                if(firstBody.node?.name == "arrow"){
                    firstBody.categoryBitMask = CollisionCategories.Player
                     firstBody.contactTestBitMask = CollisionCategories.Invader
                    let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                    self.physicsWorld.addJoint(myJoint)
                    let waitToEnableFire = SKAction.waitForDuration(2)
                    runAction(waitToEnableFire,completion:{
                        firstBody.node?.removeFromParent()
                    })
                }else{
                    let waitToEnableFire = SKAction.waitForDuration(0.01)
                    runAction(waitToEnableFire,completion:{
                        firstBody.node?.removeFromParent()
                    })
                }
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.ScenePiece != 0)) {
                if(secondBody.node?.name == "flamenode"){
                  
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
                
                
                if(secondBody.node?.name == "turretRad"){
                    let invaderObj = firstBody.node as! Invader
                    invaderObj.setLocked()
                }
                
                if(secondBody.node?.name == "mud"){
                    let invaderObj = firstBody.node as! Invader
                    invaderObj.physicsBody?.velocity = CGVectorMake(-20, 0)
                    secondBody.node?.removeFromParent()
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
                
                if(secondBody.node?.name == "saw"){
                    runAction(SKAction.playSoundFileNamed("slice.mp3", waitForCompletion: false))
                    let contactPoint = contact.contactPoint
                    let sparkEmmiter = SKEmitterNode(fileNamed: "heavyblood.sks")
                    sparkEmmiter.zPosition = 14
                    //  NSLog(String(stringInterpolationSegment: firstBody.node?.children))
                    self.addChild(sparkEmmiter)
                    sparkEmmiter.position.x = contactPoint.x
                    sparkEmmiter.position.y = contactPoint.y
                    
                    //animate
                    var playerTextures:[SKTexture] = []
                    for i in 0...14 {
                    
                      playerTextures.append(SKTexture(imageNamed: "deadsoldier\(i)"))
                     }
                    let playerAnimation = SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1)
                    firstBody.node?.runAction(playerAnimation, completion:{
                      firstBody.node?.removeFromParent()
                    })
                  
                    
                    let waitToEnableFire = SKAction.waitForDuration(0.3)
                    runAction(waitToEnableFire,completion:{
                        sparkEmmiter.removeFromParent()
                        // secondBody.node?.removeFromParent()
                    })
                   // self.physicsWorld.removeJoint(joint:)
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
