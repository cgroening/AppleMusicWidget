//
//  MusicController.swift
//  Music Widget
//
//  Created by Corvin Gröning on 04.07.22.
//

import AppleScriptObjC
import SwiftUI
import iTunesLibrary
import Combine



class MusicModel: ObservableObject {
    /// Singleton: Instanz dieser Klasse (Konstruktor muss private sein)
    static let shared = MusicModel()
    
    /// Instanz von MusicAppBridge für die Kommunikation mit der Musik-App
    var musicAppBridge: MusicAppBridge
    
    /// Instanz der Musik-Bibliothek
    var musicSongs: [ITLibMediaItem] = []
    
    /// Status der Music-App bzw. des Players
    @Published var musicState = MusicState()
    
    /// Informationen über einen Track (Interpret, Titel, usw.)
    @Published var trackInfo = Track()
    
    /// Gibt an, ob sich der Song in der Bibliothek befindet oder über
    /// Apple Music abgerufen wird
    @Published var songInLibrary = false
    
    
    /// MusicAppBridge instanziieren und Observer einrichten
    private init() {
        // AppleScriptObjC Setup
        Bundle.main.loadAppleScriptObjectiveCScripts()
        
        // Instanz von MusicAppBridge erstellen
        let musicAppBridgeClass: AnyClass = NSClassFromString("MusicAppBridge")!
        self.musicAppBridge = musicAppBridgeClass.alloc() as! MusicAppBridge
        
        // Musik-Bibliothek einlesen
        self.musicSongs = self.getMusicSongs()
        
        
        
//        print(self.musicAppBridge.favoritedPlaylists)
//        print(self.getFavoritedPlaylists())
//        print(self.getTestTest())
//        print(self.getPlaylists())
//        print(self.getPlaylistsNeu())
    }
    
    /// Lässt das Cover über AppleScript auf der Festplatte ablegen und
    /// erstellt mit dieser Datei eine Instanz von Image, welche zurückgegeben
    /// wird.
    /// TODO: Anderen Ordner, als den Download-Ordner wählen
    /// TODO: Cover beim Schließen der App wieder löschen
    func getArtworkViaAppleScript() -> Image {
        // Pfad des Downloads-Ordners erhalten und den Ordner "Music Widget"
        // erstellen, wenn er nicht vorhanden ist
        let downloadsDirectory = FileManager.default.urls(
                for: .downloadsDirectory, in: .userDomainMask).first!
        let downloadsDirectoryWithFolder = downloadsDirectory
                .appendingPathComponent("Music Widget")
        
        do {
            try FileManager.default.createDirectory(
                at: downloadsDirectoryWithFolder,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        // Artwork speichern über AppleScript
        _ = musicAppBridge.saveArtwork()
        print("Artwork gespeichert")
        
        // JPEG-Datei des Covers lesen und Image-Instanz zurückgeben
        let imgUrl = downloadsDirectoryWithFolder
                         .appendingPathComponent("music_cover.jpg")
        
        do {
            let imageData = try Data(contentsOf: imgUrl)            
            return Image(nsImage: NSImage(data: imageData) ?? NSImage())
        } catch {
            print("Error loading image : \(error)")
            return Image(systemName: "music.quarternote.3")
        }
    }
    
    
    /// Position des Players in Sekunden
    func getPlayerPosition() -> Int {
        return Int(truncating: self.musicAppBridge.playerPosition)
    }
    
    /// Klasse des Tracks ("shared track" oder "URL track")
    func getTrackInLibrary() -> Bool {
        if self.musicAppBridge.trackInLibrary == 1 {
            return true
        } else {
            return false
        }
    }
    
    /// Gibt die Liedlänge zurück (Workaround für SwiftUI-Slider).
    func getDuration() -> Int {
        // Prüfen, ob die Liedlänge gelesen werden kann, wenn nicht 1 zurückgeben
//        do {
//            let duration = musicAppBridge.trackDuration
//        } catch {
//            return 1
//        }
        
        // Prüfen, ob der Player gestoppt ist
        if musicState.status == .unknown || musicState.status == .stopped {
            // Falls der Player gestoppt ist, wird der Wert 1 zurückgegeben
            return 1
        } else {
            // Liedlänge zurückgeben
            return Int(truncating: musicAppBridge.trackDuration)
        }
    }
    
    func getFavoritedPlaylists() -> String {
        return String(describing: musicAppBridge.favoritedPlaylists)
    }
    
    func getTestTest() -> Int {
        return Int(truncating: musicAppBridge.testTest)
    }
}


extension MusicModel {
    /// Gibt ein Array zurück mit allen Liedern aus der Music-Bibliothek
    func getMusicSongs() -> [ITLibMediaItem] {
        musicSongs = []
        let iTunesLibrary: ITLibrary
        
        // Bibliothek einlesen
        do {
            iTunesLibrary = try ITLibrary(apiVersion: "1.0")
        } catch {
            print("FEHLER: Die Musik-Bibliothek konnte nicht gelesen werden.")
            return [ITLibMediaItem]()
        }
        
        // Lieder speichern
        let songs = iTunesLibrary.allMediaItems
        print("Es wurden \(songs.count) Lieder gefunden.")
                
        return songs
    }
    
//    /// Liefert ein Dictionary mit allen Playlisten
//    func getPlaylists() -> Bool {
//        let iTunesLibrary: ITLibrary
//        
//        // Bibliothek einlesen
//        do {
//            iTunesLibrary = try ITLibrary(apiVersion: "1.0")
//        } catch {
//            print("FEHLER: Die Playlisten konnten nicht gelesen werden.")
//            
//            return false
//        }
//        
//        // Playlisten speichern
//        let userPlaylists = iTunesLibrary.allPlaylists
//        print("Es wurden \(userPlaylists.count) Playlisten gefunden.")
//        
////        print(userPlaylists)
//        
//        
//        var plToAdd:ITLibPlaylist
//        
//        
//        for playlist: ITLibPlaylist in userPlaylists {
////            print(playlist.name)
////            print(playlist.persistentID)
//            
//            if playlist.name == "Testliste" {
//                plToAdd = playlist
//                print(playlist.name)
//                print(playlist.persistentID)
//            }
//        }
//        
//        var trackToAdd:ITLibMediaItem
//        
//        for mediaItem:ITLibMediaItem in iTunesLibrary.allMediaItems {
//            if mediaItem.title == "(What a) Wonderful World" {
////                print(mediaItem.addedDate)
//                trackToAdd = mediaItem
//            }
//        }
//        
//        
//        return true
//    }
    
    
//    func getPlaylistsNeu() -> Bool {
//        do {
//            let iTunesLibrary = try ITLibrary(apiVersion: "1.0")
//            let userPlaylists = iTunesLibrary.allPlaylists
//            
//            // Schritt 1: Finde alle Playlists, die selbst Ordner sind (diese haben keine Tracks)
//            let folderPlaylists = userPlaylists.filter { $0.items.isEmpty }
//            
//            // Schritt 2: Finde Playlists, die in diesen Ordnern sein könnten
//            for folder in folderPlaylists {
//                print("📂 Ordner: \(folder.name)")
//                
//                // Prüfe, ob eine Playlist "logisch" unter diesem Ordner ist (z. B. durch Namenskonventionen)
//                let subPlaylists = userPlaylists.filter { $0.name.hasPrefix(folder.name) }
//                
//                for subPlaylist in subPlaylists {
//                    print("  ↳ Enthält Playlist: \(subPlaylist.name)")
//                }
//            }
//            
//        } catch {
//            print("FEHLER: Die Playlisten konnten nicht gelesen werden.")
//        }
//        
//        
//        
//        return true
//    }
}


extension MusicModel {
    /// Liest den aktuellen Status der Music-App
    /// - Note: Wenn die Music-App nicht läuft, ruft diese Funktion nach einer
    /// Sekunde sich selbst auf
    func getMusicState() async {
        if musicAppBridge._playerState == 0 {
            Task { @MainActor in
                musicState.status = MusicState.PlayerState(rawValue: 0)!
                trackInfo = Track()
            }
            /// Sich selbst aufrufen, wenn Music-App nicht läuft
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await getMusicState()
        } else {
            Task { @MainActor in
                // Status der Music-App und Track Infos erhalten
                musicState.status = MusicState.PlayerState(rawValue:
                                      musicAppBridge._playerState as? Int ?? 0)!
                musicState.volume = musicAppBridge.soundVolume.doubleValue
                getTrackInfo()
                VolumeSliderData.shared.sliderValue = musicState.volume
            }
        }
    }
}

    
extension MusicModel {    
    /// Liest die Infos zu dem aktuellen Track (Name, Interpret, usw.)
    @MainActor func getTrackInfo() {
        let bridge = musicAppBridge
        var track = Track()

        if bridge.isRunning, let info = bridge.trackInfo as NSDictionary? {
            track = Track(dictionary: info)
            track.cover = getArtwork(track: track)
        }

        trackInfo = track
        
        // Prüft, ob das Lied in der Bibliothek ist (wird für Deaktivierung
        // der Sterne-Bewertungen benötigt
        if self.musicAppBridge.trackInLibrary == 1 {
            self.songInLibrary = true
        } else {
            self.songInLibrary = false
        }
    }
    
    /// TrackInfo aktualisieren, für den Fall, dass Favorit oder Sterne
    /// geändert wurden.
    /// TODO: Nur Favorit und sternen aktualieren, nicht alle Daten (update-
    /// Funktion in der Klasse Track implementieren)
    func updatedLovedAndRating() {
        let bridge = musicAppBridge
        var track_updated = Track()
        
        if bridge.isRunning, let info = bridge.trackInfo as NSDictionary? {
            track_updated = Track(dictionary: info)
        }
        
        trackInfo.loved = track_updated.loved
        trackInfo.rating = track_updated.rating
    }
    
    
    /// Gibt das Cover-Bild (Artwork) des aktuellen Tracks zurück
    /// - Note: Es wird zunächst versucht, das Cover aus der Music-Bibliothek
    /// zu laden. Wird keins gefunden (weil kein Cover hinterlegt ist oder
    /// der Track von Apple Music gespielt wird (nicht in Bibliothek
    /// gespeichert), wird über AppleScript das Cover auf der Festplatte
    /// abgelegt und mit Swift geöffnet. Ich konnte keinen Weg finden, das
    /// Cover über die MusicAppBridge zu übergeben
    func getArtwork(track: Track) -> Image {
        var image = Image(systemName: "music.quarternote.3")
        
        if let match = musicSongs.first(where: {
            $0.title == track.name  &&
            $0.album.title == track.album &&
            $0.trackNumber == track.trackNumber
            })
        {
            if let coverArt = match.artwork {
                image = Image(nsImage: coverArt.image!)
                print("Cover in Bibliothek gefunden.")
            } else {
                print("Song gefunden, aber kein Cover.")
            }
            
//            self.songInLibrary = true
        } else {
            // Song nicht in Bibliothek, versuche über AppleScript
            image = self.getArtworkViaAppleScript()
            
//            self.songInLibrary = false
        }

        return image
    }
}


final class VolumeSliderData: ObservableObject {
    /// Singleton: Instanz dieser Klasse (Konstruktor muss private sein)
    static let shared = VolumeSliderData()
    
    var firstUse: Bool = true
    
    let didChange = PassthroughSubject<VolumeSliderData,Never>()
    @Published var sliderValue: Double =
        0 {
            willSet {
                // Erst beim 2. Benutzen, die Lautstärke ändern. Dies sorgt
                // dafür, dass beim Programmstart die Lautstärke nicht auf 0
                // gesetzt wird (MusicModel.shared.musicAppBridge.soundVolume
                // als Startwert für sliderValue festlegen führt zu Fehlern).
                if !firstUse {
// Workaround: Die folgenden Zeilen wurden auskommentiert, da mit diesen
// die Aktualisierung des Sliders für die Lautstärke im Widget nachdem
// in der Music App die Lautstärke geändert wurde, nicht funktioniert.
// Stattdessen wird die Lautstärke in der Music-App über .onReceive des
// Sliders angepasst.
//                    MusicModel.shared.musicAppBridge.soundVolume =
//                        NSNumber(value: sliderValue)
                    didChange.send(self)
                }
                firstUse = false
            }
    }
    
    private init() { }
}


extension MusicModel {
    /// Ändert den Loved-Status eines Tracks (true/false)
    @MainActor func toggleLoved() {
        // Loved-Status in der Music-App ändern
        musicAppBridge.loved = trackInfo.loved ? 0 : 1
        
        // TrackInfo anpassen, damit sich die SwiftUI-Anzeige ändert
        trackInfo.loved.toggle()
    }

    /// Setzt die Bewertung eines Tracks
    /// - Parameter rating: Bewertung zwischen 0 und 5
    @MainActor func setRating(rating: Int) {
        // Wenn die übergebene Bewertung der bereits vorhandenen entspricht,
        // d. h. im UI auf den gesetzten Stern geklickt wurde, setze die
        // Bewerung auf 0
        if trackInfo.rating != rating {
            musicAppBridge.rating = NSNumber(value: rating * 20)
            trackInfo.rating = rating
        } else {
            musicAppBridge.rating = NSNumber(value: 0)
            trackInfo.rating = 0
        }

    }
}
