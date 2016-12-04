//
//  ViewController.swift
//  Pig
//
//  Created by Sanira Madzhikova on 12/4/16.
//  Copyright © 2016 Sanira Madzhikova. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit


class ViewController: UIViewController {
    let game = GameHelper.sharedInstance
    var scnView:SCNView!
    var gameScene:SCNScene!
    var splashScene:SCNScene!
    var pigNode: SCNNode!
    
    var cameraNode: SCNNode!
    var cameraFollowNode: SCNNode!
    
    var lightFollowNode: SCNNode!
    
    var trafficNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScenes()
        setupNodes()
        setupActions()
        setupTraffic()
        setupGestures()
        setupSounds()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func setupScenes() {
        scnView = SCNView(frame: self.view.frame)
        self.view.addSubview(scnView)
        gameScene = SCNScene(named: "/MrPig.scnassets/GameScene.scn")
        splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene1.scn")
        scnView.scene = splashScene
    }
    func setupNodes() {
        pigNode = gameScene.rootNode.childNode(withName: "MrPig", recursively: true)!
        cameraNode = gameScene.rootNode.childNode(withName: "camera", recursively:  true)!
        cameraNode.addChildNode(game.hudNode)
        cameraFollowNode = gameScene.rootNode.childNode(withName: "FollowCamera", recursively: true)!
        lightFollowNode = gameScene.rootNode.childNode(withName: "FollowLight", recursively: true)!
        trafficNode = gameScene.rootNode.childNode(withName: "Traffic", recursively: true)!
    }
    
    func setupActions() {
    }
    func setupTraffic() {
    }
    func setupGestures() {
    }
    func setupSounds() {
    }
    
    func startGame() {
        splashScene.isPaused = true
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        scnView.present(gameScene, with: transition,
                             incomingPointOfView: nil, completionHandler: {
                                self.game.state = .Playing
                                self.setupSounds()
                                self.gameScene.isPaused = false
        })
    }
    
    func stopGame() {
        game.state = .GameOver
        game.reset()
    }
    
    func startSplash() {
        gameScene.isPaused = true
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        scnView.present(splashScene, with: transition,
                             incomingPointOfView: nil, completionHandler: {
                                self.game.state = .TapToPlay
                                self.setupSounds()
                                self.splashScene.isPaused = false
        }) }
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == .TapToPlay {
            startGame()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

