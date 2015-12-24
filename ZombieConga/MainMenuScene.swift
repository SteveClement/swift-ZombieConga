//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Steve Clement on 19/12/15.
//  Copyright © 2015 Steve Clement. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
  
  override init(size: CGSize) {
    super.init(size: size)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToView(view: SKView) {
    var background: SKSpriteNode
    background = SKSpriteNode(imageNamed: "MainMenu")
    background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
    self.addChild(background)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first as UITouch!
    let touchLocation = touch.locationInNode(self)
    sceneTapped(touchLocation)
  }
  
  func sceneTapped(touchLocation: CGPoint) {
    let wait = SKAction.waitForDuration(1.0)
    let block = SKAction.runBlock {
      let myScene = GameScene(size: self.size)
      myScene.scaleMode = self.scaleMode
      let reveal = SKTransition.revealWithDirection(.Left, duration: 0.5)
      self.view?.presentScene(myScene, transition: reveal)
    }
    self.runAction(SKAction.sequence([wait, block]))
    }  
}