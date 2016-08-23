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
  var lastUpdateTime: TimeInterval = 0
  // delta time
  var dt: TimeInterval = 0
  let zombieMovePointPerSec: CGFloat = 480.0
  var velocity = CGPoint.zero
  let playableRect: CGRect
  var lastTouchLocation: CGPoint?
  let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
  let zombieAnimation: SKAction
  // We create this action so it is re-useable and uses less ressources
  let catCollisionSound: SKAction = SKAction.playSoundFileNamed("Sounds/hitCat.wav", waitForCompletion: false)
  let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("Sounds/hitCatLady.wav", waitForCompletion: false)
  var zombieInvincible = false
  let catMovePointPerSec: CGFloat = 480.0
  let cameraNode = SKCameraNode()
  let cameraMovePointsPerSec: CGFloat = 200.0
  var lives = 5
  var gameOver = false
  let touchBox = SKSpriteNode(color: SKColor.red, size: CGSize(width: 100, height: 100))
  var priorTouch: CGPoint = CGPoint.zero
  
  var cameraRect : CGRect {
    let x = getCameraPosition().x - size.width/2 + (size.width - playableRect.width)/2
    let y = getCameraPosition().y - size.height/2 + (size.height - playableRect.height)/2
    return CGRect(x: x, y: y, width: playableRect.width, height: playableRect.height)
  }
  
  let livesLabel = SKLabelNode(fontNamed: "Glimstick")
  let catsLabel = SKLabelNode(fontNamed: "Glimstick")

  let debug = true

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
    zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
    super.init(size: size)
  }
  
  // Why is this needed again?
  required init(coder aDecode: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    playBackgroundMusic("Sounds/backgroundMusic.mp3")
    backgroundColor = SKColor.white
    addChild(cameraNode)
    camera = cameraNode
    setCameraPosition(CGPoint(x: size.width/2, y: size.height/2))
    
    for i in 0...1 {
      let background = backgroundNode()
      background.anchorPoint = CGPoint.zero
      background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
      background.name = "background"
      addChild(background)
    }
    
    zombie.position = CGPoint(x: 400.0, y: 400.0)
    zombie.zPosition = 100
    //zombie.xScale = 2.0
    //zombie.yScale = 2.0
    //zombie.setScale(2.0)
    addChild(zombie)
    //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
    // This needs some explaining due to the size of the runAction call
    // First we invoke the repeatActionForever method of the SKAction class
    // Because we have more then 1 action in our array we need to invoke a sequence, and because our sequence is in a function we use the runBlock method
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEnemy), SKAction.wait(forDuration: 2.0)])))
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnCat), SKAction.wait(forDuration: 1.0)])))
    
    // Labels
    livesLabel.text = "Lives: X"
    livesLabel.fontColor = SKColor.black
    livesLabel.fontSize = 100
    livesLabel.zPosition = 100
    livesLabel.horizontalAlignmentMode = .left
    livesLabel.verticalAlignmentMode = .bottom
    livesLabel.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20), y: -playableRect.size.height/2 + CGFloat(20) + overlapAmount()/2)
    
    catsLabel.text = "Cats: X"
    catsLabel.fontColor = SKColor.black
    catsLabel.fontSize = 100
    catsLabel.zPosition = 100
    catsLabel.horizontalAlignmentMode = .right
    catsLabel.verticalAlignmentMode = .bottom
    catsLabel.position = CGPoint(x: playableRect.size.width/2 - CGFloat(20), y: -playableRect.size.height/2 + CGFloat(20) + overlapAmount()/2)
    
    cameraNode.addChild(livesLabel)
    cameraNode.addChild(catsLabel)
    
    // the Playable area will only be displayed if debug is true
    debugDrawPlayableArea()
    
    // a touch box for tvOS
    debugTouchBox()
  }
  
  #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      let touchLocation = touch.location(in: self)
      touchBox.position = touchLocation
      sceneTouched(touchLocation)
    }
  
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
      return
      }
      let touchLocation = touch.location(in: self)
      touchBox.position = touchLocation
      sceneTouched(touchLocation)
    }
  #elseif os(tvOS)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      let touchLocation = touch.locationInNode(self)
      touchBox.position = touchLocation
      priorTouch = touchLocation
    }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.locationInNode(self)
    let offset = touchLocation - priorTouch
    let direction = offset.normalized()
    velocity = direction * zombieMovePointPerSec
    priorTouch = (priorTouch * 0.75) + (touchLocation * 0.25)
    touchBox.position = zombie.position + (direction*200)
  }
  #elseif os(OSX)
    override func mouseDown(theEvent: NSEvent) {
      let touchLocation = theEvent.locationInNode(self)
      sceneTouched(touchLocation)
    }
  
    override func mouseDragged(theEvent: NSEvent) {
      let touchLocation = theEvent.locationInNode(self)
      sceneTouched(touchLocation)
    }
  #else
  // As of 2016-01-04 os() can return: OSX, iOS, watchOS, tvOS [Src: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html]
  override func mouseDown(theEvent: NSEvent) {
    print("uh-oh I will not be able to handle input events :( ")
  }
  
  override func mouseDragged(theEvent: NSEvent) {
    print("uh-oh I will not be able to handle input events :(")
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("uh-oh I will not be able to handle input events :(")
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("uh-oh I will not be able to handle input events :(")
  }
  #endif

  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
    //println("\(dt*1000) ms since last update")

    moveSprite(zombie, velocity: velocity)
    rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)

    boundsCheckZombie()
    //checkCollision()
    moveTrain()
    moveCamera()
  
    if lives <= 0 && !gameOver {
      gameOver = true
      let gameOverScene = GameOverScene(size: size, won: false)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      view?.presentScene(gameOverScene, transition: reveal)
      println("You lose!")
      backgroundMusicPlayer.stop()
    }
  }
  
  override func didEvaluateActions() {
    checkCollision()
  }

  // User Functions
  func moveSprite(_ sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    //println("Amount to move: \(amountToMove)")
    sprite.position += amountToMove
  }
  
  func moveZombieToward(_ location: CGPoint) {
    startZombieAnimation()
    let offset = location - zombie.position
    let direction = offset.normalized()
    velocity = direction * zombieMovePointPerSec
  }
  
  func sceneTouched(_ touchLocation: CGPoint) {
    lastTouchLocation = touchLocation
    moveZombieToward(touchLocation)
  }
  
  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
    let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)

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
  
  func rotateSprite(_ sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    if debug {
      print("Shortest contains: \(shortest) and .sign of it is: \(shortest.sign()) zRotation is \(sprite.zRotation) angle2 is: \(velocity)")
    }
    sprite.zRotation += shortest.sign() * amountToRotate

  }
  
  func distanceCheckZombie(_ lastTouchLocation: CGPoint, touchLocation: CGPoint) {
    print("Last: \(lastTouchLocation) \nCurrent: \(touchLocation)")
  }
  
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width/2, y: CGFloat.random(min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2))
    enemy.zPosition = 50
    addChild(enemy)
    let actionMove = SKAction.moveBy(x: -size.width-enemy.size.width*2, y:0, duration: 2.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.run(SKAction.sequence([actionMove, actionRemove]))
  }
  
  func startZombieAnimation() {
    if zombie.action(forKey: "animation") == nil {
      zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
    }
  }
  
  func stopZombieAnimation() {
    zombie.removeAction(forKey: "animation")
  }
  
  func spawnCat() {
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    cat.position = CGPoint(x: CGFloat.random(min: cameraRect.minX, max: cameraRect.maxX), y: CGFloat.random(min: cameraRect.minY, max: cameraRect.maxY))
    cat.zPosition = 50
    cat.setScale(0)
    addChild(cat)
    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotate(byAngle: π/8, duration: 0.5)
    // one way could be to just repeat rotateByAngle with a negative π OR use .reversedAction() method (#preferred)
    //let rightWiggle = SKAction.rotateByAngle(-π/8, duration: 0.5)
    let rightWiggle = leftWiggle.reversed()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
    let scaleDown = scaleUp.reversed()
    let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeat(group, count: 10)
    let appear = SKAction.scale(to: 1.0, duration: 0.5)
    let disappear = SKAction.scale(to: 0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    cat.run(SKAction.sequence(actions))
  }
  
  func zombieHitCat(_ cat: SKSpriteNode) {
    cat.name = "train"
    run(catCollisionSound)
    cat.removeAllActions()
    cat.setScale(1.0)
    cat.zRotation = 0
    let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
    cat.run(turnGreen)
  }
  
  func zombieHitEnemy(_ enemy: SKSpriteNode) {
    run(SKAction.sequence([enemyCollisionSound]))
    loseCats()
    lives -= 1
    zombieInvincible = true

    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customAction(withDuration: duration) {
      node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
      node.isHidden = remainder > slice / 2
    }
    let setHidden = SKAction.run() {
      self.zombie.isHidden = false
      self.zombieInvincible = false
    }
    
    zombie.run(SKAction.sequence([ blinkAction, setHidden ]))
  }
  
  func checkCollision() {
    var hitCats: [SKSpriteNode] = []
    enumerateChildNodes(withName: "cat") { node, _ in
      let cat = node as! SKSpriteNode
      if cat.frame.intersects(self.zombie.frame) {
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
    enumerateChildNodes(withName: "enemy") { node, _ in
      let enemy = node as! SKSpriteNode
      if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame) {
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
    
      enumerateChildNodes(withName: "train") { node, stop in
      trainCount += 1
      if !node.hasActions() {
        let actionDuration = 0.3
        let offset = targetPosition - node.position // a. You need to figure out the offset between the cat’s current position and the target position.
        let direction = offset.normalized() // b. You need to figure out a unit vector pointing in the direction of the offset.
        let amountToMovePerSec = direction * self.catMovePointPerSec // c.
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration) // d. You need to get a fraction of the amountToMovePerSec vector, based on the actionDuration. This represents the offset the cat should move over the next actionDuration seconds. Note you’ll need to cast actionDuration to a CGFloat.
        let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration) // e. You should move the cat a relative amount based on the amountToMove.
        node.run(moveAction)
      }
      targetPosition = node.position
    }
    if trainCount >= 10 && !gameOver {
      gameOver = true
      let gameOverScene = GameOverScene(size: size, won: true)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      view?.presentScene(gameOverScene, transition: reveal)
      println("You win!")
      backgroundMusicPlayer.stop()
    }
    
    // Update labels
    livesLabel.text = "Lives: \(lives)"
    catsLabel.text = "Cats: \(trainCount)"

  }
  
  func loseCats() {
    var loseCount = 0
      enumerateChildNodes(withName: "train") { node, stop in
      var randomSpot = node.position
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      node.name = ""
      node.run(
        SKAction.sequence([
          SKAction.group([
            SKAction.rotate(byAngle: π*4, duration: 1.0),
            SKAction.move(to: randomSpot, duration: 1.0),
            SKAction.scale(to: 0, duration: 1.0)
          ]),
          SKAction.removeFromParent()
        ]))
      loseCount += 1
      if loseCount >= 2 {
        stop.pointee = true
      }
    }
  }
  
  func backgroundNode() -> SKSpriteNode {
    let backgroundNode = SKSpriteNode()
    backgroundNode.anchorPoint = CGPoint.zero
    backgroundNode.name = "background"
    
    let background1 = SKSpriteNode(imageNamed: "background1")
    background1.anchorPoint = CGPoint.zero
    background1.position = CGPoint(x: 0, y: 0)
    backgroundNode.addChild(background1)
    
    let background2 = SKSpriteNode(imageNamed: "background2")
    background2.anchorPoint = CGPoint.zero
    background2.position = CGPoint(x: size.width, y: 0)
    backgroundNode.addChild(background2)
    
    backgroundNode.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
    return backgroundNode
  }
  
  func moveCamera() {
    let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
    let amountToMove = backgroundVelocity * CGFloat(dt)
    cameraNode.position += amountToMove
    enumerateChildNodes(withName: "background") { node, _ in
      let background = node as! SKSpriteNode
      if background.position.x + background.size.width < self.cameraRect.origin.x {
        background.position = CGPoint(x: background.position.x + background.size.width * 2, y: background.position.y)
      }
    }
  }
  
  func overlapAmount() -> CGFloat {
    guard let view = self.view else {
      return 0
    }
    let scale = view.bounds.size.width / self.size.width
    let scaleHeight = self.size.height * scale
    let scaleOverLap = scaleHeight - view.bounds.size.height
    return scaleOverLap / scale
  }
  
  func getCameraPosition() -> CGPoint {
    return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount()/2)
  }
  
  func setCameraPosition(_ position: CGPoint) {
    cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount()/2)
  }
  
  // Debug helpers
  func println(_ content: NSString) {
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
    let path = CGMutablePath()
    path.addRect(playableRect)
    shape.path = path
    shape.strokeColor = SKColor.red
    shape.lineWidth = 12.0
    addChild(shape)
  }
  
  func debugTouchBox() {
    if !debug {
      return
    }
    print("\(size)")
    touchBox.zPosition = 1000
    addChild(touchBox)
  }
}
