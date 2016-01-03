//
//  AppDelegate.swift
//  ZombieCongaMac
//
//  Created by Steve Clement on 03/01/16.
//  Copyright (c) 2016 Steve Clement. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
      let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
      scene.scaleMode = .AspectFill
      self.skView!.presentScene(scene)
      self.skView!.ignoresSiblingOrder = true
      self.skView!.showsFPS = true
      self.skView!.showsNodeCount = true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
