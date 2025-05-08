//
//  MusicState.swift
//  Music Widget
//
//  Created by Corvin Gröning on 05.07.22.
//

/// Represents the state of the Music app
struct MusicState {
    /// Current status of the player
    var status: PlayerState = .unknown
    
    /// Indicates whether the Music app is running
    var running: Bool {
        return status == .unknown || status == .stopped ? false : true
    }
    
    /// Current volume level
    var volume: Double = 0
    
    /// Message describing the current player state
    var message: String {
        switch status {
            case .unknown:
                return "Music app is not running."
            case .stopped:
                return "Music player is stopped."
            case .playing:
                return "Music player is playing."
            case .paused:
                return "Music player is paused."
            case .fastForwarding:
                return "Music player is fast-forwarding."
            case .rewinding:
                return "Music player is rewinding."
        }
    }
    
    /// Enum representing the possible states of the player
    enum PlayerState: Int {
        case unknown          // The Music app is not running
        case stopped          // The player is stopped
        case playing          // The player is playing
        case paused           // The player is paused
        case fastForwarding   // The player is fast-forwarding
        case rewinding        // The player is rewinding
    }
}
