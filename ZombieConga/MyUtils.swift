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
//  MyUtils.swift
//  ZombieConga
//
//  Created by Steve Clement on 26/09/15.
//  Copyright © 2015 Steve Clement. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

// Icon sizes: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/IconMatrix.html

// The following will extent the basic operations, +-*/ to be able to calculate vectors etc.
// Before implementing this you would get an error because the (run-time) compiler wouldn't
// know how to handle CGPoints for example. Now it has a reference on what to do

// Add CGPoint operations to the +_operator
func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

// Add CGPoint operations to the +=_operator
func += (left: inout CGPoint, right: CGPoint) {
  left = left + right
}

// Add CGPoint operations to the -_operator
func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

// Add CGPoint operations to the +_operator
func -= (left: inout CGPoint, right: CGPoint) {
  left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * left.x)
}

func *= (left: inout CGPoint, right: CGPoint) {
  left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (point: inout CGPoint, scalar: CGFloat) {
  point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / left.x)
}

func /= (left: inout CGPoint, right: CGPoint) {
  left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (point: inout CGPoint, scalar: CGFloat) {
  point = point / scalar
}

// This only gets considered if we are NOT (!) running on a 64bit Platform
#if !(arch(x86_64) || arch(arm64))
  func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
    return CGFloat(atan2f(Float(y), Float(x)))
  }
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

// This extent CGPoint assigned variables to have a .length()/.normalized()/.angle() property
extension CGPoint {
  func length() -> CGFloat {
    return sqrt(pow(x, 2) + pow(y, 2))
  }
  func normalized() -> CGPoint {
    return self / length()
  }
  var angle: CGFloat {
    return atan2(y, x)
  }
}
let π = CGFloat(Double.pi)

func shortestAngleBetween(_ angle1: CGFloat, angle2: CGFloat) -> CGFloat {
  let twoπ = π * 2.0
  var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
  if (angle >= π) {
    angle = angle - twoπ
  }
  if (angle <= -π) {
    angle = angle + twoπ
  }
  return angle
}

extension CGFloat {
  func sign() -> CGFloat {
  return (self >= 0.0) ? 1.0 : -1.0
  }
}

extension CGFloat {
  static func random() -> CGFloat{
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
  }
  static func random(min: CGFloat, max: CGFloat) -> CGFloat {
    assert(min < max)
    return CGFloat.random() * (max - min) + min
  }
}

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(_ filename: String) {
  let resourceUrl = Bundle.main.url(forResource: filename, withExtension: nil)
  guard let url = resourceUrl else {
    print("Couldn't find file: \(filename)")
    return
  }
  
  // Catch error…
  do {
    try backgroundMusicPlayer =  AVAudioPlayer(contentsOf: url)
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
  } catch {
    // error
    print("Couldn't create audio player!")
  }
}
