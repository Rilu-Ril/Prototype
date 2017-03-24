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
enum Actions {
    case up
    case down
    case left
    case right
}

class ViewController: UIViewController {
    let commands = ["up", "down", "left", "right"]
    let game = GameHelper.sharedInstance
    let panel = Panel.sharedInstance
    let sidePanel = SidePanel.sharedInstance
    var actions:[(SCNAction, Actions)]!
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
    var upButton: UIButton!
    var downButton: UIButton!
    var leftButton: UIButton!
    var rightButton: UIButton!
    var runButton: UIButton!
    var panelView: UIView!
    var sidePanelView: UIView!
    var activeCollisionsBitMask: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actions = [(SCNAction, Actions)]()
        
        setupScenes()
        setupNodes()
        setupActions()
        setupPanel()
        setSidePanel()
        setupTraffic()
        setupGestures()
        setupSounds()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupPanel() {
        let panelY = self.view.frame.height - 200
        panelView = UIView(frame: CGRect(x: 0, y: panelY, width: self.view.frame.width, height: 150))
        panelView.backgroundColor = UIColor.clear
        
        upButton = UIButton(type: UIButtonType.custom)
        upButton.frame = CGRect(x: 75, y: 25, width: 50, height: 50)
        upButton.setImage(UIImage(named: "up") , for: UIControlState.normal)
        upButton.addTarget(self, action: #selector(ViewController.upButtonClicked), for: UIControlEvents.touchUpInside)
        upButton.adjustsImageWhenHighlighted = false
        
        downButton = UIButton(type: UIButtonType.custom)
        downButton.frame = CGRect(x: 75, y: 125, width: 50, height: 50)
        downButton.setImage(UIImage(named: "down") , for: UIControlState.normal)
        downButton.addTarget(self, action: #selector(ViewController.downButtonClicked), for: UIControlEvents.touchUpInside)
        downButton.adjustsImageWhenHighlighted = false
        
        leftButton = UIButton(type: UIButtonType.custom)
        leftButton.frame = CGRect(x: 25, y: 75, width: 50, height: 50)
        leftButton.setImage(UIImage(named: "left") , for: UIControlState.normal)
        leftButton.addTarget(self, action: #selector(ViewController.leftButtonClicked), for: UIControlEvents.touchUpInside)
        leftButton.adjustsImageWhenHighlighted = false
        
        rightButton = UIButton(type: UIButtonType.custom)
        rightButton.frame = CGRect(x: 125, y: 75, width: 50, height: 50)
        rightButton.setImage(UIImage(named: "right") , for: UIControlState.normal)
        rightButton.addTarget(self, action: #selector(ViewController.rightButtonClicked), for: UIControlEvents.touchUpInside)
        rightButton.adjustsImageWhenHighlighted = false
        
        
        runButton = UIButton(type: UIButtonType.custom)
        runButton.frame = CGRect(x: 275, y: 75, width: 50, height: 50)
        runButton.setImage(UIImage(named: "run") , for: UIControlState.normal)
        runButton.addTarget(self, action: #selector(ViewController.runButtonClicked), for: UIControlEvents.touchUpInside)
        runButton.adjustsImageWhenHighlighted = false
        
        
        let img = UIImageView(image: #imageLiteral(resourceName: "panel"))
        img.contentMode = .bottom
        
        panelView.addSubview(img)
        panelView.addSubview(upButton)
        panelView.addSubview(downButton)
        panelView.addSubview(leftButton)
        panelView.addSubview(rightButton)
        panelView.addSubview(runButton)
        scnView.addSubview(panelView)
    }
    func setSidePanel() {
        let panelx = self.view.frame.width - 50
        let height = self.view.frame.height - 200
        sidePanelView = UIView(frame: CGRect(x: panelx, y: 0, width: self.view.frame.width, height: height))
        sidePanelView.backgroundColor = UIColor.clear
        let img = UIImageView(image: #imageLiteral(resourceName: "panel"))
        img.contentMode = .right
        sidePanelView.addSubview(img)
        scnView.addSubview(sidePanelView)
        
    }
    func updatesidePanel() {
        
        let x: Int = Int(self.view.frame.width) - 50
        var i = 0
        for (_, t) in actions
        {
            let y: Int = i * 50
            let imageView = UIImageView(frame: CGRect(x: 0, y: y, width: 50, height: 50))
            imageView.image = UIImage(named: commands[t.hashValue])
            imageView.contentMode = .scaleAspectFit
            sidePanelView.addSubview(imageView)
            
            i += 1
        }
    }
    func upButtonClicked(){
       actions.append((jumpForwardAction, .up))
        updatesidePanel()
    }
    func downButtonClicked(){
        actions.append((jumpBackwardAction, .down))
        updatesidePanel()
    }
    func leftButtonClicked(){
        actions.append((jumpLeftAction, .left))
        updatesidePanel()
    }
    func rightButtonClicked(){
        actions.append((jumpRightAction, .right))
        updatesidePanel()
    }
    func runButtonClicked(){
        let sequence = SCNAction.sequence(actions.map{$0.0})
        pigNode.runAction(sequence)
        actions.removeAll()
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
        if game.state == .TapToPlay {
            let music = SCNAudioSource(fileNamed: "MrPig.scnassets/Audio/Music.mp3")!
                music.volume = 0.3;
                music.loops = true
                music.shouldStream = true
                music.isPositional = false
            let musicPlayer = SCNAudioPlayer(source: music)
            splashScene.rootNode.addAudioPlayer(musicPlayer)
        }   else if game.state == .Playing {
            let traffic = SCNAudioSource(fileNamed: "MrPig.scnassets/Audio/Traffic.mp3")!
                traffic.volume = 0.3
                traffic.loops = true
                traffic.shouldStream = true
                traffic.isPositional = true
            let trafficPlayer = SCNAudioPlayer(source: traffic)
            gameScene.rootNode.addAudioPlayer(trafficPlayer)
            game.loadSound(name: "Jump", fileNamed: "MrPig.scnassets/Audio/Jump.wav")
            game.loadSound(name: "Blocked", fileNamed: "MrPig.scnassets/Audio/Blocked.wav")
            game.loadSound(name: "Crash", fileNamed: "MrPig.scnassets/Audio/Crash.wav")
            game.loadSound(name: "CollectCoin", fileNamed: "MrPig.scnassets/Audio/CollectCoin.wav")
            game.loadSound(name: "BankCoin", fileNamed: "MrPig.scnassets/Audio/BankCoin.wav")
        }
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
                game.playSound(node: pigNode, name: "Blocked")
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
        game.playSound(node: pigNode, name: "Jump")
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
            game.playSound(node: pigNode, name: "Crash")
            stopGame()
            
        }
        if contactNode.physicsBody?.categoryBitMask == BitMaskCoin {
          
            contactNode.isHidden = true
            contactNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 60)
            { (node: SCNNode!) -> Void in
                node.isHidden = false
            })
            game.collectCoin()
            game.playSound(node: pigNode, name: "CollectCoin")
        }
        if contactNode.physicsBody?.categoryBitMask == BitMaskHouse {
            if game.bankCoins() == true {
                game.playSound(node: pigNode, name: "BankCoin")
            }
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



























