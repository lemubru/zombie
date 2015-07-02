import UIKit
import SpriteKit
import AVFoundation
class StartGameScene: SKScene {
   
    var coinSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Dissonance", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
 
    override func didMoveToView(view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "start")
        background.name = "BG"
        background.anchorPoint = CGPointMake(0, 1)
        background.position = CGPointMake(0, size.height)
        background.zPosition = 1
        background.size = CGSize(width: self.view!.bounds.size.width, height:self.view!.bounds.size.height)
        //addChild(background)
        
        audioPlayer = AVAudioPlayer(contentsOfURL: coinSound, error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
       // let playMusic = SKAction.playSoundFileNamed("BGmusic.mp3", waitForCompletion: false)
        //self.runAction(playMusic, withKey:"sound")
        backgroundColor = SKColor.blackColor() //add background
        let startGameButton = SKSpriteNode(imageNamed: "newgamebtn")
        startGameButton.position = CGPointMake(size.width/2,size.height/2 - 100)
        startGameButton.name = "startgame" //add reference to the button.
        startGameButton.zPosition  = 2
        addChild(startGameButton) //add button to scene
        
   
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self) //all touches in screen
        let touchedNode = self.nodeAtPoint(touchLocation)
        self.removeAllActions()//touchedNode is the node being touched
        if(touchedNode.name == "startgame"){
           
            let gameOverScene = GameScene(size: size, points: 0, ef: 3.0, level: 1, numEnemy: 6, weaponCap : 0) //make next scene
            gameOverScene.scaleMode = scaleMode
            let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
            view?.presentScene(gameOverScene,transition: transitionType) //move to the next scene
        }
    }

}
