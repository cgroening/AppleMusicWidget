//
//  Track.swift
//  Music Widget
//
//  Created by Corvin Gröning on 05.07.22.
//

import SwiftUI

/// Information about a track (artist, title, etc.)
struct Track: Equatable {
    var artist: String = ""
    var album: String = ""
    var name: String = ""
    var trackNumber: Int = 0
    var duration: Int = 0
    var durationFormatted: String = ""
    var rating: Int = 0
    var loved: Bool = false
    var dateAdded: String = ""
    var datePlayed: String = ""
    var playCount: String = ""
    var cover: Image = Image(systemName: "music.quarternote.3")
}

extension Track {
    /// Initialize struct with values from the MusicAppBridge
    /// - Note: In an extension so the "memberwise initializer" can be used
    /// - Parameter dictionary: Dictionary returned by AppleScript
    init(dictionary: NSDictionary) {
        // Create date formatter for date added and last played date
        let df = DateFormatter()
        df.dateFormat = "dd MMM yy"
        
        // Retrieve values from AppleScript
        self.artist = dictionary.value(forKey: "trackArtist") as! String
        self.album = dictionary.value(forKey: "trackAlbum") as! String
        self.name = dictionary.value(forKey: "trackName") as! String
        self.trackNumber = dictionary.value(forKey: "trackNumber") as! Int
        
        if dictionary["trackDuration"] is NSNull {
            self.duration = 0
        } else {
            self.duration = Int(dictionary.value(forKey: "trackDuration") as! Double)
            self.durationFormatted = Track.formatSeconds(
                Int(truncating: dictionary.value(forKey: "trackDuration") as! NSNumber))
        }
        
        self.loved = dictionary.value(forKey: "trackLoved") as! Bool
        
        // If the song is not in the library, the following values might not be available
        if dictionary["trackDateAdded"] is NSNull {
            self.dateAdded = "n.a."
        } else {
            self.dateAdded = df.string(from: dictionary.value(forKey: "trackDateAdded") as! Date)
        }
        
        if dictionary["trackDatePlayed"] is NSNull {
            self.datePlayed = "n.a."
        } else {
            self.datePlayed = df.string(from: dictionary.value(forKey: "trackDatePlayed") as! Date)
        }
        
        if dictionary["trackPlayCount"] is NSNull {
            self.playCount = "n.a."
        } else {
            self.playCount = String(dictionary.value(forKey: "trackPlayCount") as! Int)
        }
        
        // The track's rating is stored in the library as a percentage (0 to 100).
        // The UI, however, offers 0-5 stars. Therefore, the value is divided by 20 (100/5=20).
        self.rating = (dictionary.value(forKey: "trackRating") as! Int) / 20
    }
}

extension Track {
    /// Converts a value given in seconds into a time-formatted string.
    /// Example: 90 -> "1m 30s"
    /// - Parameter duration: NSNumber; track length in seconds
    /// - Returns: Time-formatted string
    static func formatSeconds(_ duration: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(exactly: duration)!)!
    }
}
