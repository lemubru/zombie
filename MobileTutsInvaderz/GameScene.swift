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
    static let Spikes: UInt32 = 0x1 << 8
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
    var allyhits = 0
    var invaders = 0
    var playerDead = false
    var movingLeft = false
    var touching = false
    var touchx = CGFloat(1)
    var touchy = CGFloat(1)
    var numTurretsOnField = UInt32(0)
    let leftBounds = CGFloat(30) //used to create a margin on the left and right parts of the screen
    var rightBounds = CGFloat(0)
    var invadersWhoCanFire:[Invader] = []
    var invaderArr:[Invader] = []//array of the invaders who can fire.
    let player:Player = Player(name: "player")
    let turret:Player = Player(name: "turret")
    let flameEmmiter = SKEmitterNode(fileNamed: "flamer.sks")
    let flameNode = ScenePiece(pieceName: "flamenode", textTureName: "floor", dynamic: false, scale: 0.6,x : 2,y: 2)
    let dock = ScenePiece(pieceName: "dock", textTureName: "dock.png", dynamic: false, scale: 1, x: 10, y:4)
  
    var weapon = 0
    var trap = -1
    var canFire = true
    var flamerOn = false
    var flamerNodesPresent = false
    var machineGunMode = false
    var enableTrapDoor = false
    var autoCrossBow = false
    var autoShottie = false
    var points = UInt32(0)
    var shotgunround  = 0
    var placeTurretMode = false
    var placeMudMode = false
    var placeSpikeMode = false
    var numTurrets = 0
    let invaderLife = UInt32(6)
    var EnemyFreq = Double(3)
    var rocksFell = 0
    var buttonScale = CGFloat(0.5)
    
    
    let weaponLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let levelLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let trapLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    let ammoLabel = SKLabelNode(fontNamed: "COPPERPLATE")
    var weaponIcon = SKSpriteNode(imageNamed: "pistol")
    var trapIcon = SKSpriteNode(imageNamed: "rock1")
    
    var level = UInt32(0)
    var text = ""
    var movingR = false
    var movingL = false
    let mainatlas = SKTextureAtlas(named: "images")
    let soldieratlas = SKTextureAtlas(named: "soldierrun")
    var numEnemyInWave = 7
    var waitBetweenWaves = 9
    var weaponCap = 0
    var costSpikeTrap = UInt32(100)
    let costTurret = UInt32(200)
    var ammo = 0
    //Flying enemy
    var musicoff = false
    var flamerSound = SKAction()
      var beepSound = SKAction()
      var flamerGoing = SKAction()
      var nadeSound = SKAction()
      var hitSound = SKAction()
      var hitSoundHeavy = SKAction()
    var smashSound = SKAction()
     var sliceSound = SKAction()
     var slicedTex:[SKTexture] = []
    //shooting enemy
    //
    
    init(size: CGSize, points: UInt32, ef: Double, level: UInt32, numEnemy: Int, weaponCap: Int){
        text = String(points)

        super.init(size: size)
        
        for i in 0...14 {
            self.slicedTex.append(SKTexture(imageNamed: "deadsoldier\(i)"))
        }
        
       self.flamerSound = SKAction.playSoundFileNamed("flamersound4.wav", waitForCompletion: false)
        self.beepSound = SKAction.playSoundFileNamed("beep.mp3", waitForCompletion: false)
       // self.flamerGoing = SKAction.playSoundFileNamed("flamergoing.wav", waitForCompletion: false)
        self.nadeSound = SKAction.playSoundFileNamed("nade.mp3", waitForCompletion: false)
        self.hitSound = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
        self.hitSoundHeavy = SKAction.playSoundFileNamed("punch.wav", waitForCompletion: false)
        self.smashSound = SKAction.playSoundFileNamed("smash.wav", waitForCompletion: false)
        self.sliceSound = SKAction.playSoundFileNamed("slice.mp3", waitForCompletion: false)
        
        
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
        trap = -1
        setupPlayer()
        loadHud()
        soldieratlas.preloadWithCompletionHandler { () -> Void in
           self.startSchedulers1()
        }
        mainatlas.preloadWithCompletionHandler { () -> Void in
            
        }
    }
    
    func createFloor(){
        
        let grass = ScenePiece(pieceName: "grass", textTureName: "grass10.png", dynamic: false, scale: 1, x: self.size.width/2, y:20)
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
        
        let background = SKSpriteNode(imageNamed: "BG6")
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
        
        ammoLabel.text = "ammo: " + String(ammo)
        ammoLabel.position.x = 50
        ammoLabel.position.y = player.position.y + player.size.height/2
        ammoLabel.zPosition = 24
        ammoLabel.fontSize = 8
        ammoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        weaponLabel.text = "pistol";
        player.setClipSize(9)
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
        self.addChild(ammoLabel)
        
        
        self.dock.position.y = self.size.height - 20
        self.dock.zPosition = 18
        self.addChild(self.dock)
        
        
        let nextWeaponButton = ScenePiece(pieceName: "nwbutton", textTureName: "nwbutton", dynamic: false, scale: self.buttonScale,x : self.size.width - 25,y: self.size.height - 20)
        nextWeaponButton.zPosition = 14
        self.addChild(nextWeaponButton)
        
        
   
        weaponIcon.setScale(0.13)
        weaponIcon.position.x = nextWeaponButton.position.x - nextWeaponButton.size.width/2 - 30
        weaponIcon.position.y = nextWeaponButton.position.y
        weaponIcon.zPosition = 23
        self.addChild(weaponIcon)
        
        // nextWeaponButton.AddPhysics(self, dynamic: false)
        let musicBtn = ScenePiece(pieceName: "musicbtn", textTureName: "musicbtn", dynamic: false, scale: 0.4,x : self.size.width - 100,y: self.size.height - 20)
        //self.addChild(musicBtn)
        musicBtn.zPosition = 14
        
        let trapButton = ScenePiece(pieceName: "trapbtn", textTureName: "trapbtn", dynamic: false, scale: self.buttonScale,x : self.size.width - 200,y: self.size.height - 20)
        self.addChild(trapButton)
        trapButton.zPosition = 14
        let nextTrapButton = ScenePiece(pieceName: "nexttrap", textTureName: "nxttrapbtn", dynamic: false, scale: self.buttonScale,x : self.size.width - 140,y: self.size.height - 20)
        nextTrapButton.zPosition = 14
        self.addChild(nextTrapButton)
        
        trapLabel.text = "press NT to view traps";
        trapLabel.fontColor = SKColor.yellowColor()
        trapLabel.position.x = trapButton.position.x+20
        trapLabel.position.y = self.size.height - 55
        trapLabel.zPosition = 2
        trapLabel.fontSize = 17
        trapLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        
        trapIcon.setScale(0.4)
        trapIcon.position.x = trapButton.position.x - trapButton.size.width/2 - 20
        trapIcon.position.y = trapButton.position.y
        trapIcon.zPosition = 23
        self.addChild(trapIcon)
        
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
        let pod = SKSpriteNode(imageNamed: "myman")
        pod.setScale(0.7)
        pod.zPosition = 19
        pod.position.x = player.position.x
        pod.position.y = player.position.y + 30
        var playerTextures:[SKTexture] = []
        for i in 0...1 {
            playerTextures.append(SKTexture(imageNamed: "myman\(i)"))
        }
        let playerAnimation = SKAction.repeatActionForever( SKAction.animateWithTextures(playerTextures, timePerFrame: 0.3))
        pod.runAction(playerAnimation)
        
        self.addChild(pod)
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
           gunner = true
        }
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(1.3), invaderhit: 0, animprefix:"soldierrun", name:"invader", gunner: gunner, atlas: soldieratlas)
        tempInvader.zPosition = 6
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-84
        tempInvader.physicsBody?.velocity = CGVectorMake(-40,0)
        tempInvader.physicsBody?.mass = 10000
        tempInvader.physicsBody?.affectedByGravity = false
        tempInvader.physicsBody?.allowsRotation = false
    }
    
    func setupSpeeder(){
        var random = randRange(0, upper: 2)
        NSLog(String(random))
        var gunner = false
        if(random == 0){
            //gunner = true
        }
        let tempInvader:Invader = Invader(scene: self,scale: CGFloat(0.7), invaderhit: 0, animprefix:"soldierrun", name:"invader", gunner: gunner, atlas: soldieratlas)
        tempInvader.zPosition = 6
        tempInvader.position.x = self.size.width
        tempInvader.position.y = self.size.height/2-94
        tempInvader.physicsBody?.velocity = CGVectorMake(-80,0)
        tempInvader.physicsBody?.mass = 10000
        tempInvader.physicsBody?.affectedByGravity = false
        tempInvader.physicsBody?.allowsRotation = false
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
        let shortwait = SKAction.waitForDuration(2, withRange: 1)
        let medwait = SKAction.waitForDuration(4, withRange: 1)
        let endlevelwait = SKAction.waitForDuration(12)
        let betweenwaveswait = SKAction.waitForDuration(9)
        
        let spawnNormal = SKAction.runBlock(){
            self.setupEnemy()
        }
        
        let spawnHeavy = SKAction.runBlock(){
            self.setupHeavyEnemy()
        }
        
        let spawnSpeeder = SKAction.runBlock(){
            self.setupSpeeder()
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
        
        let spawnRandom1 = SKAction.runBlock(){
            var random = self.randRange(0, upper: 2)
            if(random == 1 || random == 2){
                self.setupEnemy()
            }else{
                self.setupSpeeder()
            }
        }
        
        let spawnAndWait = SKAction.repeatAction(SKAction.sequence([spawnNormal,shortwait]), count: numEnemy)
        let spawnAndWaitHeavy = SKAction.repeatAction(SKAction.sequence([spawnHeavy,shortwait]), count: numEnemy)
        let spawnAndWaitSpeeder = SKAction.repeatAction(SKAction.sequence([spawnSpeeder,shortwait]), count: numEnemy)
        let spawnAndWaitZombie = SKAction.repeatAction(SKAction.sequence([spawnZombie,shortwait]), count: numEnemy)
        let spawnAndWaitRandomNS = SKAction.repeatAction(SKAction.sequence([spawnRandom1,shortwait]), count: numEnemy)
        
        var spawnAndWaitRandomNH = SKAction.repeatAction(SKAction.sequence([spawnRandom,medwait]), count: numEnemy)
        if(self.level == 2){
            spawnAndWaitRandomNH = SKAction.repeatAction(SKAction.sequence([spawnRandom1,medwait]), count: numEnemy)
        }
        
        let actionArr = [betweenwaveswait,spawnAndWait,betweenwaveswait, spawnAndWait ,betweenwaveswait, spawnAndWaitRandomNH, endlevelwait]
        
        self.runAction(SKAction.repeatAction(SKAction.sequence(actionArr), count: 1), completion:{
            self.gameOver(true)
            
        })
        
    }
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        touching = true
        var turretLimit = 4
        var weaponCap  = self.weaponCap //meaning +1 weapons - all weapons  = 8
        var trapCap = 4 //meaning +1 traps
        let touchLocation = touch.locationInNode(self)
        touchx = touchLocation.x
        touchy = touchLocation.y
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        //NSLog(touchedNode.name!)
        if(placeSpikeMode && touchedNode.name == "grass"){
            self.removeFlashText()
            trapLabel.text = "spikes placed!";
            self.points = self.points - costSpikeTrap
            self.flashText("-"+String(costSpikeTrap)+" points", x: trapIcon.position.x, y: trapIcon.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
            placeSpikeTrap(touchx, y: touchedNode.position.y+10)
            placeSpikeMode  =  false
        }
       else if(placeMudMode){
            self.removeFlashText()
            trapLabel.text = "Gravity field";
            flashText("press T to place", x: trapLabel.position.x, y: trapLabel.position.y - 10, z: 22, waitDur: 5, color: SKColor.whiteColor())
            
            placeMud(touchx, y: touchy)
            
            placeMudMode  = false
        }else
            
            if(placeTurretMode && touchedNode.name == "dock" && touchy < self.size.height - 5){
                self.removeFlashText()
                numTurretsOnField++
                self.flashText("turret placed!", x: touchx, y: touchedNode.position.y - 30, z: 30, waitDur: 2, color: SKColor.greenColor())
                trapLabel.text = "Turret";
                flashText("press T to place", x: trapLabel.position.x, y: trapLabel.position.y - 10, z: 22, waitDur: 5, color: SKColor.whiteColor())
               
                setupTurret(touchx, y: touchy)
                self.points = self.points - costTurret
                
                self.flashText("-"+String(costTurret)+" points", x: trapIcon.position.x, y: trapIcon.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                placeTurretMode = false
                numTurrets++
            }else if(touchedNode.name == "turret"){
                let turret = touchedNode as! Ally
                self.points = self.points + self.costTurret -  50
                turret.removeFromParent()
                turret.removeTurRad()
                
            }else
                if(touchedNode.name == "nexttrap"){
                    touching = false
                    trapLabel.fontColor = SKColor.whiteColor()
                    trap++
                    
                    
                    if(trap == 3){
                        trapIcon.setScale(0.3)
                        trapIcon.texture = SKTexture(imageNamed: "field0")
                        placeTurretMode = false
                        
                        
                        trapLabel.text = "gravity field";
                       
                    self.removeFlashText()
                         flashText("press T to place", x: trapLabel.position.x, y: trapLabel.position.y - 10, z: 22, waitDur: 5, color: SKColor.whiteColor())
                        
                        flashTextLeftAlignSc("info: radial gravity field affecting only enemy bullets", x: self.size.width*0.3, y: 10, z: 22, waitDur: 5, color: SKColor.whiteColor(), fontsize: 13)
                    }
                    if(trap == 2){
                        trapIcon.setScale(0.3)
                        trapIcon.texture = SKTexture(imageNamed: "turret")
                        
                        
                        
                        if(numTurrets < turretLimit){
                           
                       self.removeFlashText()
                            self.indicateNode(self.dock, waitf: 0.2)
                             trapLabel.text = "Turret";
                            flashText("press T to place", x: trapLabel.position.x, y: trapLabel.position.y - 10, z: 22, waitDur: 5, color: SKColor.whiteColor())
                            flashTextLeftAlignSc("info: place turret on dock upper left corner", x: self.size.width*0.3, y: 10, z: 22, waitDur: 5, color: SKColor.whiteColor(), fontsize: 13)
                        }else{
                            trapLabel.text = "turret Limit:" + String(turretLimit);
                        }
                        
                    }
                    if(trap == 1){
                        trapIcon.setScale(0.3)
                        trapIcon.texture = SKTexture(imageNamed: "saw3")
                        
                        trapLabel.text = "deathswing";
                    }
                    if(trap == 4){
                        trapIcon.setScale(0.3)
                        trapIcon.texture = SKTexture(imageNamed: "spikeicon")
                         placeMudMode = false
                        trapLabel.text = "Spike trap";
                        self.removeFlashText()
                        flashText("press T to place", x: trapLabel.position.x, y: trapLabel.position.y - 10, z: 22, waitDur: 5, color: SKColor.whiteColor())
                        flashTextLeftAlignSc("info: place spike trap on the ground", x: self.size.width*0.3, y: 10, z: 22, waitDur: 5, color: SKColor.whiteColor(), fontsize: 15)
                    }
                    if(trap > trapCap || trap == 0){
                        self.removeFlashText()
                        let arrow = SKSpriteNode(imageNamed: "darrow1.png")
                        self.addChild(arrow)
                        arrow.zPosition = 34
                        arrow.position.x = self.size.width*0.2
                        arrow.position.y = self.size.height*0.88
                        arrow.setScale(0.25)
                        self.flashAndremoveNode(arrow)
                        placeMudMode = false
                        placeSpikeMode = false
                        trapIcon.setScale(0.4)
                        trapIcon.texture = SKTexture(imageNamed: "rock1")
                        trapLabel.text = "rock fall";
                        flashText("press T deploy", x: trapLabel.position.x, y: trapLabel.position.y - 10, z: 22, waitDur: 5, color: SKColor.whiteColor())
                        flashTextLeftAlignSc("info: rocks will fall from the dock", x: self.size.width*0.3, y: 10, z: 22, waitDur: 5, color: SKColor.whiteColor(), fontsize: 13)
                        trap = 0
                        
                    }
                }
                    
                else if(touchedNode.name == "nwbutton"){
                    runAction(beepSound)
                    //let flameNode = PlayerBullet(imageName: "floor", bulletSound: nil, scene: self, bulletName: "floornode")
                    touching = false
                    weapon++
                    if(weapon > weaponCap)
                    {
                        weaponIcon.setScale(0.13)
                        weaponIcon.texture = SKTexture(imageNamed: "pistol")
                        
                        if(flamerOn){
                            removeActionForKey("flamer")
                            flameEmmiter.removeFromParent()
                            flameNode.removeFromParent()
                            flamerOn = false
                        }
                        if(machineGunMode){
                            player.setClipSize(32)
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
                        weaponIcon.setScale(0.1)
                        weaponIcon.texture = SKTexture(imageNamed: "fpistol")
                        player.setClipSize(9)
                        player.setShotsFired(8)
                        weaponLabel.text = "fastpistol"
                    }
                    if(weapon == 2){
                        weaponIcon.setScale(0.12)
                        weaponIcon.texture = SKTexture(imageNamed: "Bow")
                        player.setClipSize(16)
                        player.setShotsFired(15)
                        weaponLabel.text = "bow"
                    }
                    
                    if(!flamerOn && weapon == 3){
                        weaponIcon.setScale(0.13)
                        weaponIcon.texture = SKTexture(imageNamed: "flamer1")
                        
                        self.runFlamer()
                        flamerOn = true
                        weaponLabel.text = "flamer"
                      
                    }
                    
                    if(weapon == 4){
                        player.setClipSize(2)
                        player.setShotsFired(1)
                        if(flamerNodesPresent){
                            self.flameNode.removeFromParent()
                            self.flameEmmiter.removeFromParent()
                        }
                        self.removeActionForKey("flamersound")
                        self.removeActionForKey("flamer")
                        
                        weaponIcon.setScale(0.14)
                      
                        weaponIcon.texture = SKTexture(imageNamed: "shotg")
                        weaponLabel.text = "shotgun"
                        
                       
                        flamerOn = false
                        
                        //shotgun
                    }
                    if(weapon == 5){
                        weaponIcon.setScale(0.13)
                        weaponIcon.texture = SKTexture(imageNamed: "machinegun")
                        weaponLabel.text = "machinegun"
                        machineGunMode = true
                    }
                    if(weapon == 6){
                        weaponIcon.setScale(0.16)
                        weaponIcon.texture = SKTexture(imageNamed: "cb1")
                        weaponLabel.text = "auto-crossbow"
                        machineGunMode = false
                        autoCrossBow = true
                    }
                    if(weapon == 7){
                        weaponIcon.setScale(0.1)
                        weaponIcon.texture = SKTexture(imageNamed: "ashotgun")
                        weaponLabel.text = "auto-shotgun"
                        autoCrossBow = false
                        autoShottie = true
                    }
                    if(weapon == 8){
                        player.setClipSize(2)
                        player.setShotsFired(1)
                        weaponIcon.setScale(0.14)
                        weaponIcon.texture = SKTexture(imageNamed: "nader")
                        weaponLabel.text = "nader"
                        autoShottie = false
                    }
                    // NSLog("buttonpressed"+String(weapon))
                }else if(touchedNode.name == "trapbtn"){
                    enumerateChildNodesWithName("flash") { node, stop in
                        
                        node.removeFromParent()
                    }
                    enableTrapDoor = true
                    if(trap == 0){
                        //rock fall
                        if(self.points >= 30){
                            
                            self.points = self.points - 30
                            self.flashText("-30 points", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                            
                            spikeFall()
                        }else{
                            
                            self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                        }
   
                    }else if(trap == 1){
                        //saw swing
                        
                        if(self.points >= 60){
                            
                            self.points = self.points - 60
                            self.flashText("-60 points", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                            
                            swingingSpikeBall()
                        }else{
                            
                            self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                        }
                    }else if(trap == 2){
                        //turret
                        if(numTurrets < turretLimit){
                            if(self.points >= costTurret){
                                
                                
                                placeTurretMode = true
                                trapLabel.text = "touch to place";
                                flashTextLeftAlignSc("info: place turret on dock upper left corner", x: self.size.width*0.3, y: 10, z: 22, waitDur: 5, color: SKColor.whiteColor(), fontsize: 13)
                            }else{
                                
                                self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                            }

                        }else{
                            trapLabel.text = "turret Limit:" + String(turretLimit);
                        }
                        
                    }else if(trap == 3){
                        //Gfield
                        if(self.points >= 20){
                            
                            self.points = self.points - 20
                            trapLabel.text = "touch to place";
                            self.flashText("-20 points", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.yellowColor())
                            placeMudMode = true
                        }else{
                            
                            self.flashText("no funds!", x: touchedNode.position.x, y: touchedNode.position.y - 50, z: 10, waitDur: 2, color: SKColor.redColor())
                        }
                    }else if(trap == 4){
                        //spike trap
                        if(self.points >= costSpikeTrap){
                            
                            
                            trapLabel.text = "touch to place";
                              flashTextLeftAlignSc("info: place spike trap on the ground", x: self.size.width*0.3, y: 10, z: 22, waitDur: 5, color: SKColor.whiteColor(), fontsize: 15)
                            
                            placeSpikeMode = true
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
                    var canFireWait = 0.2
                    var multiShot = false
                    var clipsize = 9
                    if(weapon == 0){
                        multiShot = false
                        bulletName = "bullet"
                        bulletTexture = "ball"
                        var bulletScale = 0.4
                        speedMultiplier = CGFloat(0.001)
                        bulletSound = "gunshot.mp3"
                        canFireWait = 0.6
                        clipsize = 9
                    }
                    if(weapon == 2){
                        bulletName = "arrow"
                        bulletTexture = "ArrowTexture"
                        bulletScale = 0.4
                        speedMultiplier = CGFloat(0.004)
                        bulletSound = "arrowfire.mp3"
                        canFireWait = 0.7
                        clipsize = 16
                    }
                    if(weapon == 4){
                        //shotgun
                        bulletName = "shell"
                        bulletTexture = "ball"
                        var bulletScale = 1
                        speedMultiplier = CGFloat(0.0007)
                        bulletSound = "shotgunsound.mp3"
                        canFireWait = 2
                        multiShot = true
                    }
                    
                    if(weapon == 8){
                        multiShot = false
                        bulletName = "nade"
                        bulletTexture = "ball"
                        bulletScale = 1
                        speedMultiplier = CGFloat(0.0005)
                        bulletSound = "gunshot.mp3"
                        canFireWait = 0.8
                        clipsize  = 2
                    }
                    if(!flamerOn && !machineGunMode && !autoCrossBow && !autoShottie){
                        player.fireBullet(self, touchX:touchLocation.x, touchY:touchLocation.y, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName, atlas: mainatlas, clipsize: clipsize)
                        
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
    func countDown(){
        var num = 3
         let flashNum = SKAction.runBlock(){
            self.flashTextLeftAlignSc("ready in ", x: self.player.position.x-20, y: self.player.position.y + 30, z: 40, waitDur: 1.2, color: SKColor.whiteColor(), fontsize: 10)
            self.flashTextLeftAlignSc(String(num), x: self.player.position.x+27, y: self.player.position.y + 30, z: 40, waitDur: 0.5, color: SKColor.whiteColor(), fontsize: 10)
            
        }
        let wait = SKAction.waitForDuration(1)
        let decrease = SKAction.runBlock(){
            
            num--
        }
     
        runAction(SKAction.repeatAction(SKAction.sequence([flashNum,wait, decrease]), count: 3))
        
    }
    
    func runFlamer(){
        let switchOn = SKAction.runBlock(){
            self.runAction(self.flamerSound, withKey:"flamersound")
            //runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("flamergoing.wav", waitForCompletion: false)), withKey: "flamer")
            self.flameNode.hidden = true
            self.flameNode.position.x = self.player.position.x
            self.flameNode.position.y = self.player.position.y
            self.flameNode.AddPhysics(self, dynamic: false)
            self.flameEmmiter.zPosition = 3
            
            self.addChild(self.flameEmmiter)
            self.flameEmmiter.position.x = self.player.position.x
            self.flameEmmiter.position.y = self.player.position.y
            self.flamerNodesPresent = true
        }
        
        let switchOff = SKAction.runBlock(){
            self.countDown()
            //runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("flamergoing.wav", waitForCompletion: false)), withKey: "flamer")
            self.flameEmmiter.removeFromParent()
            self.flameNode.removeFromParent()
            self.flamerNodesPresent = false
        }
        let wait = SKAction.waitForDuration(6)
        let reload = SKAction.waitForDuration(3)
        let seq = SKAction.sequence([switchOn,wait,switchOff,reload])
        self.runAction(SKAction.repeatActionForever(seq), withKey: "flamer")
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
       
        let touch = touches.first as! UITouch
        touching = true
        var weaponCap  = 4
        let touchLocation = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(touchLocation)
        if(touchedNode.name == "nwbutton"){
             touching = false
        }
        touchx = touchLocation.x
        touchy = touchLocation.y
  
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        touching = false
        movingR = false
        movingL = false
    }
    
    override func update(currentTime: CFTimeInterval) {
        //color changing of trap labels
        if(trap == -1){
              trapLabel.fontColor = SKColor.yellowColor()
        }else
        if(self.points >= costTurret && trap == 2){ //turret
            trapLabel.fontColor = SKColor.greenColor()
        }else if(self.points >= 60 && trap == 1){ //swing
            trapLabel.fontColor = SKColor.greenColor()
        }else if(self.points >= 30 && trap == 0){ //rocks
            trapLabel.fontColor = SKColor.greenColor()
        }else if(self.points >= 20 && trap == 3){ //gfield
            trapLabel.fontColor = SKColor.greenColor()
        }else if(self.points >= costSpikeTrap && trap == 4){ //spike trap
            trapLabel.fontColor = SKColor.greenColor()
        } else{
            trapLabel.fontColor = SKColor.redColor()
        }
        if(self.points < 0){
            self.points = 0
        }
        pointsLabel.text = "Points:" + String(points)
        hits = 0
        allyhits = 0
        ammo = player.getclipSize() - player.getShotsFired()
        if(!flamerOn){
        if(ammo == 0){
             ammoLabel.text = "reloading..."
        }else{
             ammoLabel.text = "ammo: " + String(ammo)
        }
        }else{
            ammoLabel.text = ""
        }
      
        moveInvaders()
        if(touching){
            rotateGunToTouch()
        }
        if(machineGunMode){
            self.fireMachineGun("machinegun.wav", scale: 0.4, bulletTexture: "bullet", bulletName: "mbullet", speedMulti: 0.002, multiShot: false,canFireWait: 0.2)
        }
        if(autoCrossBow){
            self.fireMachineGun("arrowfire.mp3", scale: 0.4, bulletTexture: "ArrowTexture", bulletName: "arrow", speedMulti: 0.003, multiShot: false, canFireWait: 0.2)
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
            player.fireBullet(self, touchX:touchx, touchY:touchy, bulletTexture: bulletTexture, bulletScale: bulletScale, speedMultiplier: speedMultiplier, bulletSound: bulletSound, canFireWait: canFireWait, multiShot: multiShot, bulletName: bulletName, atlas: mainatlas, clipsize: 32)
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
        node.addChild(fieldNode)
        //node.addChild(vortex)
        fieldNode.strength =  4
        fieldNode.falloff = 1
        self.waitAndRemove(node, wait: 10)
        
    }
    
    func placeSpikeTrap(x: CGFloat,y: CGFloat){
        let node = SKSpriteNode(imageNamed: "spikes4")
        node.setScale(0.15)
        self.addChild(node)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 5, height: 30))
        //node.zRotation = node.zRotation - 180 * DegreesToRadians
        node.physicsBody?.categoryBitMask = CollisionCategories.Spikes
        node.physicsBody?.contactTestBitMask = CollisionCategories.Invader
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 0
      
        node.name = "spikes"
        
        node.physicsBody?.fieldBitMask = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.position.x = x
        node.position.y = y
        node.zPosition = 19
     
        let sound = SKAction.playSoundFileNamed("spikesound.mp3", waitForCompletion: false)
        let erect = SKAction.moveTo(CGPoint(x:x, y: y + 10), duration: 0.1)
        let retract = SKAction.moveTo(CGPoint(x:x, y: y), duration: 0.1)
        let wait = SKAction.waitForDuration(0.7)
        let pullSpike = SKAction.sequence([sound,erect,wait,retract, wait])
        node.runAction(SKAction.repeatAction(pullSpike, count: 20))
        self.waitAndRemove(node, wait: 30)
        
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
        let rock1 = ScenePiece(pieceName: "rocks", textTureName: "rock1", dynamic: true, scale: randRangeFrac(4, upper: 8),x : CGFloat( randRange(60, upper: 150)),y: self.size.height - 40)
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
                invader.fireBullet(self, touchX: self.player.position.x, touchY: self.player.position.y + CGFloat(self.randRange(0, upper: 80)), bulletTexture: "ball", bulletScale: 1, speedMultiplier: CGFloat(0.001), bulletSound: "gunshot2.wav", canFireWait: 1.5, multiShot: false, bulletName: "invaderbullet", atlas: self.mainatlas)
            }
        }
        
    }
    
    
    
    override func didSimulatePhysics() {
        enumerateChildNodesWithName("invaderbullet") { node, stop in
            let bullet = node as! EnemyBullet
            if(bullet.position.y > self.size.height - 10 || bullet.position.y < 0 + 30 || bullet.position.x > self.size.width + 100 || bullet.position.x < -5 ){
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
                    self.gameOver(false)
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
        tempL.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
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
    
    func flashTextLeftAlignSc(text: String, x: CGFloat,y: CGFloat, z: CGFloat, waitDur: Double, color:SKColor,fontsize: CGFloat
        ){
        let tempL = SKLabelNode(fontNamed: "COPPERPLATE")
        tempL.fontColor = color
        tempL.text = text;
        tempL.name = "flash"
        tempL.position.x = x
        tempL.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        tempL.position.y = y
        tempL.zPosition = z
        tempL.fontSize = fontsize
        self.addChild(tempL)
        let fadein = SKAction.fadeInWithDuration(0.1)
        let fadeout = SKAction.fadeOutWithDuration(0.2)
        let wait = SKAction.waitForDuration(waitDur)
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
        self.points = self.points + numTurretsOnField*400
        let scene = GameOver(size: self.size, points: self.points,ef: EnemyFreq, level: self.level, ne:self.numEnemyInWave, win: win, weaponCap: self.weaponCap)
        let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
        self.view?.presentScene(scene, transition: transitionType)
        
    }
    
    func addAndRemoveEmitter(wait: Double, x: CGFloat,y: CGFloat, fileName:String,zPos: CGFloat){
        let node = SKEmitterNode(fileNamed: fileName)
        
    
        node.zPosition = 7
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
        node.runAction(seq)
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
        self.runAction(nadeSound)
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
    
    func removeFlashText(){
        
        enumerateChildNodesWithName("flash") { node, stop in
            
            node.removeFromParent()
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
                        runAction(hitSound)
                       // NSLog(secondBody.node!.name!)
                        if(secondBody.node?.name == "shell"){
                            invaderObj.hit(invaderObj.gethit()+3)
                        }else if(secondBody.node?.name == "mbullet"){
                            invaderObj.hit(invaderObj.gethit()+1)
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
                            bullet.texture = SKTexture(imageNamed: "AHT.png")
                        }
                        
                        if(contactPoint.y > invaderObj.position.y){
                            invaderObj.hit(invaderObj.gethit()+1)
                            self.points = self.points + 1
                            self.flashTextSc("headshot! +1", x: invaderObj.position.x-5, y: invaderObj.position.y + invaderObj.size.height*0.5, z: 10, waitDur: 0.2, color: SKColor.greenColor(),scale: 9)
                        }
                        
                        if(secondBody.node?.name == "nade"){
                            let myJoint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor:CGPointMake(contactPoint.x, contactPoint.y))
                            self.physicsWorld.addJoint(myJoint)
                         
                            let waitToEnableFire = SKAction.waitForDuration(2)
                            runAction(waitToEnableFire,completion:{
                                self.runAction(self.nadeSound)
                                let sparkEmmiter = SKEmitterNode(fileNamed: "exp.sks")
                                let blood = SKEmitterNode(fileNamed: "heavyblood.sks")
                                sparkEmmiter.zPosition = 20
                                blood.zPosition = 20
                                firstBody.node?.addChild(sparkEmmiter)
                                firstBody.node?.addChild(blood)
                                secondBody.node?.removeFromParent()
                                
                                var splat = SKSpriteNode(texture: SKTexture(imageNamed: "BS"))
                                var ran = self.randRange(0, upper: 1)
                                splat.setScale(self.randRangeFrac(3, upper: 4))
                                if(ran == 1){
                                    splat = SKSpriteNode(texture: SKTexture(imageNamed: "BS2"))
                                     splat.setScale(self.randRangeFrac(4, upper: 6))
                                }
                                
                                splat.zPosition = 19
                                
                                splat.position.x = invaderObj.position.x
                                splat.position.y = invaderObj.position.y - 20 + CGFloat(self.randRange(0, upper: 10))
                                self.addChild(splat)
                                let waitforsplat = SKAction.waitForDuration(1)
                                self.runAction(waitforsplat,completion:{
                                    
                                   splat.removeFromParent()
                                    // secondBody.node?.removeFromParent()
                                })
                                let bomb = SKNode()
                                firstBody.node?.addChild(bomb)
                                bomb.physicsBody = SKPhysicsBody(circleOfRadius: 60)
                               // bomb.physicsBody?.velocity = firstBody.velocity
                                bomb.physicsBody?.dynamic = true
                                bomb.physicsBody?.pinned = true
                                bomb.physicsBody?.mass  = 0
                                bomb.zPosition = 56
                                bomb.physicsBody?.categoryBitMask = CollisionCategories.ScenePiece
                                bomb.physicsBody?.contactTestBitMask = CollisionCategories.Invader
                                 bomb.physicsBody?.collisionBitMask = 0
                                bomb.name = "bombnode"
                               
                                self.waitAndRemove(bomb, wait: 2)
                                self.waitAndRemove(sparkEmmiter, wait: 0.5)
                                self.waitAndRemove(blood, wait: 0.3)
                                let waitforblood = SKAction.waitForDuration(0.3)
                            
                                self.runAction(waitforblood,completion:{

                                    invaderObj.hit(invaderObj.gethit()+40)
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
                        runAction(hitSoundHeavy)
                        self.addAndRemoveEmitter(0.3, x: contactPoint.x, y: contactPoint.y, fileName: "spark.sks",zPos:3)
                        let invaderObj = firstBody.node as! Invader
                        invaderObj.hit(invaderObj.gethit()+1)
                        if(invaderObj.gethit() == 5){
                            let smoke = SKEmitterNode(fileNamed: "smoke")
                            smoke.zPosition = 3
                            firstBody.node?.addChild(smoke)
                        }
                        if(invaderObj.gethit() == 8){
                            
                            self.flashTextSc("armour destroyed +2", x: invaderObj.position.x-10, y: invaderObj.position.y + invaderObj.size.height*0.25, z: 10, waitDur: 0.3, color: SKColor.yellowColor(), scale: 10)
                            self.points = self.points + 2
                            self.flashAndremoveNode(invaderObj)
                            self.runAction(nadeSound)
                            self.addAndRemoveEmitter(0.5, x: invaderObj.position.x, y: invaderObj.position.y, fileName: "exp.sks", zPos: 20)
                            let waitToEnableFire = SKAction.waitForDuration(0.3)
                            runAction(waitToEnableFire,completion:{
                                self.setupEnemyAt(invaderObj.position.x, y: invaderObj.position.y-10, speed: -50, scale: 1)
                                
                            })
                            
                        }
                    }//end heavy
                    if(firstBody.node?.name == "zombie"){
                        runAction(hitSoundHeavy)
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
        

        if ((firstBody.categoryBitMask & CollisionCategories.Player != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Invader != 0)) {
                firstBody.node?.removeFromParent()
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.PlayerBullet != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.floor != 0)) {
                
                let contactPoint = contact.contactPoint
                self.addAndRemoveEmitter(0.2, x: contactPoint.x, y: contactPoint.y + 10, fileName: "dirt.sks",zPos: 3)
                
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
                    
                    
                    self.waitAndRemove(firstBody.node!, wait: 0.01)
                    let waitToEnableFire = SKAction.waitForDuration(2)
                    runAction(waitToEnableFire,completion:{
                        self.runAction(self.nadeSound)
                        //self.physicsWorld.removeJoint(myJoint)
                        let bomb = SKNode()
                        bomb.position.x = contactPoint.x
                        bomb.position.y = contactPoint.y
                        self.addChild(bomb)
                        bomb.physicsBody = SKPhysicsBody(circleOfRadius: 60)
                        bomb.physicsBody?.dynamic = false
                       // bomb.physicsBody?.pinned = true
                        bomb.physicsBody?.mass  = 0
                        bomb.physicsBody?.categoryBitMask = CollisionCategories.ScenePiece
                        bomb.physicsBody?.contactTestBitMask = CollisionCategories.Invader
                        bomb.physicsBody?.collisionBitMask = 0
                        bomb.zPosition = 43
                        bomb.name = "bombnode"
                        self.waitAndRemove(bomb, wait: 0.4)
                        self.addAndRemoveEmitter(1.5, x: contactPoint.x, y: contactPoint.y + 10, fileName: "exp.sks", zPos: 3)
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
                    if(player.gethit() > 30){
                        self.flashAndremoveNode(player)
                        self.gameOver(false)
                        NSLog("PLayer dead")
                    }
                }
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.EnemyBullet != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Ally != 0)) {
                self.allyhits++
                if(allyhits == 1){
                    let turret = secondBody.node as! Ally
                    turret.hit(turret.gethit()+1)
                    if(turret.gethit() > 3){
                        self.flashAndremoveNode(turret)
                        turret.removeTurRad()
                        self.waitAndRemove(firstBody.node!, wait: 0.02)
                    }
                }
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Spikes != 0)) {
                let contactPoint = contact.contactPoint
                if(secondBody.node?.name == "spikes"){
                    let invaderObj = firstBody.node as! Invader
                    if(firstBody.node?.name == "invader"){
                        runAction(hitSound)
                        invaderObj.hit(invaderObj.gethit()+4)
                        self.addAndRemoveEmitter(0.3, x: contactPoint.x, y: contactPoint.y, fileName: "blood.sks", zPos: 24)
                        if(invaderObj.gethit() >= self.invaderLife){
                            self.points = self.points + 5
                            firstBody.categoryBitMask = CollisionCategories.ScenePiece
                            self.flashText("+5", x: invaderObj.position.x, y: invaderObj.position.y + invaderObj.size.height*0.25, z: 10, waitDur: 0.3, color: SKColor.yellowColor())
                            self.flashAndremoveNode(invaderObj)
                        }
                    }
                }
                
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.floor != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.ScenePiece != 0)) {
                self.waitAndRemove(secondBody.node!, wait: 0.3)
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.ScenePiece != 0)) {
                let contactPoint = contact.contactPoint
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
                    self.flashText("+5", x: invaderObj.position.x, y: invaderObj.position.y + invaderObj.size.height*0.25, z: 10, waitDur: 0.3, color: SKColor.yellowColor())
                    invaderObj.addChild(blood)
                    self.flashAndremoveNode(invaderObj)
                   
                }
                
                if(secondBody.node?.name == "mud"){
                    let invaderObj = firstBody.node as! Invader
                    invaderObj.physicsBody?.velocity = CGVectorMake(-20, 0)
                    secondBody.node?.removeFromParent()
                }
                
                if(secondBody.node?.name == "rocks"){
                    runAction(smashSound)
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
                    runAction(sliceSound)
                    let contactPoint = contact.contactPoint
                    self.addAndRemoveEmitter(0.3, x: contactPoint.x, y: contactPoint.y, fileName: "heavyblood.sks", zPos: 14)
                    
                  
                    let playerAnimation = SKAction.animateWithTextures(self.slicedTex, timePerFrame: 0.1)
                    firstBody.node?.runAction(playerAnimation, completion:{
                        self.removeNode(firstBody.node!)
                    })
                    self.physicsWorld.removeAllJoints()
                }
        }
        
    }
    
}


