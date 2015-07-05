//
//  GameScene.swift
//  MobileTutsInvaderz
//
//  Created by James Tyner on 2/11/15.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import SpriteKit
import AVFoundation
var invaderNum = 1
struct CollisionCategories{
    static let Invader : UInt32 = 0x1 << 0
    static let Player: UInt32 = 0x1 << 1
    static let EnemyBullet: UInt32 = 0x1 << 2
    static let PlayerBullet: UInt32 = 0x1 << 3
    static let floor: UInt32 = 0x1 << 4
    static let ScenePiece: UInt32 = 0x1 << 5
    static let Gfield: UInt32 = 0x1 << 6
    static let Ally: UInt32 = 0x1 << 7
}
let Pi = CGFloat(M_PI)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi
class GameScene: SKScene ,SKPhysicsContactDelegate{
    
    var coinSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("BGmusic", ofType: "mp3")!)
    var Disson = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Dissonance", ofType: "mp3")!)
    var ocean = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ocean", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    
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
    var rocksFell = 0
    
    
    let weaponLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let levelLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let trapLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    var level = UInt32(0)
    var text = ""
    var movingR = false
    var movingL = false
    let mainatlas = SKTextureAtlas(named: "images")
    let soldieratlas = SKTextureAtlas(named: "soldierrun")
    var numEnemyInWave = 7
    var weaponCap = 0
    //Flying enemy
    var musicoff = false
    //shooting enemy
    //
    
    init(size: CGSize, points: UInt32, ef: Double, level: UInt32, numEnemy: Int, weaponCap: Int){
        text = String(points)
        super.init(size: size)
        self.points = points
        self.EnemyFreq = ef
        self.level = level
        self.numEnemyInWave = numEnemy
        self.weaponCap  = weaponCap
        if(self.weaponCap > 8){
            self.weaponCap = 8
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        audioPlayer = AVAudioPlayer(contentsOfURL: ocean, error: nil)
       // audioPlayer.prepareToPlay()
       // audioPlayer.play()
        
        createPhysicsWorld()
        createFloor()
        loadBG()
        weapon = 0
        trap = 0
        setupPlayer()
        loadHud()
        soldieratlas.preloadWithCompletionHandler { () -> Void in
            self.startSchedulers1()
        }
        mainatlas.preloadWithCompletionHandler { () -> Void in
            
        }
    }
    
    func createFloor(){
        
        let grass = ScenePiece(pieceName: "grass", textTureName: "grass2.png", dynamic: false, scale: 1, x: self.size.width/2, y:20)
        grass.zPosition = 20
        self.addChild(grass)
        
        grass.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1000, height: 10), center: CGPoint(x:0,y:grass.position.y-5))
        grass.physicsBody?.dynamic = false
        grass.physicsBody?.allowsRotation = false
        //grass.physicsBody?.pinned = true
        
        grass.physicsBody?.mass = 10000000
        grass.physicsBody?.categoryBitMask = CollisionCategories.floor
        grass.physicsBody?.contactTestBitMask = CollisionCategories.PlayerBullet | CollisionCategories.Invader | CollisionCategories.ScenePiece
        grass.physicsBody?.collisionBitMask = CollisionCategories.PlayerBullet | CollisionCategories.Invader | CollisionCategories.ScenePiece
        
        
        
    }
    
    func createPhysicsWorld(){
        self.physicsWorld.gravity = CGVectorMake(0, -2)
        self.physicsWorld.contactDelegate = self
    }
    
    func loadBG(){
        
        let background = SKSpriteNode(imageNamed: "BG2.jpg")
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
    
    func loadHud(){
        levelLabel.text = "level: " + String(level)
        levelLabel.position.x = 7
        levelLabel.position.y = 20
        levelLabel.zPosition = 24
        levelLabel.fontSize = 17
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        
        weaponLabel.text = "pistol";
        weaponLabel.position.x = self.size.width*0.99
        weaponLabel.position.y = self.size.height - 55
        weaponLabel.zPosition = 2
        weaponLabel.fontSize = 17
        weaponLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        
        
        pointsLabel.text = String(points)
        pointsLabel.position = CGPoint(x: 7,y: 5)
        pointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        pointsLabel.fontSize = 20
        pointsLabel.zPosition = 24
        self.addChild(pointsLabel)
        self.addChild(trapLabel)
        self.addChild(weaponLabel)
        self.addChild(levelLabel)
        
        
        
        let dock = ScenePiece(pieceName: "dock", textTureName: "dock.png", dynamic: false, scale: 1, x: 10, y: self.size.height - 20)
        dock.zPosition = 18
        self.addChild(dock)
        
        
        let nextWeaponButton = ScenePiece(pieceName: "nwbutton", textTureName: "nwbutton", dynamic: false, scale: 0.4,x : self.size.width - 20,y: self.size.height - 20)
        nextWeaponButton.zPosition = 14
        self.addChild(nextWeaponButton)
        // nextWeaponButton.AddPhysics(self, dynamic: false)
        let musicBtn = ScenePiece(pieceName: "musicbtn", textTureName: "musicbtn", dynamic: false, scale: 0.4,x : self.size.width - 100,y: self.size.height - 20)
        //self.addChild(musicBtn)
        musicBtn.zPosition = 14
        
        let trapButton = ScenePiece(pieceName: "trapbtn", textTureName: "trapbtn", dynamic: false, scale: 0.4,x : self.size.width - 200,y: self.size.height - 20)
        self.addChild(trapButton)
        trapButton.zPosition = 14
        let nextTrapButton = ScenePiece(pieceName: "nexttrap", textTureName: "nxttrapbtn", dynamic: false, scale: 0.4,x : self.size.width - 100,y: self.size.height - 20)
        nextTrapButton.zPosition = 14
        self.addChild(nextTrapButton)
        
        trapLabel.text = "rock fall";
        trapLabel.position.x = trapButton.position.x+20
        trapLabel.position.y = self.size.height - 55
        trapLabel.zPosition = 2
        trapLabel.fontSize = 17
        trapLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        let moveR = ScenePiece(pieceName: "moveR", textTureName: "movebtn", dynamic: false, scale: 1,x : 100,y:  20)
        moveR.zPosition = 2
        //self.addChild(moveR)
        
        let moveL = ScenePiece(pieceName: "moveL", textTureName: "movebtn", dynamic: false, scale: 1,x : 20,y:  20)
        moveL.zPosition = 2
        //self.addChild(moveL)
        
        
    }
    
    func setupPlayer(){
        player.position.x = -self.size.width/2+300
        player.position.y = self.size.height*0.8
        player.zPosition = 7
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width*0.4)
        player.physicsBody?.dynamic = false
        player.physicsBody?.categoryBitMask = CollisionCategories.Player
        player.physicsBody?.contactTestBitMask = CollisionCategories.EnemyBullet
        player.physicsBody?.collisionBitMask =  CollisionCategories.EnemyBullet
        player.setScale(1.5)
        addChild(player)
    }
    
    
    
    func setupTurret(x: CGFloat,y: CGFloat){
        let turret:Ally = Ally(scene: self,name: "turret",x: x,y: y)
        turret.zPosition = 20
        turret.physicsBody = SKPhysicsBody(circleOfRadius: turret.size.width/2)
        turret.physicsBody?.dynamic = false
        turret.physicsBody?.categoryBitMask = CollisionCategories.Ally
        turret.physicsBody?.contactTestBitMask = CollisionCategories.EnemyBullet
        turret.physicsBody?.collisionBitMask =  CollisionCategories.EnemyBullet
    }
    
    
    
    func setupEnemy(){
        var random = randRange(0, upper: 2)
        NSLog(String(random))
        var gunner = false
        if(random == 0){
          //  gunner = true
        }
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"soldierrun", name:"invader", gunner: gunner, atlas: soldieratlas)
        tempInvader.zPosition = 6
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-74
        tempInvader.physicsBody?.velocity = CGVectorMake(-40,0)
        tempInvader.physicsBody?.mass = 10000
        tempInvader.physicsBody?.affectedByGravity = false
        
    }
    
    func setupEnemyAt(x: CGFloat, y: CGFloat, speed: CGFloat, scale: CGFloat){
        var random = randRange(0, upper: 2)
        NSLog(String(random))
        var gunner = false
        if(random == 0){
            gunner = true
        }
        let tempInvader:Invader = Invader(scene: self,scale: scale, invaderhit: 0, animprefix:"soldierrun", name:"invader", gunner: gunner, atlas: soldieratlas)
        tempInvader.zPosition = 6
        tempInvader.position.x = x
        tempInvader.position.y = y
        tempInvader.physicsBody?.velocity = CGVectorMake(speed, 0)
        tempInvader.physicsBody?.mass = 10000
        tempInvader.physicsBody?.affectedByGravity = false
        
    }
    
    func setupHeavyEnemy(){
        let invaderFrame = SKNode()
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"heavy", name:"heavy", gunner: true, atlas: soldieratlas)
        tempInvader.zPosition = 9
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-74
        tempInvader.physicsBody?.velocity = CGVectorMake(-20, 0)
        tempInvader.physicsBody?.mass = 10000
        tempInvader.physicsBody?.affectedByGravity = false
        
    }
    
    
    func setupZombie(){
        let invaderFrame = SKNode()
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1), invaderhit: 0, animprefix:"zombie", name:"zombie", gunner: true, atlas: soldieratlas)
        tempInvader.zPosition = 9
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-74
        tempInvader.physicsBody?.velocity = CGVectorMake(-30, 0)
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
        let spawnZombie = SKAction.runBlock(){
            self.setupZombie()
        }
        let spawnHeavy = SKAction.runBlock(){
            var random = self.randRange(0, upper: 1)
            if(random == 1){
                self.setupEnemy()
            }else{
                self.setupHeavyEnemy()
            }
        }
        let spawnAndWait = SKAction.sequence([spawnNormal,wait1])
        let spawnAndWaitHeavy = SKAction.sequence([spawnHeavy,wait2])
        let spawnAndWaitZombie = SKAction.sequence([spawnZombie,wait2])
        
        self.runAction(SKAction.repeatActionForever(spawnAndWait), withKey:"spawnandwait")
        self.runAction(longwait,completion:{
            
            self.removeActionForKey("spawnandwait")
            self.runAction(SKAction.repeatActionForever(spawnAndWaitHeavy), withKey:"spawnandwaitheavy")
            self.runAction(longwait,completion:{
                
                self.removeActionForKey("spawnandwaitheavy")
                self.physicsWorld.removeAllJoints()
                self.runAction(SKAction.repeatActionForever(spawnAndWaitZombie), withKey:"spawnandwaitzombie")
                
            })
        })
        
    }
    
    func startSchedulers1(){
        var iter = 0
        var numEnemy = self.numEnemyInWave
        let wait1 = SKAction.waitForDuration(2, withRange: 1)
        let wait2 = SKAction.waitForDuration(4, withRange: 1)
        let longwait = SKAction.waitForDuration(15)
        let medwait = SKAction.waitForDuration(3)
        
        let spawnNormal = SKAction.runBlock(){
            self.setupEnemy()
        }
        
        let spawnHeavy = SKAction.runBlock(){
            self.setupHeavyEnemy()
        }
        
        let spawnZombie = SKAction.runBlock(){
            self.setupZombie()
        }
        
        let spawnRandom = SKAction.runBlock(){
            var random = self.randRange(0, upper: 1)
            if(random == 1){
                self.setupEnemy()
            }else{
                self.setupHeavyEnemy()
            }
        }
        
        let spawnAndWait = SKAction.repeatAction(SKAction.sequence([spawnNormal,wait1]), count: numEnemy)
        let spawnAndWaitHeavy = SKAction.repeatAction(SKAction.sequence([spawnHeavy,wait2]), count: numEnemy)
        let spawnAndWaitZombie = SKAction.repeatAction(SKAction.sequence([spawnZombie,wait2]), count: numEnemy)
        let spawnAndWaitRandom = SKAction.repeatAction(SKAction.sequence([spawnRandom,wait2]), count: numEnemy)
        
        let actionArr = [medwait,spawnAndWait,medwait, spawnAndWait ,medwait, spawnAndWaitRandom, longwait]
        
        self.runAction(SKAction.repeatAction(SKAction.sequence(actionArr), count: 1), completion:{
            self.gameOver(true)
            
        })
        
    }
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        touching = true
        var turretLimit = 4
        var weaponCap  = self.weaponCap //meaning +1 weapons - all weapons  = 8
        var trapCap = 3 //meaning +1 traps
        let touchLocation = touch.locationInNode(self)
        touchx = touchLocation.x
        touchy = touchLocation.y
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        //NSLog(touchedNode.name!)
        if(placeMudMode){
            trapLabel.text = "Gfield placed!";
            placeMud(touchx, y: touchy)
            placeMudMode  = false
        }else
            
            if(placeTurretMode && touchedNode.name == "dock"){
                self.flashText("turret placed!", x: touchedNode.position.x, y: touchedNode.position.y - 30, z: 30, waitDur: 2, color: SKColor.greenColor())
                trapLabel.text = "press T to place turret";
                setupTurret(touchx, y: touchy)
                placeTurretMode = false
                numTurrets++
            }else if(touchedNode.name == "turret"){
                let turret = touchedNode as! Ally
                turret.removeFromParent()
                turret.removeTurRad()
                
            }else
                if(touchedNode.name == "nexttrap"){
                    trapLabel.fontColor = SKColor.whiteColor()
                    trap++
                    
                    if(trap == 3){
                        placeTurretMode = false
                        
                        
                        trapLabel.text = "press T to place gravity field";
                        enumerateChildNodesWithName("flash") { node, stop in
                            
                            node.removeFromParent()
                        }
                        flashText("info: radial gravity field affecting only enemy bullets", x: self.size.width*0.3, y: 10, z: 22, waitDur: 3, color: SKColor.whiteColor())
                    }
                    if(trap == 2){
                        
                        
                        
                        if(numTurrets < turretLimit){
                            trapLabel.text = "press T to place turret";
                            enumerateChildNodesWithName("flash") { node, stop in
                                
                                node.removeFromParent()
                            }
                            flashText("info: place turret on dock upper left corner", x: self.size.width*0.3, y: 10, z: 22, waitDur: 3, color: SKColor.whiteColor())
                            
                            
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
                        let arrow = SKSpriteNode(imageNamed: "darrow1.png")
                        self.addChild(arrow)
                        arrow.zPosition = 12
                        arrow.position.x = self.size.width*0.3
                        arrow.position.y = self.size.height*0.9
                        arrow.setScale(0.2)
                        self.indicateNode(arrow, waitf: 0.2)
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
                        if(flamerOn){
                            removeActionForKey("flamer")
                            flameEmmiter.removeFromParent()
                            flameNode.removeFromParent()
                            flamerOn = false
                        }
                        if(machineGunMode){
                            machineGunMode = false
                        }
                        if(autoCrossBow){
                            autoCrossBow = false
                        }
                        if(autoShottie){
                            autoShottie = false
                        }
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
                    if(weapon == 8){
                        weaponLabel.text = "nader"
                        autoShottie = false
                    }
                    // NSLog("buttonpressed"+String(weapon))
                }else if(touchedNode.name == "trapbtn"){
                    enableTrapDoor = true
                    if(trap == 0){
                        if(self.points >= 30){
                            
                            self.points = self.points - 30
                            self.flashText("-30 points", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                            
                            spikeFall()
                        }else{
                            
                            self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                        }
                        
                        
                        
                    }else if(trap == 1){
                        
                        if(self.points >= 60){
                            
                            self.points = self.points - 60
                            self.flashText("-60 points", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                            
                            swingingSpikeBall()
                        }else{
                            
                            self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                        }
                        
                        
                        
                        
                        
                        
                    }else if(trap == 2){
                        if(numTurrets < turretLimit){
                            if(self.points >= 100){
                                
                                self.points = self.points - 100
                                trapLabel.text = "touch to place";
                                self.flashText("-100 points", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                                placeTurretMode = true
                            }else{
                                
                                self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                            }

                        }else{
                            trapLabel.text = "turret Limit:" + String(turretLimit);
                        }
                        
                    }else if(trap == 3){
                        if(self.points >= 20){
                            
                            self.points = self.points - 20
                            trapLabel.text = "touch to place";
                            self.flashText("-20 points", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                            placeMudMode = true
                        }else{
                            
                            self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                        }
                    }
                } else if(touchedNode.name == "musicbtn"){
                    if(musicoff){
                        musicoff = false
                        audioPlayer.play()
                    }else{
                        musicoff = true
                        audioPlayer.stop()
                    }
                    
                }else{
                    var bulletName = "bullet"
                    var bulletTexture = "bullet"
                    var bulletScale = CGFloat(0.6)
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
                        bulletScale = 0.5
                        speedMultiplier = CGFloat(0.004)
                        bulletSound = "arrowfire.mp3"
                        canFireWait = 0.4
                    }
                    if(weapon == 4){
                        //shotgun
                        bulletName = "shell"
                        bulletTexture = "ball"
                        var bulletScale = 1
                        speedMultiplier = CGFloat(0.0007)
                        bulletSound = "shotgunsound.mp3"
                        canFireWait = 1
                        multiShot = true
                    }
                    
                    if(weapon == 8){
                        multiShot = false
                        bulletName = "nade"
                        bulletTexture = "ball"
                        var bulletScale = 1
                        speedMultiplier = CGFloat(0.001)
                        bulletSound = "gunshot.mp3"
                        canFireWait = 0.8
                    }
                    if(!flamerOn && !machineGunMode && !autoCrossBow && !autoShottie){
                        player.fireBullet(self, touchX:touchLocation.x, touchY:touchLocation.y, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName, atlas: mainatlas)
                        
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
        //color changing of trap labels
        if(self.points >= 100 && trap == 2){
            trapLabel.fontColor = SKColor.greenColor()
        }else if(self.points >= 60 && trap == 1){
            trapLabel.fontColor = SKColor.greenColor()
        }else if(self.points >= 30 && trap == 0){
            trapLabel.fontColor = SKColor.greenColor()
        }else if(self.points >= 20 && trap == 3){
            trapLabel.fontColor = SKColor.greenColor()
        }else{
            trapLabel.fontColor = SKColor.redColor()
        }
        if(self.points < 0){
            self.points = 0
        }
        pointsLabel.text = "Points:" + String(points)
        hits = 0
        moveInvaders()
        if(touching){
            rotateGunToTouch()
        }
        if(machineGunMode){
            self.fireMachineGun("machinegun.wav", scale: 0.4, bulletTexture: "bullet", bulletName: "bullet", speedMulti: 0.001, multiShot: false,canFireWait: 0.2)
        }
        if(autoCrossBow){
            self.fireMachineGun("arrowfire.mp3", scale: 0.3, bulletTexture: "arrow1", bulletName: "arrow", speedMulti: 0.003, multiShot: false, canFireWait: 0.2)
        }
        if(autoShottie){
            
            self.fireMachineGun("shotgunsound.mp3", scale: 0.2, bulletTexture: "ball", bulletName: "bullet", speedMulti: 0.001, multiShot: true, canFireWait: 0.7)
            
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
            player.fireBullet(self, touchX:touchx, touchY:touchy, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName, atlas: mainatlas)
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
            turret.fireBullet(self, touchX:enemyx, touchY:enemyy, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName, atlas: self.mainatlas)
        }
        
    }
    
    func placeMud(x: CGFloat,y: CGFloat){
        let node = SKSpriteNode(imageNamed: "field0")
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width*0.1)
        node.physicsBody?.categoryBitMask = CollisionCategories.Gfield
        node.physicsBody?.collisionBitMask = CollisionCategories.EnemyBullet
        node.physicsBody?.contactTestBitMask = CollisionCategories.EnemyBullet
        
        node.physicsBody?.fieldBitMask = 0
        node.physicsBody?.dynamic = false
        node.position.x = x
        node.position.y = y
        node.zPosition = 12
        self.addChild(node)
        var playerTextures:[SKTexture] = []
        for i in 0...11 {
            playerTextures.append(SKTexture(imageNamed: "field\(i)"))
        }
        let playerAnimation = SKAction.repeatActionForever( SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1))
        node.runAction(playerAnimation)
       
        let vortex = SKFieldNode.vortexField()
       
        let fieldNode = SKFieldNode.radialGravityField()
        fieldNode.enabled = true;
        vortex.enabled = true
        //node.addChild(fieldNode)
        node.addChild(vortex)
        fieldNode.strength =  4
        fieldNode.falloff = 1
        self.waitAndRemove(node, wait: 10)
        
    }
    
    func swingingSpikeBall(){
        
        let anchor = ScenePiece(pieceName: "rock", textTureName: "saw3", dynamic: true, scale: 0.2,x : self.size.width*0.5,y: self.size.height + 30)
        
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
        let rock1 = ScenePiece(pieceName: "rocks", textTureName: "rock1", dynamic: true, scale: randRangeFrac(4, upper: 8),x : CGFloat( randRange(100, upper: 150)),y: self.size.height - 40)
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
        
        enumerateChildNodesWithName("heavy") { node, stop in
            let invader = node as! Invader
            if(invader.getLock()){
                self.fireTurret("machinegun.wav", scale: 0.4, bulletTexture: "ball", bulletName: "bullet", speedMulti: 0.001, multiShot: false,canFireWait: 1, enemyx: invader.position.x - CGFloat(self.randRange(0, upper: 10)), enemyy: invader.position.y + CGFloat(self.randRange(0, upper: 80)))
            }
        }
        enumerateChildNodesWithName("invader") { node, stop in
            let invader = node as! Invader
            if(invader.getLock()){
                self.fireTurret("machinegun.wav", scale: 0.7, bulletTexture: "bullet", bulletName: "bullet", speedMulti: 0.001, multiShot: false,canFireWait: 1, enemyx: invader.position.x - CGFloat(self.randRange(0, upper: 10)), enemyy: invader.position.y + CGFloat(self.randRange(0, upper: 80)))
            }
            if(invader.isGunner()){
                invader.fireBullet(self, touchX: self.player.position.x, touchY: self.player.position.y + CGFloat(self.randRange(0, upper: 80)), bulletTexture: "ball", bulletScale: 1, speedMultiplier: CGFloat(0.001), bulletSound: "gunshot.mp3", canFireWait: 1.5, multiShot: false, bulletName: "invaderbullet", atlas: self.mainatlas)
            }
        }
        
    }
    
    
    
    override func didSimulatePhysics() {
        enumerateChildNodesWithName("invaderbullet") { node, stop in
            let bullet = node as! EnemyBullet
            if(bullet.position.y > self.size.height - 10 || bullet.position.y < 0 + 30 || bullet.position.x > self.size.width + 100){
                self.removeNode(bullet)
            }
            
        }
        
        enumerateChildNodesWithName("bullet") { node, stop in
            let bullet = node as! PlayerBullet
            if(bullet.position.y > self.size.height - 10 || bullet.position.y < 0 + 30 || bullet.position.x > self.size.width - 10){
                self.removeNode(bullet)
                
            }
            
        }
        
        enumerateChildNodesWithName("arrow") { node, stop in
            let bullet = node as! PlayerBullet
            if(bullet.position.y > self.size.height - 10 || bullet.position.y < 0 + 30 || bullet.position.x > self.size.width - 10){
                self.removeNode(bullet)
            }
            
        }
        
        enumerateChildNodesWithName("nade") { node, stop in
            let bullet = node as! PlayerBullet
            if(bullet.position.y > self.size.height - 10 || bullet.position.y < 0 + 30 || bullet.position.x > self.size.width - 10){
                
                self.removeNode(bullet)
            }
            
        }
        enumerateChildNodesWithName("invader") { node, stop in
            let invader = node as! Invader
            if(invader.gethit() > 35){
                self.flashAndremoveNode(invader)
            }
            if(invader.position.x < -10){
                if(self.points >= 60){
                    self.points = self.points - 60
                }else if(self.points < 60){
                    self.points = 0
                }
                self.flashText("breach! -60 points", x: 10, y: self.size.height*0.25, z: 10, waitDur: 3, color: SKColor.redColor())
                self.removeNode(invader)
                // self.gameOver()
            }
            
        }
        
        enumerateChildNodesWithName("zombie") { node, stop in
            let invader = node as! Invader
            
            if(invader.position.x < -10){
                if(self.points >= 60){
                    self.points = self.points - 60
                }else if(self.points < 60){
                    self.points = 0
                }
                self.flashText("breach! -60 points", x: 10, y: self.size.height*0.25, z: 10, waitDur: 3, color: SKColor.redColor())
                self.removeNode(node)
                // self.gameOver()
            }
            
        }
        
        enumerateChildNodesWithName("heavy") { node, stop in
            let invader = node as! Invader
            if(invader.position.x < -10){
                self.removeNode(invader)
                if(invader.position.x < 5){
                    if(self.points >= 60){
                        self.points = self.points - 60
                    }else if(self.points < 60){
                        self.points = 0
                    }
                    
                    self.flashText("breach! -60 points", x: 10, y: self.size.height*0.25, z: 10, waitDur: 3, color: SKColor.redColor())
                    self.removeNode(node)
                    // self.gameOver()
                }
            }
            
        }
    }
    
    func flashText(text: String, x: CGFloat,y: CGFloat, z: CGFloat, waitDur: Double, color:SKColor){
        let tempL = SKLabelNode(fontNamed: "COPPERPLATE")
        tempL.fontColor = color
        tempL.text = text;
        tempL.name = "flash"
        tempL.position.x = x
        tempL.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        tempL.position.y = y
        tempL.zPosition = z
        if(text == "turret placed!"){
            tempL.fontSize = 9
        }else{
            tempL.fontSize = 14
        }
        
        self.addChild(tempL)
        let fadein = SKAction.fadeInWithDuration(0.1)
        let fadeout = SKAction.fadeOutWithDuration(waitDur)
        let wait = SKAction.waitForDuration(0.1)
        let flash = SKAction.sequence([fadein,wait,fadeout])
        
        tempL.runAction(flash,completion:{
            tempL.removeAllActions()
            tempL.removeFromParent()
        })
        
    }
    
    func flashTextSc(text: String, x: CGFloat,y: CGFloat, z: CGFloat, waitDur: Double, color:SKColor, scale: CGFloat){
        let tempL = SKLabelNode(fontNamed: "COPPERPLATE")
        tempL.fontColor = color
        tempL.text = text;
        tempL.name = "flash"
        
        tempL.position.x = x
        tempL.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        tempL.position.y = y
        tempL.zPosition = z
        tempL.fontSize = scale
        
        self.addChild(tempL)
        let fadein = SKAction.fadeInWithDuration(0.1)
        let fadeout = SKAction.fadeOutWithDuration(waitDur)
        let wait = SKAction.waitForDuration(0.1)
        let flash = SKAction.sequence([fadein,wait,fadeout])
        
        tempL.runAction(flash,completion:{
            tempL.removeAllActions()
            tempL.removeFromParent()
        })
        
    }
    
    
    func gameOver(win: Bool){
        audioPlayer.stop()
        //self.removeFromParent()
        self.removeAllChildren()
        self.removeAllActions()
        let scene = GameOver(size: self.size, points: self.points,ef: EnemyFreq, level: self.level, ne:self.numEnemyInWave, win: win, weaponCap: self.weaponCap)
        let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
        self.view?.presentScene(scene, transition: transitionType)
        
    }
    
    func addAndRemoveEmitter(wait: Double, x: CGFloat,y: CGFloat, fileName:String,zPos: CGFloat){
        let node = SKEmitterNode(fileNamed: fileName)
        
        node.zPosition = zPos
        self.addChild(node)
        node.position.x = x
        node.position.y = y

        let wait = SKAction.waitForDuration(wait)
        runAction(wait,completion:{
            self.removeNode(node)
        })
 
    }
    
    func waitAndRemove(node: SKNode, wait: Double){
        
        let waitToEnableFire = SKAction.waitForDuration(wait)
        runAction(waitToEnableFire,completion:{
            node.removeAllChildren()
            node.removeAllActions()
            node.removeFromParent()
            
        })
    }
    

    func removeNode(node: SKNode){
        node.removeAllChildren()
        node.removeAllActions()
        node.removeFromParent()
    }
    
    
    func flashAndremoveNode(node: SKNode){
        node.removeAllChildren()
        let setHidden = SKAction.runBlock(){
            node.hidden = true
        }
        let setVisible = SKAction.runBlock(){
            node.hidden = false
        }
        let waitAbit = SKAction.waitForDuration(0.07)
        let seq = SKAction.sequence([setHidden,waitAbit,setVisible,waitAbit,setHidden,waitAbit,setVisible,waitAbit])
        node.runAction(seq,completion:{
            node.removeAllActions()
            node.removeFromParent()
            // self.playerDead = true
        })
    }
    
    func indicateNode(node: SKNode, waitf: Double){
        node.removeAllChildren()
        let setHidden = SKAction.runBlock(){
            node.hidden = true
        }
        let setVisible = SKAction.runBlock(){
            node.hidden = false
        }
        let waitAbit = SKAction.waitForDuration(waitf)
        let seq = SKAction.sequence([setHidden,waitAbit,setVisible,waitAbit,setHidden,waitAbit,setVisible,waitAbit])
        node.runAction(seq,completion:{
            node.removeAllActions()
            node.removeFromParent()
            // self.playerDead = true
        })
    }
    
    func BombNode() -> SKNode{
        let bomb = SKNode()
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        bomb.physicsBody?.dynamic = true
        bomb.physicsBody?.affectedByGravity = false

        bomb.name = "bombnode"
        self.waitAndRemove(bomb, wait: 2)
        return bomb

    }
    func explodeNode(node: SKNode, x: CGFloat, y: CGFloat){
        self.runAction(SKAction.playSoundFileNamed("nade.mp3", waitForCompletion: false))
        let sparkEmmiter = SKEmitterNode(fileNamed: "explo.sks")
        let blood = SKEmitterNode(fileNamed: "heavyblood.sks")
        sparkEmmiter.zPosition = 3
        blood.zPosition = 3
        node.addChild(sparkEmmiter)
        node.addChild(blood)
        node.removeFromParent()
        let invaderObj = node as! Invader
        let waitforblood = SKAction.waitForDuration(0.3)
        self.runAction(waitforblood,completion:{
            invaderObj.hit(invaderObj.gethit()+40)
            blood.removeFromParent()
            sparkEmmiter.removeFromParent()
            // secondBody.node?.removeFromParent()
        })
        
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
                let invaderObj = firstBody.node as! Invader
                if(secondBody.node?.name == "arrow"){
                    self.waitAndRemove(secondBody.node!, wait: 2)
                }else if(secondBody.node?.name == "nade")
                {
                    //dont remove nade
                }else{
                    self.waitAndRemove(secondBody.node!, wait: 0.01)
                    //self.removeNode()
                }
                self.hits++
                if(hits == 1){
                    let contactPoint = contact.contactPoint
                    if(firstBody.node?.name == "invader"){
                        self.addAndRemoveEmitter(0.2, x: contactPoint.x - 10, y: contactPoint.y, fileName: "blood.sks",zPos:3)
                        runAction(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
                        NSLog(secondBody.node!.name!)
                        if(secondBody.node?.name == "shell"){
                            invaderObj.hit(invaderObj.gethit()+3)
                        }else{
                            invaderObj.hit(invaderObj.gethit()+2)
                        }
                        
                        if(invaderObj.gethit() == 4){
                            let smoke = SKEmitterNode(fileNamed: "cblood")
                            smoke.zPosition = 3
                            firstBody.node?.addChild(smoke)
                        }
                        
                        if(secondBody.node?.name == "arrow"){
                            invaderObj.physicsBody?.velocity = CGVectorMake(-30, 0)
                            let bullet = secondBody.node as! PlayerBullet
                            let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                            self.physicsWorld.addJoint(myJoint)
                            //bullet.texture = SKTexture(imageNamed: "ArrowHitTexture")
                        }
                        
                        if(contactPoint.y > invaderObj.position.y){
                            self.points = self.points + 1
                            self.flashTextSc("headshot! +1", x: invaderObj.position.x, y: invaderObj.position.y + invaderObj.size.height*0.5, z: 10, waitDur: 0.2, color: SKColor.greenColor(),scale: 9)
                        }
                        
                        if(secondBody.node?.name == "nade"){
                            let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                            self.physicsWorld.addJoint(myJoint)
                            
                            let waitToEnableFire = SKAction.waitForDuration(2)
                            runAction(waitToEnableFire,completion:{
                                self.runAction(SKAction.playSoundFileNamed("nade.mp3", waitForCompletion: false))
                                let sparkEmmiter = SKEmitterNode(fileNamed: "explo.sks")
                               
                                
                                
                                let blood = SKEmitterNode(fileNamed: "heavyblood.sks")
                                sparkEmmiter.zPosition = 3
                                blood.zPosition = 3
                                firstBody.node?.addChild(sparkEmmiter)
                                firstBody.node?.addChild(blood)
                                secondBody.node?.removeFromParent()
                                let bomb = SKNode()
                                bomb.physicsBody = SKPhysicsBody(circleOfRadius: 60)
                                bomb.physicsBody?.velocity = firstBody.velocity
                                bomb.physicsBody?.dynamic = true
                                bomb.physicsBody?.pinned = true
                                bomb.physicsBody?.mass  = 0
                                bomb.physicsBody?.categoryBitMask = CollisionCategories.ScenePiece
                                bomb.physicsBody?.contactTestBitMask = CollisionCategories.Invader
                                 bomb.physicsBody?.collisionBitMask = 0
                                bomb.name = "bombnode"
                                self.waitAndRemove(bomb, wait: 2)
                            
                                
                                firstBody.node?.addChild(bomb)
                                let waitforblood = SKAction.waitForDuration(0.4)
                                self.runAction(waitforblood,completion:{
                                    invaderObj.hit(invaderObj.gethit()+40)
                                    blood.removeFromParent()
                                    sparkEmmiter.removeFromParent()
                                    // secondBody.node?.removeFromParent()
                                })
                                //self.flashAndremoveNode(firstBody.node!)
                            })
                            
                        }
                        
                        if(invaderObj.gethit() >= self.invaderLife){
                            self.points = self.points + 5
                            firstBody.categoryBitMask = CollisionCategories.ScenePiece
                            self.flashText("+5", x: invaderObj.position.x, y: invaderObj.position.y + invaderObj.size.height*0.25, z: 10, waitDur: 0.3, color: SKColor.yellowColor())
                            self.flashAndremoveNode(invaderObj)
                        }
                        
                    } //end invader hit stuff
                    if(firstBody.node?.name == "heavy"){
                        runAction(SKAction.playSoundFileNamed("punch.wav", waitForCompletion: false))
                        self.addAndRemoveEmitter(0.3, x: contactPoint.x, y: contactPoint.y, fileName: "spark.sks",zPos:3)
                        let invaderObj = firstBody.node as! Invader
                        invaderObj.hit(invaderObj.gethit()+1)
                        if(invaderObj.gethit() == 5){
                            let smoke = SKEmitterNode(fileNamed: "smoke")
                            smoke.zPosition = 3
                            firstBody.node?.addChild(smoke)
                        }
                        if(invaderObj.gethit() == 10){
                            
                            self.flashTextSc("armour destroyed +2", x: invaderObj.position.x-10, y: invaderObj.position.y + invaderObj.size.height*0.25, z: 10, waitDur: 0.3, color: SKColor.yellowColor(), scale: 10)
                            self.points = self.points + 2
                            self.flashAndremoveNode(invaderObj)
                            self.runAction(SKAction.playSoundFileNamed("nade.mp3", waitForCompletion: false))
                            self.addAndRemoveEmitter(0.5, x: invaderObj.position.x, y: invaderObj.position.y, fileName: "explo.sks", zPos: 20)
                            let waitToEnableFire = SKAction.waitForDuration(0.3)
                            runAction(waitToEnableFire,completion:{
                                self.setupEnemyAt(invaderObj.position.x, y: invaderObj.position.y-10, speed: -50, scale: 1)
                                
                            })
                            
                        }
                    }//end heavy
                    
                    
                    if(firstBody.node?.name == "zombie"){
                        runAction(SKAction.playSoundFileNamed("punch.wav", waitForCompletion: false))
                        self.addAndRemoveEmitter(0.3, x: contactPoint.x, y: contactPoint.y, fileName: "blood.sks",zPos:3)
                        let invaderObj = firstBody.node as! Invader
                        invaderObj.hit(invaderObj.gethit()+1)
                        if(invaderObj.gethit() == 3){
                            let smoke = SKEmitterNode(fileNamed: "cblood")
                            smoke.zPosition = 3
                            firstBody.node?.addChild(smoke)
                        }
                        if(invaderObj.gethit() == 6){
                            self.flashText("+10", x: invaderObj.position.x, y: invaderObj.position.y + invaderObj.size.height*0.25, z: 10, waitDur: 0.3, color: SKColor.yellowColor())
                            self.points = self.points + 10
                            self.flashAndremoveNode(invaderObj)
                        }
                    }//end zombie
                    
                }
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.floor != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.ScenePiece != 0)) {
                let contactPoint = contact.contactPoint
                let waitToEnableFire = SKAction.waitForDuration(0.3)
                runAction(waitToEnableFire,completion:{
                    secondBody.node?.removeFromParent()
                })
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Player != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Invader != 0)) {
                firstBody.node?.removeFromParent()
                
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.PlayerBullet != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.floor != 0)) {
                
                let contactPoint = contact.contactPoint
                self.addAndRemoveEmitter(0.2, x: contactPoint.x, y: contactPoint.y + 20, fileName: "dirt.sks",zPos: 3)
                if(firstBody.node?.name == "arrow"){
                    firstBody.categoryBitMask = CollisionCategories.ScenePiece
                    firstBody.contactTestBitMask = CollisionCategories.Invader
                    let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                    self.physicsWorld.addJoint(myJoint)
                    let waitToEnableFire = SKAction.waitForDuration(2)
                    runAction(waitToEnableFire,completion:{
                        self.physicsWorld.removeJoint(myJoint)
                        firstBody.node?.removeAllActions()
                        firstBody.node?.removeFromParent()
                    })
                }else if(firstBody.node?.name == "nade"){
                    let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                    self.physicsWorld.addJoint(myJoint)
                    let waitToEnableFire = SKAction.waitForDuration(2)
                    runAction(waitToEnableFire,completion:{
                        self.runAction(SKAction.playSoundFileNamed("nade.mp3", waitForCompletion: false))
                        self.physicsWorld.removeJoint(myJoint)
                        firstBody.node?.removeAllActions()
                        firstBody.node?.removeFromParent()
                        self.addAndRemoveEmitter(1, x: contactPoint.x, y: contactPoint.y + 10, fileName: "explo.sks", zPos: 3)
                    })
                }else{
                    self.waitAndRemove(firstBody.node!, wait: 0.01)
                }
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.EnemyBullet != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Gfield != 0)) {
                firstBody.node?.removeFromParent()
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.EnemyBullet != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.PlayerBullet != 0)) {
                self.waitAndRemove(firstBody.node!, wait: 0.1)
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Player != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.EnemyBullet != 0)) {
                let contactPoint = contact.contactPoint
                self.hits++
                if(hits == 1){
                    let player = firstBody.node as! Player
                    let bullet = secondBody.node as! EnemyBullet
                    bullet.removeFromParent()
                    NSLog(String(player.gethit()))
                    NSLog("hits on player")
                    player.hit(player.gethit()+1)
                    self.addAndRemoveEmitter(0.3, x: contactPoint.x, y: contactPoint.y, fileName: "spark.sks",zPos:3)
                    if(player.gethit() == 2){
                        let smoke = SKEmitterNode(fileNamed: "smoke")
                        smoke.zPosition = 30
                        smoke.position.x = player.position.x
                        smoke.position.y = player.position.y
                        self.addChild(smoke)
                    }
                    if(player.gethit() > 3){
                        self.flashAndremoveNode(player)
                        self.gameOver(false)
                        NSLog("PLayer dead")
                    }
                }
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.EnemyBullet != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Ally != 0)) {
                NSLog("dfdfdAAAAfdfddd")
                let turret = secondBody.node as! Ally
                self.flashAndremoveNode(turret)
                turret.removeTurRad()
                self.waitAndRemove(firstBody.node!, wait: 0.02)
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.ScenePiece != 0)) {
                if(secondBody.node?.name == "flamenode"){
                    let invaderObj = firstBody.node as! Invader
                    invaderObj.hit(invaderObj.gethit()+10)
                    var playerTextures:[SKTexture] = []
                    for i in 0...18 {
                        playerTextures.append(SKTexture(imageNamed: "flamedeath\(i)"))
                    }
                    let playerAnimation = SKAction.animateWithTextures(playerTextures, timePerFrame: 0.05)
                    firstBody.node?.runAction(playerAnimation,completion:{
                        firstBody.node?.removeFromParent()
                    })
                }
                
                if(secondBody.node?.name == "turretRad"){
                    let invaderObj = firstBody.node as! Invader
                    invaderObj.setLocked()
                }
                
                if(secondBody.node?.name == "bombnode"){
                    let invaderObj = firstBody.node as! Invader
                    let blood = SKEmitterNode(fileNamed: "heavyblood.sks")
               
                    blood.zPosition = 3
                
                    invaderObj.addChild(blood)
                    self.flashAndremoveNode(invaderObj)
                   
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
                        sparkEmmiter
                        sparkEmmiter.removeFromParent()
                        // secondBody.node?.removeFromParent()
                    })
                }
                
                if(secondBody.node?.name == "saw"){
                    runAction(SKAction.playSoundFileNamed("slice.mp3", waitForCompletion: false))
                    let contactPoint = contact.contactPoint
                    self.addAndRemoveEmitter(0.3, x: contactPoint.x, y: contactPoint.y, fileName: "heavyblood.sks", zPos: 14)
                    
                    var playerTextures:[SKTexture] = []
                    for i in 0...14 {
                        playerTextures.append(SKTexture(imageNamed: "deadsoldier\(i)"))
                    }
                    let playerAnimation = SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1)
                    firstBody.node?.runAction(playerAnimation, completion:{
                        self.removeNode(firstBody.node!)
                    })
                    self.physicsWorld.removeAllJoints()
                }
        }
        
    }
    
}


