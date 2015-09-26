//
//  MyUtils.swift
//  ZombieConga
//
//  Created by Steve Clement on 26/09/15.
//  Copyright © 2015 Steve Clement. All rights reserved.
//

import Foundation
import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (inout left: CGPoint, right: CGPoint) {
  left = left + right
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - left.x)
}
func -= (inout left: CGPoint, right: CGPoint) {
  left = left - right
}
func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * left.x)
}
func *= (inout left: CGPoint, right: CGPoint) {
  left = left * right
}
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
func *= (inout point: CGPoint, scalar: CGFloat) {
  point = point * scalar
}
func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / left.x)
}
func /= (inout left: CGPoint, right: CGPoint) {
  left = left / right
}
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
func /= (inout point: CGPoint, scalar: CGFloat) {
  point = point / scalar
}
#if !(arch(x86_64) || arch(amd64))
  func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
    return CGFloat(atan2f(Float(y), Float(x)))
  }
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

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