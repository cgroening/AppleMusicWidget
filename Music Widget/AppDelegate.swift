//
//  AppDelegate.swift
//  Music Widget
//
//  Created by Corvin Gröning on 05.07.22.
//

import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate {
    /// Shared instance of the MusicModel
    let musicModel: MusicModel = .shared
    
    /// AppStorage variable to store the "Always On Top" state
    @AppStorage("alwaysOnTopDisabled") var alwaysOnTopDisabled = false
    
    /// Creates an observer for "com.apple.Music.playerInfo" and sets
    /// `window.level = .floating` for all windows if the
    /// "Always On Top" setting is disabled.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Observer
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector: #selector(AppDelegate.updateState),
                        name: NSNotification.Name(
                            rawValue: "com.apple.Music.playerInfo"
                        ),
                        object: "com.apple.Music.player")
        
        // Set the window level to floating if "Always On Top" is disabled
        for window in NSApplication.shared.windows {
            window.level = alwaysOnTopDisabled ? .normal : .floating
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Nothing happens here, yet.
    }
    
    /// Updates the Music Model after the Music app triggers the signal
    /// "com.apple.Music.playerInfo"
    @objc func updateState(_ aNotification: Notification) {
        // Is a track playing?
        if let message = aNotification.userInfo as NSDictionary?,
           message["Name"] as? String == nil {
            // No music is playing or the Music app is being closed,
            // wait a second to avoid AppleScript errors
            sleep(1)
        }
        Task {
            await musicModel.getMusicState()
        }
    }
}
