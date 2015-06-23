import UIKit
import SpriteKit
class StartGameScene: SKScene {
   
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor() //add background
        let startGameButton = SKSpriteNode(imageNamed: "newgamebtn")
        startGameButton.position = CGPointMake(size.width/2,size.height/2 - 100)
        startGameButton.name = "startgame" //add reference to the button.
        addChild(startGameButton) //add button to scene
        
        
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self) //all touches in screen
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        if(touchedNode.name == "startgame"){
            let gameOverScene = GameScene(size: size) //make next scene
            gameOverScene.scaleMode = scaleMode
            let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
            view?.presentScene(gameOverScene,transition: transitionType) //move to the next scene
        }
    }
}
