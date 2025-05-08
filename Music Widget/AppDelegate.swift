//
//  AppDelegate.swift
//  Music Widget
//
//  Created by Corvin Gröning on 05.07.22.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // Instance of Music Model
    let musicModel: MusicModel = .shared
    
    /// Indicates whether the app should always be displayed "Always On Top"
    @AppStorage("alwaysOnTopDisabled") var alwaysOnTopDisabled = false
    
    /// Creates an observer for "com.apple.Music.playerInfo" and sets
    /// `window.level = .floating` for all windows for "Always On Top"
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Observer
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector: #selector(AppDelegate.updateState),
                        name: NSNotification.Name(
                            rawValue: "com.apple.Music.playerInfo"),
                        //                            rawValue: "com.apple.Music.library.read-write"),
                        //                            rawValue: "com.apple.Music.library.sourceSaved"),
                        //                            rawValue: "com.apple.Music.playback"),
                        //                        object: nil)
                        object: "com.apple.Music.player")
        //                        object: "com.apple.Music.library")
        
        // Always On Top?
        for window in NSApplication.shared.windows {
            window.level = alwaysOnTopDisabled ? .normal : .floating
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Nothing happens here yet.
    }
    
    /// Updates the Music Model after the Music app triggers the signal
    /// "com.apple.Music.playerInfo"
    @objc func updateState(_ aNotification: Notification) {
        // Is a track playing?
        if let message = aNotification.userInfo as NSDictionary?,
           message["Name"] as? String == nil {
            // No, no music is playing, or the Music app is being closed.
            // Wait a moment to avoid AppleScript errors.
            sleep(1)
        }
        Task {
            await musicModel.getMusicState()
        }
    }
}
