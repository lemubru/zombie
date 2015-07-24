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
    let HS = HighScoreManager()
    var highscoreMode = false
    var weaponCap = 0
    let HSL = SKLabelNode(fontNamed: "COPPERPLATE")
    
    var txtfield = UITextField()
    init(size: CGSize, points: UInt32, ef: Double, level: UInt32, ne: Int, win: Bool, weaponCap:  Int){
            //  text = String(points)
        super.init(size: size)
        
        txtfield = UITextField(frame: CGRect(x: self.size.width*0.9, y: self.size.height * 0.6, width: 200.00, height: 40.00))

        self.points = points
        self.EnemyFreq = ef - 0.5
        self.level = level
        self.ne = ne + 1
        self.win = win
        txtfield.hidden = true
        self.weaponCap = weaponCap
      
      
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        var donebtn = UIButton(frame: CGRect(x: self.size.width*0.9, y: self.size.height * 0.6, width: 100.00, height: 40.00))
        txtfield.placeholder = "enter name here"

        txtfield.center = view.center;
        txtfield.borderStyle = UITextBorderStyle(rawValue: 1)!
        txtfield.textColor = UIColor.blackColor()

        txtfield.backgroundColor = UIColor.whiteColor()
      
        view.addSubview(txtfield)
        
        let btnL = SKLabelNode(fontNamed: "COPPERPLATE")
        let gameLabel = SKLabelNode(fontNamed: "COPPERPLATE")
        let unlocks = SKLabelNode(fontNamed: "COPPERPLATE")
        
        gameLabel.fontSize = 45
        gameLabel.position = CGPoint(x:self.size.width/2,y:self.size.height*0.75)
        addChild(gameLabel)
     
        audioPlayer = AVAudioPlayer(contentsOfURL: Disson, error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
        pointsLabel.text = "Points:" + String(points)
        pointsLabel.position = CGPoint(x:self.size.width/2,y:self.size.height*0.6)
        pointsLabel.fontSize = 25
        addChild(pointsLabel)
        
       
      
        
       // HSL.text = "HighScore: Level " + String(self.HS.scores[0].getScore()) + "by" + self.HS.scores[0].getName()
        HSL.position = CGPoint(x:self.size.width/2,y:self.size.height*0.35)
        HSL.fontSize = 13
        addChild(HSL)
        
        
        if(win){
            self.level++
            self.weaponCap++
            gameLabel.fontSize = 30
            gameLabel.text = "Level Complete! +50 points"
            self.points = self.points + 50
            pointsLabel.text = "Points:" + String(points)
            btnL.text = "Continue"
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
            
        }else{ //loss
            self.points = 30
            gameLabel.text = "Game Over"
            btnL.text = "Restart"
      
            pointsLabel.text = "You reached level " + String(level)
            
                
        
            if(HS.scores.first == nil){
                HS.scores.append(HighScore(score: Int(0), dateOfScore: NSDate(), name: ""))
                txtfield.hidden = false
                highscoreMode  = true
                pointsLabel.text = "New highscore Level " + String(level)
              
            }else{
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                var dateString = dateFormatter.stringFromDate(HS.scores[0].getDate())//format style. Browse online to get a format that fits your needs.
                dateFormatter.timeStyle = .ShortStyle
                HSL.text = "Highscore: Level " + String(HS.scores[0].getScore()) + " by " + HS.scores[0].getName() + " date: " + dateString
                HSL.fontSize  = 16
            }
          

            if(Int(level) > HS.scores[0].getScore()){
                txtfield.hidden = false
                highscoreMode  = true
                pointsLabel.text = "New highscore Level " + String(level)
                
            }
       
            
            
           
            if(self.weaponCap < 1){
                self.weaponCap = 1
            }
            if(self.level < 1){
                self.level = 1
            }
            if(self.ne < 1){
                self.ne = 1
            }
        }
        unlocks.fontColor = SKColor.yellowColor()
        unlocks.fontSize = 20
        unlocks.position = CGPoint(x:self.size.width*0.5,y:self.size.height*0.43)
        addChild(unlocks)
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
        
        if(highscoreMode){
            if(txtfield.isFirstResponder()){
                self.txtfield.resignFirstResponder()
                HS.scores[0] = HighScore(score: Int(level), dateOfScore: NSDate(), name: txtfield.text)
                HS.save()
                txtfield.removeFromSuperview()
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle //format style. Browse online to get a format that fits your needs.
                dateFormatter.timeStyle = .ShortStyle
                var dateString = dateFormatter.stringFromDate(HS.scores[0].getDate())
                HSL.text = "Highscore: Level " + String(HS.scores[0].getScore()) + " by " + HS.scores[0].getName() + " date: " + dateString
                HSL.fontSize  = 16
            }
        }
        
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self) //all touches in screen
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        if(touchedNode.name == "restart"){
            audioPlayer.stop()
            var gameOverScene = GameScene(size: size, points:self.points, ef:EnemyFreq, level:level, numEnemy: self.ne, weaponCap: self.weaponCap)
            if(self.win){
                gameOverScene = GameScene(size: size, points:self.points, ef:EnemyFreq, level:level, numEnemy: self.ne, weaponCap: self.weaponCap)
            }else{//loss
                
                gameOverScene = GameScene(size: size, points:self.points, ef:EnemyFreq, level:level, numEnemy : self.ne, weaponCap: self.weaponCap)
            }
            //make next scene
            gameOverScene.scaleMode = scaleMode
            let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
            view?.presentScene(gameOverScene,transition: transitionType) //move to the next scene
        }
    }
    
    
   
}
