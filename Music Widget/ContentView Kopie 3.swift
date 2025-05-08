//
//  ContentView.swift
//  Music Widget
//
//  Created by Corvin Gröning on 04.07.22.
//

import SwiftUI
import Combine
import AudioToolbox  // für AudioServicesPlaySystemSound
import AVFAudio


struct ContentView: View {
    // Music Model
    @EnvironmentObject var musicModel: MusicModel
    @EnvironmentObject var volumeSliderData: VolumeSliderData
    
    
    // Variablen für den Slider für die Player Position
    @State var sliderValue: Double = 0
    @State var timerPaused: Bool = false
    @State var songDuration: Double = 1
    
    // Timer für den Player-Positions-Slider
    @StateObject private var timers = Timers.shared
    //    @State private var timers = Timers.shared
    
    
    // Gibt an, ob der Info-Button aktiviert wurde
    @AppStorage("isInfoButtonActivated") var isInfoButtonActivated: Bool = false
    
    // Gibt an, ob Shuffle aktiviert ist
    @State var shuffleEnabled: Bool = false
    
    // Einstellung für die Titelwiederholung zurück (kRp0, kAll oder kRp1)
    @State var songRepeat: String = "kRp0"
    
    
    var body: some View {
        HStack (alignment: .top, spacing: 0) {
            // Cover / Buttons auf dem Cover
            ZStack (alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                // Cover
                musicModel.trackInfo.cover
                    .resizable()
                    .frame(width: 107, height: 103)
                // Abdunkeln des Covers von rechts oben nach links unten
                // https://designcode.io/swiftui-handbook-mask-and-transparency
                    .mask(LinearGradient(gradient: Gradient(colors:
                                                                [.black, .black, .black, .clear]),
                                         startPoint: .bottomLeading, endPoint: .topTrailing))
                
                VStack {
                    HStack {
                        Spacer()
                        
                        // Button der ein Haken anzeigt, wenn sich der Titel in der Bibliothek
                        // befindet bzw. ein Plus anzeigt, um den Titel der Bibliothek hinzuzufügen
                        Button(action: { },
                               label: { Image(systemName: musicModel.songInLibrary ? "checkmark.circle" : "minus.circle") })
                        .help(musicModel.songInLibrary ? "The current title has been added to the library." : "The current title has NOT been added to the library.")
                        .buttonStyle(.borderedProminent)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                    
                    // Weitere Informationen zum Titel, die angezeigt werden, wenn es durch
                    // ein Klicken auf das Info-Symbol aktiviert wurde
                    VStack {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .frame(width: 15)
                                .font(.system(size: 11))
                                .padding(.leading, 5)
                                .help("Date added")
                            Text(musicModel.trackInfo.dateAdded).font(Font.system(size: 11))
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "play")
                                .frame(width: 15)
                                .font(.system(size: 11))
                                .padding(.leading, 5)
                                .help("Date played")
                            Text(musicModel.trackInfo.datePlayed).font(Font.system(size: 11))
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "number")
                                .frame(width: 15)
                                .font(.system(size: 11))
                                .padding(.leading, 5)
                                .help("Play count")
                            Text(musicModel.trackInfo.playCount).font(Font.system(size: 11))
                            Spacer()
                        }
                    }
                    .background(Color.white)
                    .opacity((self.isInfoButtonActivated) ? 0.9 : 0.0)
                }
                
                
            }
            .padding(0)
            .padding(.leading, -2)
            .frame(width: 107, height: 103)
            
            VStack (alignment: .center) {
                // Titel, Interpret und Album
                HStack (alignment: .bottom) {
                    Image(systemName: "music.note")
                        .frame(width: 15)
                        .font(.system(size: 11))
                        .help("Title")
                    Text(musicModel.trackInfo.name).font(Font.system(size: 11))
                        .help(musicModel.trackInfo.name)
                    // Der erforderliche Timer für SlidingText kostet zu viel Energie
                    //                    GeometryReader(content: { geometry in
                    //                        SlidingText(geometryProxy: geometry,
                    //                                    text: musicModel.trackInfo.name,
                    //                                    fontSize: 11, boldFont: true)
                    //                    })
                    Spacer()
                }
                .frame(height: 14)
                HStack {
                    Image(systemName: "person.fill")
                        .frame(width: 15)
                        .font(.system(size: 11))
                        .help("Artist")
                    Text(musicModel.trackInfo.artist).font(Font.system(size: 11))
                        .help(musicModel.trackInfo.artist)
                    // Der erforderliche Timer für SlidingText kostet zu viel Energie
                    //                    GeometryReader(content: { geometry in
                    //                        SlidingText(geometryProxy: geometry,
                    //                                    text: musicModel.trackInfo.artist,
                    //                                    fontSize: 11, boldFont: false)
                    //                    })
                    Spacer()
                }
                .frame(height: 14)
                .padding(.top, -9)
                HStack {
                    Image(systemName: "opticaldisc")
                        .frame(width: 15)
                        .font(.system(size: 11))
                        .help("Album")
                    Text(musicModel.trackInfo.album).font(Font.system(size: 11))
                        .help(musicModel.trackInfo.album)
                    // Der erforderliche Timer für SlidingText kostet zu viel Energie
                    //                    GeometryReader(content: { geometry in
                    //                        SlidingText(geometryProxy: geometry,
                    //                                    text: musicModel.trackInfo.album,
                    //                                    fontSize: 11, boldFont: false)
                    //                    })
                    Spacer()
                }
                .frame(height: 14)
                .padding(.top, -9)
                
                HStack {
                    ZStack {
                        // Meldung, die angezeigt wird, wenn Herz und Sterne
                        // ausgeblendet sind
                        Text("[Song not in library.]")
                            .font(Font.system(size: 10)) //.bold()
                            .lineSpacing(0)
                            .opacity(musicModel.songInLibrary ? 0 : 1)
                        
                        // Herz und Sterne
                        HStack {
                            // Herz
                            let loved = musicModel.trackInfo.loved
                            Button(action: {
                                musicModel.toggleLoved()
                            }, label: {
                                Image(systemName: loved ? "heart.fill" : "heart")
                                    .foregroundStyle(.red)
                            })
                            .buttonStyle(.plain)
                            //.font(.system(size: 8))
                            //.frame(width: 10, height: 10)
                            .padding(.trailing, 5)
                            
                            // 5 Buttons für die Sterne
                            ForEach(1..<6) { stars in
                                RatingButton(starNumber: stars,
                                             trackRating: musicModel.trackInfo.rating,
                                             timer: timers.$first)
                                .buttonStyle(.plain)
                                .foregroundStyle(.blue)
                                .padding(.trailing, (stars==5) ? 5 : -6)
                            }
                        }
                        // Herz und Sterne verstecken, wenn sich das Lied nicht in
                        // der Bibliothek befindet, d. h. über Apple Music abgerufen wird
                            .opacity(musicModel.songInLibrary ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    // End Track Button
                    Button(action: {
                        let endPos = NSNumber(value: songDuration - 1)
                        musicModel.musicAppBridge.playerPosition = endPos
                    }, label: {
                        Image(systemName: "arrow.right.to.line.compact")
                    })
                    .help("End track = skip to next track but increase the " +
                          "play count of the current track.")
                    .buttonStyle(.plain)
                    
                    // Shuffle-Button
                    Button(action: {
                        self.musicModel.musicAppBridge.toggleShuffle()
                        self.shuffleEnabled.toggle()
                    },
                           label: { Image(systemName: "shuffle") })
                    .buttonStyle(.plain)
                    .foregroundStyle((self.shuffleEnabled) ? Color(red: 0, green: 0.5, blue: 0) : .primary)
                    .onAppear{
                        self.shuffleEnabled = self.musicModel.musicAppBridge.shuffleEnabled as! Bool
                    }
                    .onReceive(timers.$second) { _ in
                        self.shuffleEnabled = self.musicModel.musicAppBridge.shuffleEnabled as! Bool
                    }
                    
                    
                    // Repeat-Button
                    Button(action: {
                        self.musicModel.musicAppBridge.toggleSongRepeat()
                        if self.songRepeat == "kRp0" || self.songRepeat == "kRpO" {
                            self.songRepeat = "kAll"
                            print(self.songRepeat)
                        } else if self.songRepeat == "kAll" {
                            self.songRepeat = "kRp1"
                            print(self.songRepeat)
                        } else {
                            self.songRepeat = "kRp0"
                            print(self.songRepeat)
                        }
                    },
                           label: { Image(systemName: (self.songRepeat == "kRp1") ? "repeat.1" : "repeat" ) })
                    .buttonStyle(.plain)
                    .foregroundStyle((self.songRepeat == "kAll" || self.songRepeat == "kRp1") ? Color(red: 0, green: 0.5, blue: 0) : .primary)
                    .onAppear{
                        self.songRepeat = self.musicModel.musicAppBridge.songRepeat.stringValue ?? "kRp0"
                    }
                    .onReceive(timers.$second) { _ in
                        self.songRepeat = self.musicModel.musicAppBridge.songRepeat.stringValue ?? "kRp0"
                    }
                    
                    // Add to playlist-Button
//                    Button(action: { },
//                           label: { Image(systemName: "list.triangle") })
//                    .buttonStyle(.plain)
                    
                    // Info-Button
                    Button(action: { self.isInfoButtonActivated.toggle() },
                           label: { Image(systemName: "info.circle") })
                    .buttonStyle(.plain)
                    .foregroundStyle((self.isInfoButtonActivated) ? Color(red: 0, green: 0.5, blue: 0) : .primary)
                    // Settings-Button
                    Button(action: { },
                           label: { Image(systemName: "gear") })
                    .buttonStyle(.plain)
                }.padding([.top, .bottom], -5)
                            
                
                // Slider für Player Position
                //Slider(value: $sliderValue, in: 0...songDuration, step: 1,
                Slider(value: $sliderValue, in: 0...((songDuration > 0) ? songDuration : 1), step: 1,
                       onEditingChanged: {
                    sliderBeingDragged in
                    
                    // Timer pausieren, während der Slider bewegt wird
                    timerPaused = sliderBeingDragged ? true : false
                    
                    // Nur die Player Position verändern, wenn die Änderung
                    // größer als 2 % ist. So wird auch das Ruckeln der
                    // Tonwiedergabe beim Drücken der Maustaste vermieden
                    let plPos = musicModel.musicAppBridge.playerPosition
                    
                    if abs(sliderValue / Double(truncating: plPos) - 1) > 0.02 {
                        musicModel.musicAppBridge.playerPosition =
                        NSNumber(value: sliderValue)
                    }
                })
                .onReceive(timers.$first) { _ in
                    if !timerPaused {
                        self.sliderValue = Double(musicModel.getPlayerPosition())
                        
                        // Song Duration ist aus unerklärlichen Gründen beim
                        // Starten der App manchmal 0, daher dieser Workaround
                        self.songDuration = Double(musicModel.getDuration())
                        
                        // Favorit und Sterne-Bewertung aktualisieren, für den
                        // Fall, dass es in der Music-App geändert wurde
                        //musicModel.getTrackInfo()
                        //musicModel.getTrackInfo()
                        musicModel.updatedLovedAndRating()
                    }
                }
                .padding(0)
                .frame(height: 19)
                
                
                // CustomSlider(value: Binding.constant(CGFloat(10)), maxValue: CGFloat(100))
                
                VStack(spacing: 50) {
                    CustomSlider(value: $sliderValue, maxValue: songDuration)
                        .frame(height: 20)
                    //.opacity(0.5)
                }
                .padding(.horizontal,20)
                
                
                // Player-Position und Dauer
                let position = Track.formatSeconds(Int(sliderValue))
                let duration = musicModel.trackInfo.durationFormatted
                let remaining = Track.formatSeconds(
                    Int(sliderValue) - musicModel.trackInfo.duration)
                
                // Workaround für den Fall, dass der Player gestoppt ist
                let progress = String(Int((sliderValue / ((songDuration > 0) ? songDuration : 1)) * 100))
                
                HStack {
                    Text("\(position) (\(remaining))")
                        .frame(minWidth: 100,
                               maxWidth: .infinity,
                               alignment: .leading)
                        .font(.system(size: 10))
                    Text("\(progress) %")
                        .frame(maxWidth: 50,
                               alignment: .center)
                        .font(.system(size: 10))
                    Text(duration)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 10))
                        .padding(.trailing, 5)
                }
                .padding(.top, -5)
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .padding(.bottom, 5)
            // Verschwommenes Cover als Hintergrund
            .background(
                musicModel.trackInfo.cover
                    .resizable()
                    .frame(height: 115)
                    .blur(radius: 20, opaque: false)
                    .opacity(0.5)
            )
        }
        .padding(0)
        .disabled(!musicModel.musicState.running)
        .opacity(musicModel.musicState.running ? 1 : 0.5)
        .task { await musicModel.getMusicState() }
        .onAppear { timers.start() }
        .onDisappear { timers.stop() }
    }
}


struct ContentView_Previews: PreviewProvider {
    // Instanz von MusicModel (Singleton)
    static let musicModel: MusicModel = .shared
    static let volumeSliderData: VolumeSliderData = .shared
    
    static var previews: some View {
        ContentView()
            .environmentObject(musicModel)
            .environmentObject(volumeSliderData)
            .frame(width: 385)
    }
}

/// CustomView für die Bewertungs/Sterne-Buttons. Der Button blinkt, wenn
/// der aktuelle Track noch nicht bewertet wurde und der Track-Fortschritt
/// >= 80 % ist.
/// - Parameter starNumber: Sterne-Anzahl für die der Button vorgesehen ist
/// - Parameter trackRating: Bewertung (0-5) des aktuellen Tracks
/// - Parameter timer: Publisher-Object des Timers (erforderlich, damit
/// der Button blinken kann
struct RatingButton: View {
    let starNumber: Int
    let trackRating: Int
    let timer: Published<Int>.Publisher
    
    @State var appJustStarted: Bool = true
    @State var showWarningColor: Bool = false
    
    // Audioplayer um Warnton abzuspielen, wenn Titel noch nicht bewertet wurde
    @State var audioPlayer: AVAudioPlayer?
    
    /// Gibt an, ob die Warnung für den Fall, dass der Track bald zu Ende ist,
    /// jedoch noch nicht bewertet wurde, deaktiviert sein soll
    @AppStorage("songNotRatedWarningDisabled")
    var songNotRatedWarningDisabled: Bool = false
    
    var body: some View {
        Button(action: {
            // Track-Bewertung setzen
            MusicModel.shared.setRating(rating: starNumber)
        }, label: {
            Image(systemName: trackRating >= starNumber ? "star.fill" : "star")
                .foregroundStyle(.blue)
        })
        .foregroundColor(self.showWarningColor ? .red : .none)
        .onAppear {
            // Audioplayer vorbereiten, falls Hinweiston wegen fehlender Bewertung
            // abgespielt werden soll
            if let audio = NSDataAsset(name: "Audiio_MobilePhoneChime2") {
                do {
                    audioPlayer = try AVAudioPlayer(data: audio.data)
                    audioPlayer?.volume = 0.3
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        .onReceive(timer) { _ in
            // Track Fortschritt ermitteln
            let trackProgess: Double =
            Double(truncating: MusicModel.shared.musicAppBridge.playerPosition)
            / Double(MusicModel.shared.trackInfo.duration)
            
            // Überspringe den ersten Timerschritt (es muss abgewartet werden,
            // bis MusicModel.shared.trackInfo.rating gesetzt wurde, sonst
            // kommt es zu einer Fehlfunktion)
            if self.appJustStarted {
                self.appJustStarted = false
            } else {
                // Soll der Button blinken?
                if MusicModel.shared.trackInfo.rating == 0  // keine Bewertung?
                    && trackProgess >= 0.8  // Track-Fortschritt >= 80 %
                    && !songNotRatedWarningDisabled {
                    self.showWarningColor.toggle()
                    
                    // Hinweis-Ton wegen fehlender Bewertung abspielen
//                    AudioServicesPlaySystemSound(1209)
                    audioPlayer?.play()
                } else {
                    self.showWarningColor = false
                }
            }
        }
    }
}


/// Alternative für Text(): Ist der übergebene String breiter als der Platz im
/// UI, wird er animiert (er läuft von links nach rechts und wieder zurück).
struct SlidingText: View {
    // GeometryProxy, in dem sich der Text befindet (enthält verfügbare Breite)
    let geometryProxy: GeometryProxy
    
    // Text, dessen Breite gemessen werden soll
    let text: String
    
    // Schriftgröße und fett ja/nein
    let fontSize: CGFloat
    let boldFont: Bool
    
    // Einstellungen für das Sliding
    @State private var animateSliding: Bool = false
    private let slideDuration: Double = 1.8
    // @StateObject private var timers = Timers()
    @StateObject private var timers = Timers.shared
    
    var body: some View {
        ZStack(alignment: .leading, content: {
            VStack {
                if boldFont {
                    Text(text).font(Font.system(size: fontSize)).bold()
                } else {
                    Text(text).font(Font.system(size: fontSize))
                }
            }
            .fixedSize()
            .frame(width: geometryProxy.size.width,
                   // Die Ausrichtung soll nur geändert werden, wenn Sliding
                   // erforderlich ist
                   alignment: (animateSliding &&
                               text.widthOfString(usingFont:
                                                    NSFont.systemFont(ofSize: fontSize)) >
                               geometryProxy.size.width) ? .trailing : .leading)
            .clipped()
            .animation(Animation.linear(duration: slideDuration),
                       value: self.animateSliding)
            .onReceive(timers.$second) { _ in
                // Nur animieren, wenn der Platz nicht ausreicht, um den
                // kompletten Text darzustellen
                let spaceRequired = text.widthOfString(usingFont:
                                                        NSFont.systemFont(ofSize: fontSize))
                let spaceAvailable = geometryProxy.size.width
                
                if spaceRequired > spaceAvailable {
                    self.animateSliding.toggle()
                }
            }
        })
        .frame(width: self.geometryProxy.size.width,
               height: self.geometryProxy.size.height)
        .clipShape(Rectangle())
        .onAppear { timers.start()  }
        .onDisappear { timers.stop() }
    }
}


extension String {
    /// Gibt die Breite in Pixeln zurück, welcher ein Text in der UI benötigt.
    ///
    /// ```
    /// // Breite eines Texts in Systemschriftart und Schriftgröße 14
    /// let width = text.widthOfString(usingFont: NSFont.systemFont(ofSize: 14))
    /// ```
    ///
    /// - Parameter font: Instanz von NSFont, welches Schriftart und -größe
    /// beinhaltet
    /// - Warning: Es muss darauf gedachtet werden, dass die richtige Schriftart
    /// und -größe übergeben werden.
    /// - Note: Für iOS muss statt NSFont der Typ UIFont verwendet werden, dazu
    /// muss UIKit importiert werden.
    /// - Returns: Breite des Texts in der UI
    func widthOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

/// ViewModel, damit mehrere Timer möglich sind.
final class Timers: ObservableObject {
    /// Singleton: Instanz dieser Klasse (Konstruktor muss private sein)
    static let shared = Timers()
    
    @Published private(set) var first = 0
    @Published private(set) var second = 0
    private var subscriptions: Set<AnyCancellable> = []
    
    
    private init() { }
    
    /// Startet alle Timer
    /// Derzeit sind die folgenden Timer vorhanden:
    /// first: alle 5 Sekunden, vorgesehen für Player-Positions-Slider
    /// second: alle 2 Sekunden, vorgesehen für SlidingText
    /// Er wird eine Toleranz von 1 s verwendet, um die CPU-Auslastungs zu
    /// verringern (das System hat so die Möglichkeit von timer coalescing, die
    /// CPU kann sich mehr im Idle befinden,
    /// s. https://www.hackingwithswift.com/books/ios-swiftui/triggering-events-repeatedly-using-a-timer
    func start() {
        Timer.publish(every: 5, tolerance: 1, on: .main, in: .common)
            .autoconnect()
            .scan(0) { accumulated, _ in accumulated + 1 }
            .assign(to: \.first, on: self)
            .store(in: &subscriptions)
        Timer.publish(every: 2, tolerance: 1, on: .main, in: .common)
            .autoconnect()
            .scan(0) { accumulated, _ in accumulated + 1 }
            .assign(to: \.second, on: self)
            .store(in: &subscriptions)
    }
    
    /// Löscht alle Timer
    func stop() {
        subscriptions.removeAll()
    }
}


struct CustomSlider: View {
    @Binding var value:CGFloat
    private var maxValue:CGFloat
    
    init(value: Binding<CGFloat>, maxValue: CGFloat) {
        self._value = value
        self.maxValue = maxValue
    }
    var body: some View {
        GeometryReader{ proxy in
            ZStack(alignment: .center){
                Capsule()
                    .foregroundColor(.secondary)
                
                Capsule()
                    .fill(LinearGradient(gradient: .init(colors: [Color.red, Color.blue]), 
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: proxy.size.width * (CGFloat(value) / CGFloat(maxValue)))
                    .contentShape(.capsule)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(.white, in: Capsule().stroke(style: .init()))
                
            }
        }
    }
}
