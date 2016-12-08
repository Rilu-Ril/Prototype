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
    
    var driveLeftAction: SCNAction!
    var driveRightAction: SCNAction!
    
    var jumpLeftAction: SCNAction!
    var jumpRightAction: SCNAction!
    var jumpForwardAction: SCNAction!
    var jumpBackwardAction: SCNAction!
    
    var triggerGameOver: SCNAction!
    
    var collisionNode: SCNNode!
    var frontCollisionNode: SCNNode!
    var backCollisionNode: SCNNode!
    var leftCollisionNode: SCNNode!
    var rightCollisionNode: SCNNode!
    
    let BitMaskPig = 1
    let BitMaskVehicle = 2
    let BitMaskObstacle = 4
    let BitMaskFront = 8
    let BitMaskBack = 16
    let BitMaskLeft = 32
    let BitMaskRight = 64
    let BitMaskCoin = 128
    let BitMaskHouse = 256
    
    var activeCollisionsBitMask: Int = 0
    
    
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
        scnView.delegate = self
        gameScene.physicsWorld.contactDelegate = self
    }
    func setupNodes() {
        pigNode = gameScene.rootNode.childNode(withName: "MrPig", recursively: true)!
        cameraNode = gameScene.rootNode.childNode(withName: "camera", recursively:  true)!
        cameraNode.addChildNode(game.hudNode)
        
        cameraFollowNode = gameScene.rootNode.childNode(withName: "FollowCamera", recursively: true)!
        lightFollowNode = gameScene.rootNode.childNode(withName: "FollowLight", recursively: true)!
        trafficNode = gameScene.rootNode.childNode(withName: "Traffic", recursively: true)!
        collisionNode = gameScene.rootNode.childNode(withName: "Collision",  recursively: true)!
        frontCollisionNode = gameScene.rootNode.childNode(withName: "Front",
                                                                  recursively: true)!
        backCollisionNode = gameScene.rootNode.childNode(withName: "Back",
                                                                 recursively: true)!
        leftCollisionNode = gameScene.rootNode.childNode(withName: "Left",
                                                                 recursively: true)!
        rightCollisionNode = gameScene.rootNode.childNode(withName: "Right",
                                                                  recursively: true)!
        
        pigNode.physicsBody?.contactTestBitMask = BitMaskVehicle | BitMaskCoin | BitMaskHouse
        frontCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        backCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        leftCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        rightCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        
    }
    
    func setupActions() {
        driveLeftAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-2.0, 0, 0), duration: 1.0))
        driveRightAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(2.0, 0, 0), duration: 1.0))
        
        let duration = 0.2
        
        let bounceUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration:
            duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration:
            duration * 0.5)
        
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn

        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])

        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration:
            duration)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration:
            duration)
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration:
            duration)
        let moveBackwardAction = SCNAction.moveBy(x: 0, y: 0, z: 1.0, duration:
            duration)
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: -90), z: 0,
                                                duration: duration, usesShortestUnitArc: true)
        
        let turnRightAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 90), z: 0,
                                                 duration: duration, usesShortestUnitArc: true)
        let turnForwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 180), z: 0,
                                                   duration: duration, usesShortestUnitArc: true)
        let turnBackwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 0), z: 0,
                                                    duration: duration, usesShortestUnitArc: true)
        
        jumpLeftAction = SCNAction.group([turnLeftAction, bounceAction,
                                          moveLeftAction])
        jumpRightAction = SCNAction.group([turnRightAction, bounceAction,
                                           moveRightAction])
        jumpForwardAction = SCNAction.group([turnForwardAction, bounceAction,
                                             moveForwardAction])
        jumpBackwardAction = SCNAction.group([turnBackwardAction, bounceAction,
                                              moveBackwardAction])
        
        
        
        
        /**** game over *****/
        let spinAround = SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 720), z: 0,
                                             duration: 2.0)
        let riseUp = SCNAction.moveBy(x: 0, y: 10, z: 0, duration: 2.0)
        let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 2.0)
        let goodByePig = SCNAction.group([spinAround, riseUp, fadeOut])
        // 2
        let gameOver = SCNAction.run { (node:SCNNode) -> Void in
            self.pigNode.position = SCNVector3(x:0, y:0, z:0)
            self.pigNode.opacity = 1.0
            self.startSplash()
        }
        
        triggerGameOver = SCNAction.sequence([goodByePig, gameOver])
        
        
        
    }
    func setupTraffic() {
        for node in trafficNode.childNodes {
            if node.name?.contains("Bus") == true {
                driveLeftAction.speed = 1.0
                driveRightAction.speed = 1.0
            }else {
                driveLeftAction.speed = 2.0
                driveRightAction.speed = 2.0
            }
            
            if node.eulerAngles.y > 0 {
                node.runAction(driveRightAction)
            } else {
                node.runAction(driveLeftAction)
            }
        }
        
        
    }
    func setupGestures() {
        let swipeRight:UISwipeGestureRecognizer =
            UISwipeGestureRecognizer(target: self, action:
                #selector(ViewController.handleGesture(sender:)))
        swipeRight.direction = .right
        scnView.addGestureRecognizer(swipeRight)
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target:
            self, action: #selector(ViewController.handleGesture(sender:)))
        swipeLeft.direction = .left
        scnView.addGestureRecognizer(swipeLeft)
        
        let swipeForward:UISwipeGestureRecognizer =
            UISwipeGestureRecognizer(target: self, action:
                #selector(ViewController.handleGesture(sender:)))
        swipeForward.direction = .up
        scnView.addGestureRecognizer(swipeForward)
        
        let swipeBackward:UISwipeGestureRecognizer =
            UISwipeGestureRecognizer(target: self, action:
                #selector(ViewController.handleGesture(sender:)))
        swipeBackward.direction = .down
        scnView.addGestureRecognizer(swipeBackward)
        
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
        pigNode.runAction(triggerGameOver)
        
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
    
    
    
    func handleGesture(sender:UISwipeGestureRecognizer){
        
        //stopGame()
        //return
        
        guard game.state == .Playing else {
            return
        }
        
        let activeFrontCollision = activeCollisionsBitMask & BitMaskFront ==
        BitMaskFront
        let activeBackCollision = activeCollisionsBitMask & BitMaskBack ==
        BitMaskBack
        let activeLeftCollision = activeCollisionsBitMask & BitMaskLeft ==
        BitMaskLeft
        let activeRightCollision = activeCollisionsBitMask & BitMaskRight ==
        BitMaskRight
        // 2
        guard (sender.direction == .up && !activeFrontCollision) ||
            (sender.direction == .down && !activeBackCollision) ||
            (sender.direction == .left && !activeLeftCollision) ||
            (sender.direction == .right && !activeRightCollision) else {
                return
        }
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.up:
            pigNode.runAction(jumpForwardAction)
        case UISwipeGestureRecognizerDirection.down:
            pigNode.runAction(jumpBackwardAction)
        case UISwipeGestureRecognizerDirection.left:
            if pigNode.position.x >  -15 {
                pigNode.runAction(jumpLeftAction)
            }
        case UISwipeGestureRecognizerDirection.right:
            if pigNode.position.x < 15 {
                pigNode.runAction(jumpRightAction)
            } default:
            break
        }
    }
    func updatePositions() {
        collisionNode.position = pigNode.presentation.position
        let lerpX = (pigNode.position.x - cameraFollowNode.position.x) * 0.05
        let lerpZ = (pigNode.position.z - cameraFollowNode.position.z) * 0.05
        cameraFollowNode.position.x += lerpX
        cameraFollowNode.position.z += lerpZ
        lightFollowNode.position = cameraFollowNode.position
    }
    func updateTraffic() {
        for node in trafficNode.childNodes {
            if node.position.x > 25 {
                node.position.x = -25
            } else if node.position.x < -25 {
                node.position.x = 25
            }
        }
    }
    
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

extension ViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        guard game.state == .Playing else {
            return
        }
        game.updateHUD()
        updatePositions()
        updateTraffic()
    }
}

extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard game.state == .Playing else {
            return
        }
        var collisionBoxNode: SCNNode!
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
            collisionBoxNode = contact.nodeB
        } else {
            collisionBoxNode = contact.nodeA
        }
        activeCollisionsBitMask |= collisionBoxNode.physicsBody!.categoryBitMask
        
        var contactNode: SCNNode!
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskPig {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if contactNode.physicsBody?.categoryBitMask == BitMaskVehicle {
            stopGame()
        }
        if contactNode.physicsBody?.categoryBitMask == BitMaskCoin {
            contactNode.isHidden = true
            contactNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 60)
            { (node: SCNNode!) -> Void in
                node.isHidden = false
            })
            game.collectCoin()
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard game.state == .Playing else {
            return
        }
        // 8
        var collisionBoxNode: SCNNode!
        
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
            collisionBoxNode = contact.nodeB
        } else {
            collisionBoxNode = contact.nodeA
        }
        
        activeCollisionsBitMask &=  ~collisionBoxNode.physicsBody!.categoryBitMask
    }
}



























