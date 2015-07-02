//
//  GameOver.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/22.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//


import SpriteKit
import AVFoundation

class GameOver: SKScene {
    
    var coinSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("BGmusic", ofType: "mp3")!)
    var Disson = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Dissonance", ofType: "mp3")!)
    var ocean = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ocean", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    var text = ""
    var points = UInt32(0)
    var EnemyFreq = Double(0)
    var level = UInt32(0)
    var ne = Int(0)
    var win = false
    var weaponCap = 0
    init(size: CGSize, points: UInt32, ef: Double, level: UInt32, ne: Int, win: Bool, weaponCap:  Int){
       //  text = String(points)
        super.init(size: size)
        self.points = points
        self.EnemyFreq = ef - 0.5
        self.level = level + 1
        self.ne = ne + 1
        self.win = win
        if(self.level == 2){
            self.weaponCap = weaponCap
        }else{
            self.weaponCap = weaponCap + 1
        }
      
    }
    


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        audioPlayer = AVAudioPlayer(contentsOfURL: Disson, error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        let btnL = SKLabelNode(fontNamed: "COPPERPLATE")
        let gameLabel = SKLabelNode(fontNamed: "COPPERPLATE")
        let unlocks = SKLabelNode(fontNamed: "COPPERPLATE")
        if(self.win){
             gameLabel.text = "Level Complete"
             btnL.text = "Continue"
        }else{
            gameLabel.text = "Game Over"
             btnL.text = "Restart"
        }
        if(weaponCap == 1){
            unlocks.text = "unlocked fast pistol"
        }
        
        if(weaponCap == 2){
            unlocks.text = "unlocked bow"
        }
        
        if(weaponCap == 3){
            unlocks.text = "unlocked flamer"
        }
        
        if(weaponCap == 4){
            unlocks.text = "unlocked shotgun"
        }
        
        if(weaponCap == 5){
            unlocks.text = "unlocked machinegun"
        }
        
        if(weaponCap == 6){
            unlocks.text = "unlocked auto-crossbow"
        }
        backgroundColor = SKColor.blackColor() //add background
        unlocks.fontSize = 20
        unlocks.position = CGPoint(x:self.size.width*0.5,y:self.size.height*0.4)
        addChild(unlocks)
       
        gameLabel.fontSize = 30
        gameLabel.position = CGPoint(x:self.size.width/2,y:self.size.height*0.75)
        addChild(gameLabel)
        
        let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
        pointsLabel.text = "Points:" + String(points)
        pointsLabel.position = CGPoint(x:self.size.width/2,y:self.size.height*0.6)
        addChild(pointsLabel)
        
        
        btnL.zPosition = 2
        btnL.position = CGPointMake(size.width/2,size.height/2 - 100)
        addChild(btnL)
     
        
        let startGameButton = SKSpriteNode(imageNamed: "gameover")
        startGameButton.position = CGPointMake(size.width/2,size.height/2 - 100)
        startGameButton.hidden = true
        startGameButton.name = "restart" //add reference to the button.
        startGameButton.zPosition = 4
        addChild(startGameButton) //add button to scene   
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self) //all touches in screen
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        if(touchedNode.name == "restart"){
            audioPlayer.stop()
            var gameOverScene = GameScene(size: size, points:self.points, ef:EnemyFreq, level:level, numEnemy: self.ne, weaponCap: self.weaponCap)
            if(self.win){
               gameOverScene = GameScene(size: size, points:self.points, ef:EnemyFreq, level:level, numEnemy: self.ne, weaponCap: self.weaponCap)            }else{
                self.ne--
                gameOverScene = GameScene(size: size, points:self.points, ef:EnemyFreq, level:level, numEnemy : self.ne, weaponCap: self.weaponCap)
            }
             //make next scene
            gameOverScene.scaleMode = scaleMode
            let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
            view?.presentScene(gameOverScene,transition: transitionType) //move to the next scene
        }
    }//dfdf
    
    
   
}
