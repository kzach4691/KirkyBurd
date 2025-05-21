//  Zachary Kirk
//  GameViewController.swift
//  KirkyBurd
//  FlappyBurd: KirkyBurd
//  Created by student on 2/6/25.
//  Professor: Dr. Robert Schukei

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    
    override func viewDidLoad()
    {
            
    super.viewDidLoad()
            
            if let view = self.view as! SKView? {
            //Load te SKScene from 'GameScene.sks'
            let scene = GameScene(size: CGSize(width: 1536, height: 2048))
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            }

        }
    
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .allButUpsideDown
        }
        else
        {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Release any data, images, etc that aren't in use.
    }
}

