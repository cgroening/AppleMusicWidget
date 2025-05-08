//
//  Support.swift
//  Swift-AppleScriptObjC
//

import Cocoa

@objc(NSObject) protocol MusicAppBridge {
    
    // Important:
    // ASOC does not bridge C data types, only Cocoa classes and objects, i.e.,
    // the Swift data types Bool/Int/Double must be explicitly converted to/from
    // NSNumber when "communicating" with AppleScript.
    
    // Indicates whether the Music app is running (Bool)
    var _isRunning: NSNumber { get }
    
    // Player status (stopped, playing, paused, fast forwarding, rewinding)
    var _playerState: NSNumber { get }
    
    // Player position (in seconds)
    var playerPosition: NSNumber { get set }
    
    // Array: Title, artist, etc., of the current track
    var trackInfo: [NSString:AnyObject]? { get }
    
    // Indicates whether the track is in the library (1) or from Apple Music (0)
    var trackInLibrary: NSNumber { get }
    
    // Track duration for slider (workaround)
    var trackDuration: NSNumber { get }
    
    // Player volume
    var soundVolume: NSNumber { get set }
    
    // Loved?
    var loved: NSNumber { get set }
    
    // Rating (0-100)
    var rating: NSNumber { get set }
    
    // Date the track was added to the library
    var dateAdded: NSDate { get }
    
    // Date the track was last played
    var datePlayed: NSDate { get }
    
    // Play count
    var playCount: NSNumber { get }
    
    // Starts or pauses the player's playback
    func playPause()
    
    // Jumps to the next track
    func gotoPreviousTrack()
    
    // Jumps to the previous track
    func gotoNextTrack()
    
    // Indicates whether shuffle is enabled (Bool)
    var shuffleEnabled: NSNumber { get }
    
    // Toggles shuffle on/off
    func toggleShuffle()
    
    // Returns the repeat setting for tracks (off, all, or one)
    // <NSAppleEventDescriptor: 'kRp0'>
    // <NSAppleEventDescriptor: 'kAll'>
    // <NSAppleEventDescriptor: 'kRp1'>
    var songRepeat: NSAppleEventDescriptor { get }
    
    // Cycles through repeat settings: all -> one -> off
    func toggleSongRepeat()
    
    // Saves the artwork of the current track in the Application Support folder
    func saveArtwork() -> NSString
    
    // Returns a list of playlists marked as favorites
    //    var favoritedPlaylists: [NSString]? { get }
    //    @objc optional func favoritedPlaylists() -> [NSString]
    
    //    var favoritedPlaylists: AnyObject { get }
    var favoritedPlaylists: NSString { get }
    
    var testTest: NSNumber { get }
}

// Native Swift version of the ASOC APIs defined above
extension MusicAppBridge {
    // Indicates whether the Music app is running
    var isRunning: Bool {
        return self._isRunning.boolValue
    }
    
    // Player status (stopped, playing, paused, fast forwarding, rewinding)
    var playerState: PlayerState {
        return PlayerState(rawValue: self._playerState as! Int)!
    }
}

// Property for the player's status (player state)
@objc enum PlayerState: Int {
    case unknown  // When the Music app is not running
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}
