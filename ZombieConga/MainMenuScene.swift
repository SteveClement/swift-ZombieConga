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

  #if os(iOS) || os(tvOS)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      sceneTapped()
    }
  #elseif os(OSX)
    override func mouseDown(theEvent: NSEvent) {
      sceneTapped()
    }
  #else
  // As of 2016-01-04 os() can return: OSX, iOS, watchOS, tvOS [Src: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html]
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("uh-oh I will not be able to handle input events :( ")
  }
  override func mouseDown(theEvent: NSEvent) {
    print("uh-oh I will not be able to handle input events :( ")
  }
  #endif

  func sceneTapped() {
    let myScene = GameScene(size: self.size)
    myScene.scaleMode = self.scaleMode
    let reveal = SKTransition.doorwayWithDuration(1.5)
    self.view?.presentScene(myScene, transition: reveal)
    }
}