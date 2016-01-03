/*
* Copyright (c) 2013-2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

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
  // delta time
  var dt: NSTimeInterval = 0
  let zombieMovePointPerSec: CGFloat = 480.0
  var velocity = CGPointZero
  let playableRect: CGRect
  var lastTouchLocation: CGPoint?
  let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
  let zombieAnimation: SKAction
  // We create this action so it is re-useable and uses less ressources
  let catCollisionSound: SKAction = SKAction.playSoundFileNamed("Sounds/hitCat.wav", waitForCompletion: false)
  let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("Sounds/hitCatLady.wav", waitForCompletion: false)
  var zombieInvincible = false
  let catMovePointPerSec: CGFloat = 480.0
  let backgroundMovePointsPerSec: CGFloat = 200.0
  let backgroundLayer = SKNode()
  var lives = 5
  var gameOver = false

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
  
  // Why is this needed again?
  required init(coder aDecode: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToView(view: SKView) {
    playBackgroundMusic("Sounds/backgroundMusic.mp3")
    backgroundColor = SKColor.whiteColor()
    backgroundLayer.zPosition = -1
    addChild(backgroundLayer)
    
    for i in 0...1 {
      let background = backgroundNode()
      background.anchorPoint = CGPointZero
      background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
      background.name = "background"
      backgroundLayer.addChild(background)
    }
    
    zombie.position = CGPoint(x: 400.0, y: 400.0)
    zombie.zPosition = 100
    //zombie.xScale = 2.0
    //zombie.yScale = 2.0
    //zombie.setScale(2.0)
    backgroundLayer.addChild(zombie)
    //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
    // This needs some explaining due to the size of the runAction call
    // First we invoke the repeatActionForever method of the SKAction class
    // Because we have more then 1 action in our array we need to invoke a sequence, and because our sequence is in a function we use the runBlock method
    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)])))
    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
    // the Playable area will only be displayed if debug is true
    debugDrawPlayableArea()
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first as UITouch!
    let touchLocation = touch.locationInNode(backgroundLayer)
    sceneTouched(touchLocation)
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first as UITouch!
    let touchLocation = touch.locationInNode(backgroundLayer)
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
    rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)

    boundsCheckZombie()
    //checkCollision()
    moveTrain()
    moveBackground()
  
    if lives <= 0 && !gameOver {
      gameOver = true
      let gameOverScene = GameOverScene(size: size, won: false)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontalWithDuration(0.5)
      view?.presentScene(gameOverScene, transition: reveal)
      println("You lose!")
      backgroundMusicPlayer.stop()
    }
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
    let bottomLeft = backgroundLayer.convertPoint(CGPoint(x: 0, y: CGRectGetMinY(playableRect)), fromNode: self)
    let topRight = backgroundLayer.convertPoint(CGPoint(x: size.width, y: CGRectGetMaxY(playableRect)), fromNode: self)

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
    if debug {
      print("Shortest contains: \(shortest) and .sign of it is: \(shortest.sign()) zRotation is \(sprite.zRotation) angle2 is: \(velocity)")
    }
    sprite.zRotation += shortest.sign() * amountToRotate

  }
  
  func distanceCheckZombie(lastTouchLocation: CGPoint, touchLocation: CGPoint) {
    print("Last: \(lastTouchLocation) \nCurrent: \(touchLocation)")
  }
  
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    let enemyScenePos = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
    enemy.position = backgroundLayer.convertPoint(enemyScenePos, fromNode: self)
    backgroundLayer.addChild(enemy)
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
    let catScenePos = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)), y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
    cat.position = backgroundLayer.convertPoint(catScenePos, fromNode: self)
    cat.setScale(0)
    backgroundLayer.addChild(cat)
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
    cat.name = "train"
    runAction(catCollisionSound)
    cat.removeAllActions()
    cat.setScale(1.0)
    cat.zRotation = 0
    let turnGreen = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
    cat.runAction(turnGreen)
  }
  
  func zombieHitEnemy(enemy: SKSpriteNode) {
    runAction(SKAction.sequence([enemyCollisionSound]))
    loseCats()
    lives--
    zombieInvincible = true

    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customActionWithDuration(duration) {
      node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime) % slice
      node.hidden = remainder > slice / 2
    }
    let setHidden = SKAction.runBlock() {
      self.zombie.hidden = false
      self.zombieInvincible = false
    }
    
    zombie.runAction(SKAction.sequence([ blinkAction, setHidden ]))
  }
  
  func checkCollision() {
    var hitCats: [SKSpriteNode] = []
    backgroundLayer.enumerateChildNodesWithName("cat") { node, _ in
      let cat = node as! SKSpriteNode
      if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
        hitCats.append(cat)
      }
    }
    for cat in hitCats {
      zombieHitCat(cat)
    }
    
    if zombieInvincible {
      return
    }
    
    var hitEnemies: [SKSpriteNode] = []
    backgroundLayer.enumerateChildNodesWithName("enemy") { node, _ in
      let enemy = node as! SKSpriteNode
      if CGRectIntersectsRect(
        CGRectInset(node.frame, 20, 20), self.zombie.frame) {
          hitEnemies.append(enemy)
      }
    }
    for enemy in hitEnemies {
      zombieHitEnemy(enemy)
    }
  }
  
  func moveTrain() {
    var targetPosition = zombie.position
    var trainCount = 0
    
      backgroundLayer.enumerateChildNodesWithName("train") { node, stop in
      trainCount++
      if !node.hasActions() {
        let actionDuration = 0.3
        let offset = targetPosition - node.position // a. You need to figure out the offset between the cat’s current position and the target position.
        let direction = offset.normalized() // b. You need to figure out a unit vector pointing in the direction of the offset.
        let amountToMovePerSec = direction * self.catMovePointPerSec // c.
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration) // d. You need to get a fraction of the amountToMovePerSec vector, based on the actionDuration. This represents the offset the cat should move over the next actionDuration seconds. Note you’ll need to cast actionDuration to a CGFloat.
        let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration) // e. You should move the cat a relative amount based on the amountToMove.
        node.runAction(moveAction)
      }
      targetPosition = node.position
    }
    if trainCount >= 10 && !gameOver {
      gameOver = true
      let gameOverScene = GameOverScene(size: size, won: true)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontalWithDuration(0.5)
      view?.presentScene(gameOverScene, transition: reveal)
      println("You win!")
      backgroundMusicPlayer.stop()
    }
  }
  
  func loseCats() {
    var loseCount = 0
      backgroundLayer.enumerateChildNodesWithName("train") { node, stop in
      var randomSpot = node.position
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      node.name = ""
      node.runAction(
        SKAction.sequence([
          SKAction.group([
            SKAction.rotateByAngle(π*4, duration: 1.0),
            SKAction.moveTo(randomSpot, duration: 1.0),
            SKAction.scaleTo(0, duration: 1.0)
          ]),
          SKAction.removeFromParent()
        ]))
      loseCount++
      if loseCount >= 2 {
        stop.memory = true
      }
    }
  }
  
  func backgroundNode() -> SKSpriteNode {
    let backgroundNode = SKSpriteNode()
    backgroundNode.anchorPoint = CGPointZero
    backgroundNode.name = "background"
    
    let background1 = SKSpriteNode(imageNamed: "background1")
    background1.anchorPoint = CGPointZero
    background1.position = CGPoint(x: 0, y: 0)
    backgroundNode.addChild(background1)
    
    let background2 = SKSpriteNode(imageNamed: "background2")
    background2.anchorPoint = CGPointZero
    background2.position = CGPoint(x: size.width, y: 0)
    backgroundNode.addChild(background2)
    
    backgroundNode.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
    return backgroundNode
  }
  
  func moveBackground() {
    let backgroundVelocity = CGPoint(x: -backgroundMovePointsPerSec, y: 0)
    let amountToMove = backgroundVelocity * CGFloat(dt)
    backgroundLayer.position += amountToMove
    backgroundLayer.enumerateChildNodesWithName("background") { node, _ in
      let background = node as! SKSpriteNode
      let backgroundScreenPos = self.backgroundLayer.convertPoint( background.position, toNode: self)
      if backgroundScreenPos.x <= -background.size.width {
        background.position = CGPoint(x: background.position.x + background.size.width*2,
        y: background.position.y)
      }
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