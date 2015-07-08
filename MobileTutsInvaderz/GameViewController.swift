import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        let scene = GameScene(size: view.bounds.size, points: 5, ef: 4.0, level: 1, numEnemy: 5, weaponCap: 1)
        let skView = view as! SKView
        //skView.showsFPS = true
        //skView.showsPhysics = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}