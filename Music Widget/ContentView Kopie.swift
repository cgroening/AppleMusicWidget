//
//  ContentView.swift
//  Music Widget
//
//  Created by Corvin Gröning on 04.07.22.
//

import SwiftUI
import Combine


struct ContentView: View {
    // Music Model
    @EnvironmentObject var musicModel: MusicModel
    @EnvironmentObject var volumeSliderData: VolumeSliderData
    
    // Variablen für den Slider für die Player Position
    @State var sliderValue: Double = 0
    @State var timerPaused: Bool = false
    @State var songDuration: Double = 1
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    
    var body: some View {
        HStack (alignment: .top) {
            // Cover
            musicModel.trackInfo.cover
                .resizable()
                .frame(width: 140, height: 140)
            
            VStack (alignment: .center) {
                VStack {
                    
                    // Titel, Interpret und Album
                    HStack (alignment: .bottom) {
                        Image(systemName: "music.note").frame(width: 15)
                        GeometryReader(content: { geometry in
                            SlidingText(geometryProxy: geometry,
                                        text: musicModel.trackInfo.name,
                                        fontSize: 13, boldFont: true)
                        })
                        Spacer()
                    }.frame(height: 14)
                    HStack {
                        Image(systemName: "person.fill").frame(width: 15)
                        GeometryReader(content: { geometry in
                            SlidingText(geometryProxy: geometry,
                                        text: musicModel.trackInfo.artist,
                                        fontSize: 13, boldFont: false)
                        })
                        Spacer()
                    }.frame(height: 14)
                    HStack {
                        Image(systemName: "opticaldisc").frame(width: 15)
                        GeometryReader(content: { geometry in
                            SlidingText(geometryProxy: geometry,
                                        text: musicModel.trackInfo.album,
                                        fontSize: 13, boldFont: false)
                        })
                        Spacer()
                    }.frame(height: 14)
                                        
//                    // Titel, Interpret und Album
//                    HStack {
//                        Image(systemName: "music.note").frame(width: 15)
//                        Text(musicModel.trackInfo.name)
//                            .font(Font.body.bold())
//                        Spacer()
//                    }
//                    HStack {
//                        Image(systemName: "person.fill").frame(width: 15)
//                        Text(musicModel.trackInfo.artist)
//                        Spacer()
//                    }
//                    HStack {
//                        Image(systemName: "opticaldisc").frame(width: 15)
//                        Text(musicModel.trackInfo.album)
//                        Spacer()
//                    }
                }
                
                
                // Herz und Sterne
                HStack {
                    // Herz
                    let loved = musicModel.trackInfo.loved
                    Button(action: {
                        musicModel.toggleLoved()
                    }, label: {
                        Image(systemName: loved ? "heart.fill" : "heart")
                    }).padding(.trailing, 20)
                 
                    let stars = musicModel.trackInfo.rating
//                    let starImageWidth:CGFloat = 10
                    Button(action: {
                        musicModel.setRating(rating: 1)
                    }, label: {
                        Image(systemName: stars > 0 ? "star.fill" : "star")
                    })
                    Button(action: {
                        musicModel.setRating(rating: 2)
                    }, label: {
                        Image(systemName: stars > 1 ? "star.fill" : "star")
                    })
                    Button(action: {
                        musicModel.setRating(rating: 3)
                    }, label: {
                        Image(systemName: stars > 2 ? "star.fill" : "star")
                    })
                    Button(action: {
                        musicModel.setRating(rating: 4)
                    }, label: {
                        Image(systemName: stars > 3 ? "star.fill" : "star")
                    })
                    Button(action: {
                        musicModel.setRating(rating: 5)
                    }, label: {
                        Image(systemName: stars > 4 ? "star.fill" : "star")
                    })
                }.padding(0)
                                
//                // Herz und Sterne als Image (platzsparender als Buttons,
//                // erfordert jedoch 2 Klicks, wenn das Fenster nicht im Fokus ist)
//                HStack {
//                    // Herz
//                    let loved = musicModel.trackInfo.loved
//                    Image(systemName: loved ? "heart.fill" : "heart")
//                        .onTapGesture { musicModel.toggleLoved() }
//                        .padding(.trailing, 20)
//
//                    // Sterne
//                    let stars = musicModel.trackInfo.rating
//                    let starImageWidth:CGFloat = 10
//                    Image(systemName: stars > 0 ? "star.fill" : "star")
//                        .onTapGesture { musicModel.setRating(rating: 1) }
//                        .frame(width: starImageWidth)
//                    Image(systemName: stars > 1 ? "star.fill" : "star")
//                        .onTapGesture { musicModel.setRating(rating: 2) }
//                        .frame(width: starImageWidth)
//                    Image(systemName: stars > 2 ? "star.fill" : "star")
//                        .onTapGesture { musicModel.setRating(rating: 3) }
//                        .frame(width: starImageWidth)
//                    Image(systemName: stars > 3 ? "star.fill" : "star")
//                        .onTapGesture { musicModel.setRating(rating: 4) }
//                        .frame(width: starImageWidth)
//                    Image(systemName: stars > 4 ? "star.fill" : "star")
//                        .onTapGesture { musicModel.setRating(rating: 5) }
//                        .frame(width: starImageWidth)
//                        .padding(.trailing, 20)
//                }
//                .padding([.top, .bottom], 1)
                
//                // Player Controls
//                HStack {
//                    // Buttons für Previous, Play/Pause, Next
//                    Button(action: {
//                        musicModel.musicAppBridge.gotoPreviousTrack()
//                    }, label: {
//                        Image(systemName: "backward.fill")
//                    })
//                    Button(action: {
//                        musicModel.musicAppBridge.playPause()
//                    }, label: {
//                        Image(systemName: musicModel.musicState.status == .playing ? "pause.fill" : "play.fill")
//                    })
//                    .frame(width: 40)
//                    Button(action: {
//                        musicModel.musicAppBridge.gotoNextTrack()
//                    }, label: {
//                        Image(systemName: "forward.fill")
//                    })
//                        .padding(.trailing, 20)
//
//                    // Slider für Lautstärke
//                    Image(systemName: "speaker.fill")
//                    // Bei diesem Slider wird die Lautstärke beim Bewegen und
//                    // beim Loslassen angepasst. Bei dem auskommentierten nur
//                    // beim Bewegen. Anpassung beim Loslassen notwendig, falls
//                    // Slider ganz schnell nach rechts oder links bewegt wird.
//                    Slider(value: $volumeSliderData.sliderValue, in: 0...100,
//                           onEditingChanged: { _ in
//                               musicModel.musicAppBridge.soundVolume =
//                                   NSNumber(value: volumeSliderData.sliderValue)
//                           })
//                    .onReceive(timer) { _ in
//                        // TODO: Slider regelmäßig aktualisieren
//                        // Wenn die Lautstärke in der Music-App angepasst wird,
//                        // wird der Slider momentan erst beim nächsten Track
//                        // oder bei Play/Pause angepasst.
//                    }
//                    Image(systemName: "speaker.wave.3.fill")
//                }
//
                // Slider für Player Position
                Slider(value: $sliderValue, in: 0...songDuration, step: 1,
                       onEditingChanged: {
                    bool in

                    // Timer pausieren während der Slider bewegt wird
                    timerPaused = bool ? true : false

                    // Nur die Player Position verändern, wenn die Änderung
                    // größer als 2 % ist. So wird auch das Ruckeln der
                    // Tonwiedergabe beim Drück der Maustaste vermieden
                    let plPos = musicModel.musicAppBridge.playerPosition

                    if abs(sliderValue / Double(truncating: plPos) - 1) > 0.02 {
                        musicModel.musicAppBridge.playerPosition =
                            NSNumber(value: sliderValue)
                    }
                })
                .onReceive(timer) { _ in
                    if !timerPaused {
                        self.sliderValue = Double(musicModel.getPlayerPosition())

                        // Song Duration ist aus unerklärlichen Gründen beim
                        // Starten der App manchmal 0, daher dieser Workaround
                        self.songDuration = Double(musicModel.getDuration())
                    }
                }
                .padding(0)
                .frame(height: 19)
                
                // Player-Position und Dauer
                //let position = Track.formatSeconds(musicModel.getPlayerPosition())
                let position = Track.formatSeconds(Int(sliderValue))
                let duration = musicModel.trackInfo.durationFormatted
                let remaining = Track.formatSeconds(Int(sliderValue)
                                                    - musicModel.trackInfo.duration)
                let progress = String(Int((sliderValue / songDuration) * 100))
                HStack {
                    Text("\(position) (\(remaining))")
                        .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                    Text("\(progress) %")
                        .frame(maxWidth: 50, alignment: .center)
                        .font(.system(size: 12))
                    Text(duration)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 12))
                }
            }
            .padding(.leading, 5)
            .padding(.trailing, 10)
            .padding(.bottom, 5)
        }
        .disabled(!musicModel.musicState.running)
        .opacity(musicModel.musicState.running ? 1 : 0.5)
        //.frame(width: 450, height: 400)
        .task {
            await musicModel.getMusicState()
        }
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
    }
}


/// Alternative für Text(): Ist der übergebene String breiter als der Platz im
/// UI, wird er animiert (er läuft von links nach rechts und wieder zurück).
struct SlidingText: View {
    let geometryProxy: GeometryProxy
    let text: String
    let fontSize: CGFloat
    let boldFont: Bool
    
    @State private var animateSliding: Bool = false
    private let timerNeu = Timer.publish(every: 2, on: .current, in: .common).autoconnect()
    private let slideDuration: Double = 1
    
    
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
            .frame(width: geometryProxy.size.width, alignment: (animateSliding && text.widthOfString(usingFont: NSFont.systemFont(ofSize: fontSize)) > geometryProxy.size.width) ? .trailing : .leading)
            .clipped()
            .animation(Animation.linear(duration: slideDuration), value: self.animateSliding)
            .onReceive(timerNeu) { _ in
                // Nur animieren, wenn der Platz nicht ausreicht, um den
                // kompletten Text darzustellen
                let spaceRequired = text.widthOfString(usingFont: NSFont.systemFont(ofSize: fontSize))
                let spaceAvailable = geometryProxy.size.width
                
                print("HI")

                if spaceRequired > spaceAvailable {
                    
                    self.animateSliding.toggle()
                                        
                }
            }
        })
        .frame(width: self.geometryProxy.size.width, height: self.geometryProxy.size.height)
        .clipShape(Rectangle())
    }
}




/// Gibt die Breite in Pixeln zurück, welcher ein Text in der UI benötigt
/// - Parameter font: Instanz von NSFont, welches Schriftart und -größe
/// beinhaltet
/// - Note: Für iOS muss statt NSFont der Typ UIFont verwendet werden, dazu
/// muss UIKit importiert werden.
extension String {
    func widthOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
