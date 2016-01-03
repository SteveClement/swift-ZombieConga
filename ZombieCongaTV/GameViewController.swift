//
//  GameViewController.swift
//  ZombieCongaTV
//
//  Created by Steve Clement on 03/01/16.
//  Copyright (c) 2016 Steve Clement. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
    // Configure the view.
    let skView = self.view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
            
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = true
            
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = .AspectFill
            
    skView.presentScene(scene)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
