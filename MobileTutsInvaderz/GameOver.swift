//
//  GameOver.swift
//  MobileTutsInvaderz
//
//  Created by Frank du Plessis on 2015/06/22.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//


import SpriteKit

class GameOver: SKScene {
    var text = ""
   
    init(size: CGSize, points: String){
         text = String(points)
        super.init(size: size)
       
        
        
    }
    


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        let pointsLabel = SKLabelNode(fontNamed: "COPPERPLATE")
        pointsLabel.text = text
        pointsLabel.position = CGPoint(x:60,y:60)
        addChild(pointsLabel)
        backgroundColor = SKColor.blackColor() //add background
        let startGameButton = SKSpriteNode(imageNamed: "gameover")
        startGameButton.position = CGPointMake(size.width/2,size.height/2 - 100)
        startGameButton.name = "restart" //add reference to the button.
        addChild(startGameButton) //add button to scene   
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self) //all touches in screen
        let touchedNode = self.nodeAtPoint(touchLocation) //touchedNode is the node being touched
        if(touchedNode.name == "restart"){
            let gameOverScene = GameScene(size: size) //make next scene
            gameOverScene.scaleMode = scaleMode
            let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
            view?.presentScene(gameOverScene,transition: transitionType) //move to the next scene
        }
    }
    
    
   
}
