//
//  GameScene.swift
//  ZombieConga
//
//  Created by Steve Clement on 24/09/15.
//  Copyright (c) 2015 Steve Clement. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

  // Variables exposed to all the functions (or properties to some)
  let zombie = SKSpriteNode(imageNamed: "zombie1")
  var lastUpdateTime: NSTimeInterval = 0
  var dt: NSTimeInterval = 0
  let zombieMovePointPerSec: CGFloat = 480.0
  var velocity = CGPointZero
  let playableRect: CGRect

  let debug = true


  // Overrides
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    super.init(size: size)
  }
  required init(coder aDecode: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func didMoveToView(view: SKView) {
    backgroundColor = SKColor.whiteColor()
    let background = SKSpriteNode(imageNamed: "background1")
    //background.position = CGPoint(x: size.width/2, y: size.height/2)
    background.anchorPoint = CGPointZero
    background.position = CGPointZero
    background.zPosition = -1
    
    zombie.position = CGPoint(x: 400.0, y: 400.0)
    //zombie.xScale = 2.0
    //zombie.yScale = 2.0
    //zombie.setScale(2.0)
    addChild(background)
    addChild(zombie)
    debugDrawPlayableArea()
  }
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first as UITouch!
    let touchLocation = touch.locationInNode(self)
    sceneTouched(touchLocation)
  }
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first as UITouch!
    let touchLocation = touch.locationInNode(self)
    sceneTouched(touchLocation)
  }
  override func update(currentTime: CFTimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
    println("\(dt*1000) ms since last update")

    moveSprite(zombie, velocity: velocity)
    boundsCheckZombie()
    rotateSprite(zombie, direction: velocity)
  }
  
  // User Functions
  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
    println("Amount to move: \(amountToMove)")
    sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
  }
  
  func moveZombieToward(location: CGPoint) {
    let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)
    let length = sqrt(pow(offset.x, 2) + pow(offset.y, 2))
    let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
    velocity = CGPoint(x: direction.x * zombieMovePointPerSec, y: direction.y * zombieMovePointPerSec)
  }
  func sceneTouched(touchLocation: CGPoint) {
    moveZombieToward(touchLocation)
  }
  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
    let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))

    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = -velocity.x
    }
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }
  func println(content: NSString) {
    if debug {
      print("\(content)")
    }
  }
  func debugDrawPlayableArea() {
    if !debug {
      return
    }
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 12.0
    addChild(shape)
  }
  func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
    sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
  }
}