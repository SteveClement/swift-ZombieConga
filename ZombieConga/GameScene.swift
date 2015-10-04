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
  var lastTouchLocation: CGPoint?
  let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
  let zombieAnimation: SKAction

  let debug = false


  // Overrides
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    // This initializes an array of type SKTexture
    var textures:[SKTexture] = []
    // Simple for loop, storing the numbers 1-4 in i
    for i in 1...4 {
      // Here we append the 4 textures to our array
      textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    // This manually appends textures at index [1] and [2] to complete the walking sequence (arrays are 0 based)
    textures.append(textures[2])
    textures.append(textures[1])
    // This assigns the texture array to our zombieAnimation by processing the array with SKAction.animateWithTextures
    zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
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
    //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
    // This needs some explaining due to the size of the runAction call
    // First we invoke the repeatActionForever method of the SKAction class
    // Because we have more then 1 action in our array we need to invoke a sequence, and because our sequence is in a function we use the runBlock method
    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)])))
    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
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

    if let lastTouch = lastTouchLocation {
      let diff = lastTouch - zombie.position
      if (diff.length() <= zombieMovePointPerSec * CGFloat(dt)) {
        zombie.position = lastTouchLocation!
        velocity = CGPointZero
        stopZombieAnimation()
      } else {
        moveSprite(zombie, velocity: velocity)
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
      }
    }

    boundsCheckZombie()
    //checkCollision()
  }
  override func didEvaluateActions() {
    checkCollision()
  }

  // User Functions
  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    println("Amount to move: \(amountToMove)")
    sprite.position += amountToMove
  }
  func moveZombieToward(location: CGPoint) {
    startZombieAnimation()
    let offset = location - zombie.position
    let direction = offset.normalized()
    velocity = direction * zombieMovePointPerSec
  }
  func sceneTouched(touchLocation: CGPoint) {
    lastTouchLocation = touchLocation
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
  func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    sprite.zRotation += shortest.sign() * amountToRotate

  }
  func distanceCheckZombie(lastTouchLocation: CGPoint, touchLocation: CGPoint) {
    print("Last: \(lastTouchLocation) \nCurrent: \(touchLocation)")
  }
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
    addChild(enemy)
    let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 1.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
  }
  func startZombieAnimation() {
    if zombie.actionForKey("animation") == nil {
      zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
    }
  }
  func stopZombieAnimation() {
    zombie.removeActionForKey("animation")
  }
  func spawnCat() {
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)), y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
    cat.setScale(0)
    addChild(cat)
    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotateByAngle(π/8, duration: 0.5)
    // one way could be to just repeat rotateByAngle with a negative π OR use .reversedAction() method (#preferred)
    //let rightWiggle = SKAction.rotateByAngle(-π/8, duration: 0.5)
    let rightWiggle = leftWiggle.reversedAction()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
    let scaleDown = scaleUp.reversedAction()
    let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeatAction(group, count: 10)
    let appear = SKAction.scaleTo(1.0, duration: 0.5)
    let disappear = SKAction.scaleTo(0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    cat.runAction(SKAction.sequence(actions))
  }
  func zombieHitCat(cat: SKSpriteNode) {
    cat.removeFromParent()
  }
  func zombieHitEnemy(enemy: SKSpriteNode) {
    enemy.removeFromParent()
  }
  func checkCollision() {
    var hitCats: [SKSpriteNode] = []
    enumerateChildNodesWithName("cat") { node, _ in
      let cat = node as! SKSpriteNode
      if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
        hitCats.append(cat)
      }
    }
    for cat in hitCats {
      zombieHitCat(cat)
    }
    var hitEnemies: [SKSpriteNode] = []
    enumerateChildNodesWithName("enemy") { node, _ in
      let enemy = node as! SKSpriteNode
      if CGRectIntersectsRect(CGRectInset(enemy.frame, 20, 20), self.zombie.frame) {
        hitEnemies.append(enemy)
      }
    }
    for enemy in hitEnemies {
      zombieHitEnemy(enemy)
    }
  }

  // Debug helpers
  func println(content: NSString) {
    if debug {
      print("\(content)")
    }
  }
  func debugDrawPlayableArea() {
    if !debug {
      return
    }
    print("\(size)")
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 12.0
    addChild(shape)
  }
}