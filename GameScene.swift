//  GameScene.swift
//  KirkyBurd
//  Feburary 20th 2025
//  Created by Zach Kirk on 2/6/25.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory
{
    static let player: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let pipePair: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var ground = SKSpriteNode()
    var background = SKSpriteNode()
    var player = SKSpriteNode()
    var pipePair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLabel = SKLabelNode()
    var died = Bool()
    var restart = SKSpriteNode()
    var highScore = 0
    let highScoreLabel = SKLabelNode()
    func restartScene()
    {
        self.removeAllChildren( )
        self.removeAllActions( )
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene()
    {
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2
        {
            let background = SKSpriteNode(imageNamed: "MatteGreyBackground")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = self.size
            background.zPosition = 0
            self.addChild(background)
        }
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        highScoreLabel.position = CGPoint(x: self.frame.width / 2, y: scoreLabel.position.y - 100)
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontName = "04b_19"
        highScoreLabel.zPosition = 6
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.fontSize = 40
        self.addChild(highScoreLabel)
        
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height/2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.zPosition = 4
        scoreLabel.fontSize = 75
        self.addChild(scoreLabel)
        
        ground = SKSpriteNode(imageNamed: "ground")
        ground.setScale(1.00)
        ground.position = CGPoint(x: self.frame.width / 2, y: 0 + ground.frame.height / 2 )
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.player
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        
        ground.zPosition = 3
        
        self.addChild(ground)
        //Create player asset
        player = SKSpriteNode(imageNamed:"Flappy-Bird-PNG-Pic.png")
        player.size = CGSize(width: 200, height: 200)
        player.position = CGPoint(x: self.frame.width / 2 - player.frame.width, y: self.frame.height / 2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.frame.width / 2)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.pipePair
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pipePair | PhysicsCategory.score
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        
        player.zPosition = 2
        
        self.addChild(player)
    }
    override func didMove(to view: SKView)
    {
        createScene()
    }
    
    func createBTN()
    {
        restart = SKSpriteNode(imageNamed: "cfbcd4336297cdd")
        restart.size = CGSize(width: 400, height: 200)
        restart.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restart.zPosition = 5
        restart.setScale(0)
        self.addChild(restart)
        restart.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    func didBegin(_ contact: SKPhysicsContact)
    {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.player
        {
            score += 1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
        else if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.score
        {
            score += 1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
        else if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.pipePair || firstBody.categoryBitMask == PhysicsCategory.pipePair && secondBody.categoryBitMask == PhysicsCategory.player
        {
            enumerateChildNodes(withName: "pipePair", using: { (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            })
            if died == false
            {
                died = true
                createBTN()
            }
        }
        else if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.ground || firstBody.categoryBitMask == PhysicsCategory.ground && secondBody.categoryBitMask == PhysicsCategory.player
        {
            
            enumerateChildNodes(withName: "pipePair", using: {(node, error) in
                node.speed = 0
                self.removeAllActions()
            })
            if died == false
            {
                died = true
                createBTN()
            }
        }
        if score > highScore
        {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "HighScore")
            highScoreLabel.text = "\(highScore)"
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if gameStarted == false
        {
            gameStarted = true
            player.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run({
                () in
                
                self.createPipes()
            })
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence( [spawn, delay] )
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + pipePair.frame.width + 50)
            let movePipes = SKAction.moveBy(x:-distance - 3500, y: 0, duration: 0.008 * distance)
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.applyImpulse(CGVectorMake(0, 950))
        }
        else
        {
            if died == true
            {
                
            }
            else
            {
                player.physicsBody?.velocity = CGVectorMake(0, 0)
                player.physicsBody?.applyImpulse(CGVectorMake(0, 950))
            }
        }
        for touch in touches
        {
            let location = touch.location(in: self)
            if died == true
            {
                if restart.contains(location)
                {
                    restartScene()
                }
            }
        }
        
    }
    //Creates random spawn of pipes and flips topPipe upside down
    func createPipes()
    {
        
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 225, height: 900)
        scoreNode.position = CGPoint(x:self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
        //scoreNode.color = SKColor.white
        
        
        pipePair = SKNode()
        pipePair.name = "pipePair"
        let topPipe = SKSpriteNode(imageNamed: "pngkey.com-mario-pixel-png-1691566.png")
        let bottomPipe = SKSpriteNode(imageNamed: "pngkey.com-mario-pixel-png-1691566.png")
        topPipe.position = CGPoint(x:self.frame.width, y: self.frame.height / 2 + 900)
        bottomPipe.position = CGPoint(x: self.frame.width, y:self.frame.height / 2 - 550)
        
        topPipe.xScale = 1.15
        topPipe.yScale = 1.35
        bottomPipe.xScale = 1.15
        bottomPipe.yScale = 1.35
        
        //let scaledSize = CGSize(width: topPipe.texture!.size().width * 1.15, height: topPipe.texture!.size().height * 1.35)
        //topPipe.size = scaledSize
        //topPipe.physicsBody = SKPhysicsBody(texture: topPipe.texture!, size: scaledSize)
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.categoryBitMask = PhysicsCategory.pipePair
        topPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
        topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.affectedByGravity = false
        
        //let scaledSize2 = CGSize(width: bottomPipe.texture!.size().width * 1.15, height: bottomPipe.texture!.size().height * 1.35)
        //bottomPipe.size = scaledSize2
        //bottomPipe.physicsBody = SKPhysicsBody(texture: bottomPipe.texture!, size: scaledSize)
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.pipePair
        bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.player
        bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.player
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.affectedByGravity = false
        
        topPipe.zRotation = CGFloat.pi
        pipePair.addChild(topPipe)
        pipePair.addChild(bottomPipe)
        
        pipePair.zPosition = 1
        
        pipePair.position.y = CGFloat.random(in:-250...250)
        pipePair.addChild(scoreNode)
        pipePair.run(moveAndRemove)
        
        self.addChild(pipePair)
    }

    override func update(_ currentTime: TimeInterval)
    {
        if gameStarted == true
        {
            if died == false{
                enumerateChildNodes(withName: "background", using:({
                    (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    bg.position = CGPoint(x:bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width
                    {
                        bg.position = CGPointMake(bg.position.x + bg.size.width, bg.position.y)
                    }
                    
                }))
                                        
            }
        }
    }
}
