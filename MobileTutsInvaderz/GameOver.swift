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
    var points = UInt32(0)
    var EnemyFreq = Double(0)
    var level = UInt32(0)
    init(size: CGSize, points: UInt32, ef: Double, level: UInt32){
       //  text = String(points)
        super.init(size: size)
        self.points = points
        self.EnemyFreq = ef - 0.5
        self.level = level + 1
        
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
            let gameOverScene = GameScene(size: size, points:self.points, ef:EnemyFreq, level:level) //make next scene
            gameOverScene.scaleMode = scaleMode
            let transitionType = SKTransition.flipHorizontalWithDuration(1.0)
            view?.presentScene(gameOverScene,transition: transitionType) //move to the next scene
        }
    }//dfdf
    
    
   
}
