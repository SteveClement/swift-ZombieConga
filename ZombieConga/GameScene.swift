//
//  GameScene.swift
//  ZombieConga
//
//  Created by Steve Clement on 24/09/15.
//  Copyright (c) 2015 Steve Clement. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

  let zombie1 = SKSpriteNode(imageNamed: "zombie1")
  
  override func didMoveToView(view: SKView) {
    backgroundColor = SKColor.whiteColor()
    let background = SKSpriteNode(imageNamed: "background1")
    //background.position = CGPoint(x: size.width/2, y: size.height/2)
    background.anchorPoint = CGPointZero
    background.position = CGPointZero
    background.zPosition = -1
    
    zombie1.position = CGPoint(x: 400.0, y: 400.0)
    addChild(background)
    addChild(zombie1)

  }
    
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
  }
   
  override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
  }
}
