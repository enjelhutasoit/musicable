//
//  MusicPlayerViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 04/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Accelerate
import CoreHaptics

//===========================================================================================================================
//Global Property For Signal Sample Count (from: rajabun)
//===========================================================================================================================
let sampleCount = 1024
//===========================================================================================================================
protocol GetLyricDelegate
{
    func getLyric(sender: UIButton)
}


class MusicPlayerViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var albumImageView: UIView!
    @IBOutlet weak var equalizerView: UIView!
    @IBOutlet weak var playView: UIView!
        
    var referenceHeaderView: MusicPlayerHeader?
    var referenceAlbumImageView: MusicPlayerAlbumImage?
    var referenceEqualizerView: EqualizerView?
    var referencePlayView: PlayView?
    var referenceLyricView: Lirik?
    
    var songTitle: String = ""
    var songSinger: String = ""
    var albumImage: UIImage?
    var totalDuration: Int = 0
    var timer:Timer!
    
    //===========================================================================================================================
    //Global Property For Render Signal (from: rajabun)
    //===========================================================================================================================
    let forwardDCT = vDSP.DCT(count: sampleCount,
                              transformType: .II)
    
    var frequencyDomainGraphLayerIndex = 0
    let frequencyDomainGraphLayers = [CAShapeLayer(), CAShapeLayer(),
                                      CAShapeLayer(), CAShapeLayer()]
    
    let envelopeLayer = CAShapeLayer()
    
    var pageNumber = 0
    //var signalToParameter: Float = 0.0
    //===========================================================================================================================
    
    //===========================================================================================================================
    //Global Property For Sample Sound (from: rajabun)
    //===========================================================================================================================
    let samples: [Float] =
    {
        guard let samples = AudioUtilities.getAudioSamples(
            forResource: "Sempurna",
            withExtension: "mp3")
        else
        {
                fatalError("Unable to parse the audio resource.")
        }
        
        return samples
    }()
    //===========================================================================================================================
    
    //===========================================================================================================================
    //Global Property For Haptic Engine (from: rajabun)
    //===========================================================================================================================

    // Haptic Engine & Player State:
    private var engine: CHHapticEngine!
    private var engineNeedsStart = true
    private var continuousPlayer: CHHapticAdvancedPatternPlayer!
    
    // Constants
    private let initialIntensity: Float = 1.0
    private let initialSharpness: Float = 0.5
    
    // Tokens to track whether app is in the foreground or the background:
    private var foregroundToken: NSObjectProtocol?
    private var backgroundToken: NSObjectProtocol?
    
    private lazy var supportsHaptics: Bool =
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.supportsHaptics
    }()
    
    //===========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        getData()
        updateTotalDuration()

//        referenceAlbumImageView?.nowPlayingAlbumImage.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        referenceAlbumImageView?.nowPlayingAlbumImage.layer.shadowOpacity = 0.3
//        referenceAlbumImageView?.nowPlayingAlbumImage.layer.shadowRadius = 10
        
        referencePlayView?.volumeSlider.self.setMaximumTrackImage(#imageLiteral(resourceName: "Minimal Slider"), for: .normal)
        referencePlayView?.volumeSlider.self.setMinimumTrackImage(#imageLiteral(resourceName: "Slider Filler"), for: .normal)
        referencePlayView?.volumeSlider.self.setThumbImage(#imageLiteral(resourceName: "Slider Dot"), for: .normal)
        referencePlayView?.timeSlider.setMinimumTrackImage(#imageLiteral(resourceName: "Slider Filler"), for: .normal)
        referencePlayView?.timeSlider.setMaximumTrackImage(#imageLiteral(resourceName: "Minimal Slider"), for: .normal)
        
//        MPVolumeView.setVolume(0.5)
    //===========================================================================================================================
        //Function For Render Waveform View (from: rajabun)
        //===========================================================================================================================
        renderGraphView()
        //===========================================================================================================================
               
//        AudioUtilities.configureAudioUnit(signalProvider: self)
               
        //===========================================================================================================================
        //Function For Prepare Haptics (from: rajabun)
        //===========================================================================================================================
        if supportsHaptics
        {
            createAndStartHapticEngine()
            createContinuousHapticPlayer()
        }
        addObservers()
        //===========================================================================================================================
        
    }
    
    //===========================================================================================================================
    //Function For Add Waveform View to SubView (from: rajabun)
    //===========================================================================================================================
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        frequencyDomainGraphLayers.forEach
        {
            $0.frame = equalizerView.frame.insetBy(dx: 0, dy: 50)
        }
        
        envelopeLayer.frame = equalizerView.frame.insetBy(dx: 0, dy: 50)
    }
    //===========================================================================================================================
    
    //===========================================================================================================================
    //Function For Add Waveform View (from: rajabun)
    //===========================================================================================================================
    func renderGraphView()
    {
        frequencyDomainGraphLayers.forEach
        {
            view.layer.addSublayer($0)
        }
        
        envelopeLayer.fillColor = nil
        view.layer.addSublayer(envelopeLayer)
    }
    //==========================================================================================================================
    
    func setView(){
        if let referenceHeaderView = Bundle.main.loadNibNamed("MusicPlayerHeader", owner: self, options: nil)?.first as? MusicPlayerHeader{
            headerView.addSubview(referenceHeaderView)
            referenceHeaderView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceHeaderView = referenceHeaderView
        }
        
        if let referenceAlbumImageView = Bundle.main.loadNibNamed("MusicPlayerAlbumImage", owner: self, options: nil)?.first as? MusicPlayerAlbumImage{
            albumImageView.addSubview(referenceAlbumImageView)
            referenceAlbumImageView.nowPlayingAlbumImage.layer.cornerRadius = 10
            referenceAlbumImageView.frame = CGRect(x: 0, y: 0, width: albumImageView.frame.width, height: albumImageView.frame.height)
            self.referenceAlbumImageView = referenceAlbumImageView
        }
        
        if let referenceEqualizerView = Bundle.main.loadNibNamed("EqualizerView", owner: self, options: nil)?.first as? EqualizerView{
            equalizerView.addSubview(referenceEqualizerView)
            referenceEqualizerView.frame = CGRect(x: 0, y: 0, width: equalizerView.frame.width, height: equalizerView.frame.height)
            self.referenceEqualizerView = referenceEqualizerView
        }

        if let referencePlayView = Bundle.main.loadNibNamed("PlayView", owner: self, options: nil)?.first as? PlayView{
            playView.addSubview(referencePlayView)
            referencePlayView.frame = CGRect(x: 0, y: 0, width: playView.frame.width, height: playView.frame.height)
            self.referencePlayView = referencePlayView
        }
        
//        let playController = PlayViewViewController(nibName: "PlayView", bundle: nil)
//        let playView:PlayView = playController.view as! PlayView
//        playView.frame = CGRect(x: 0, y: 0, width: self.playView.frame.width, height: self.playView.frame.height)
//        print(playView.lirik)
//        print(playController.shouldAutorotate)
//
//        present(playController, animated: true) {
//            self.playView = playView
//        }
    }
    
    func getData(){
        
        if UserDefaults.standard.string(forKey: "isPlaying") == "true"{
            songTitle = nowPlayingSongTitle
            referenceHeaderView?.nowPlayingSongTitle.text = songTitle
            referenceHeaderView?.nowPlayingSinger.text = songSinger
            referenceAlbumImageView?.nowPlayingAlbumImage.image = albumImage
            referencePlayView?.btnPrevious.isEnabled = true
            referencePlayView?.btnNext.isEnabled = true
            referencePlayView?.btnPlay.setImage(#imageLiteral(resourceName: "Pause Button (Big)"), for: .normal)
            referenceAlbumImageView?.nowPlayingAlbumImage.image = nowPlayingAlbumImage
//            referenceHeaderView?.albumImage.image = nowPlayingAlbumImage
            
            if let nowPlaying = MPMusicPlayerApplicationController.applicationQueuePlayer.nowPlayingItem{
                referencePlayView?.timeSlider.maximumValue = Float(nowPlayingTotalDuration)
                nowPlayingTotalDuration = Int(nowPlaying.playbackDuration)
                referencePlayView?.timeSlider.maximumValue = Float(nowPlayingTotalDuration)
                referenceAlbumImageView?.nowPlayingAlbumImage.image = nowPlaying.artwork?.image(at: CGSize(width: (referenceAlbumImageView?.nowPlayingAlbumImage.frame.width)!, height: (referenceAlbumImageView?.nowPlayingAlbumImage.frame.height)!))
                referenceAlbumImageView?.nowPlayingAlbumImage.layer.cornerRadius = 10
                nowPlayingSongSinger = nowPlaying.artist!
                referenceHeaderView?.nowPlayingSinger.text = nowPlayingSongSinger
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime),
                userInfo: nil, repeats: true)
            }
        }else{
            songTitle = "Tidak Sedang Memutar Lagu"
            referenceHeaderView?.nowPlayingSongTitle.text = songTitle
            referenceHeaderView?.nowPlayingSinger.text = ""
            referencePlayView?.btnPrevious.isEnabled = false
            referencePlayView?.btnNext.isEnabled = false
            referenceAlbumImageView?.nowPlayingAlbumImage.image = #imageLiteral(resourceName: "tidak sedang memutar image")
        }
        
    }
    
//    func getLyric()
//    {
//        if let nowPlaying = MPMusicPlayerController.applicationMusicPlayer.nowPlayingItem{
//            MXMLyricsAction.sharedExtension()?.findLyricsForSong(withTitle: nowPlaying.title, artist: nowPlaying.artist, album: nowPlaying.albumTitle, artWork: nowPlaying.artwork?.image(at: CGSize(width: 100, height: 100)), currentProgress: mediaPlayer.currentPlaybackTime, trackDuration: nowPlaying.playbackDuration, for: MusicPlayerViewController, sender: sender, competionHandler: nil)
//        }
//    }
    
    @objc func updateTime(){
        nowPlayingCurrentTime = Int(mediaPlayer.currentPlaybackTime)
        let minutes = nowPlayingCurrentTime/60
        let seconds = nowPlayingCurrentTime - minutes * 60
        referencePlayView?.currentTime.text = String(String(format: "%02d:%02d", minutes,seconds) as String)
    }
        
    @objc func updateSlider() {
        let player = mediaPlayer
        referencePlayView?.timeSlider.value = Float(player.currentPlaybackTime)
    }
    
    func updateTotalDuration(){
        let minutes = nowPlayingTotalDuration/60
        let seconds = nowPlayingTotalDuration - minutes * 60
        referencePlayView?.timeDuration.text = String(format: "%02d:%02d", minutes,seconds) as String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.referenceMusicPlayerMini?.songTitle.text = nowPlayingSongTitle
        vc.referenceMusicPlayerMini?.photoAlbum.image = nowPlayingAlbumImage
    }
    
    
}

extension MusicPlayerViewController: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
//            doNextSong()
//            musicIsPlaying = true
        }
    }
}

//===========================================================================================================================
//Extension For Convert Signal (from: rajabun)
//===========================================================================================================================
extension MusicPlayerViewController: SignalProvider
{
    // Returns a page containing `sampleCount` samples from the
    // `samples` array and increments `pageNumber`.
    func getSignal() -> [Float]
    {
        let start = pageNumber * sampleCount
        let end = (pageNumber + 1) * sampleCount
        
        let page = Array(samples[start ..< end])
        
        pageNumber += 1
        
        if (pageNumber + 1) * sampleCount >= samples.count
        {
            pageNumber = 0
        }
        
        let outputSignal: [Float]
        
        var forHapticParameter: [Float]
        
        outputSignal = page

        forHapticParameter = outputSignal.filter { $0 >= 0}
        let signalToParameter = forHapticParameter[100]
        
        //===========================================================================================================================
        //Prepare for Haptic (from: rajabun)
        //===========================================================================================================================
            print("continuousPalettePressed Function Worked !")
            // The intensity should be highest at the top, opposite of the iOS y-axis direction, so subtract.
            
            //For Damage Control/High Gain Sound :
            let dynamicIntensity: Float = signalToParameter
                    
            //For Laskar Pelangi/Low Gain Sound :
            //let dynamicIntensity: Float = signalToParameter*4.5
                    
            // Dynamic parameters range from -0.5 to 0.5 to map the final sharpness to the [0,1] range.
            
            //For Damage Control/High Gain Sound :
            let dynamicSharpness: Float = signalToParameter/2
                    
            //For Laskar Pelangi/Low Gain Sound :
            //let dynamicSharpness: Float = signalToParameter*2.5
            
            // Proceed if and only if the device supports haptics.
            if supportsHaptics
            {
                // Create dynamic parameters for the updated intensity & sharpness.
                let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                                          value: dynamicIntensity,
                                                                          relativeTime: 0)

                let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl,
                                                                          value: dynamicSharpness,
                                                                          relativeTime: 0)
                print("Haptic Parameter Changed !")
                        
                print(dynamicIntensity)
                print(dynamicSharpness)
                        
                DispatchQueue.main.async
                {
                    // Send dynamic parameters to the haptic player.
                    do
                    {
                        try self.continuousPlayer.sendParameters([intensityParameter, sharpnessParameter],
                                                                    atTime: 0)
                        print("Haptic Parameter Send !")
                    }
                    catch let error
                    {
                        print("Dynamic Parameter Error: \(error)")
                    }
                            
                    // Warm engine.
                    do
                    {
                        // Begin playing continuous pattern.
                        try self.continuousPlayer.start(atTime: CHHapticTimeImmediate)
                        print("Haptic Continuous Player Started !")
                    }
                    catch let error
                    {
                        print("Error starting the continuous haptic player: \(error)")
                    }
                }
                        
            }
        //===========================================================================================================================
        
        renderSignalAsFrequencyDomainGraph(signal: outputSignal)
        
        return outputSignal
    }
    //===========================================================================================================================
    //Function for Rendering Signal (from: rajabun)
    //===========================================================================================================================
    func renderSignalAsFrequencyDomainGraph(signal: [Float])
    {
        guard let frequencyDomain = forwardDCT?.transform(signal)
            else
        {
            return
        }

        DispatchQueue.main.async
        {
            let index = self.frequencyDomainGraphLayerIndex % self.frequencyDomainGraphLayers.count
            
            GraphUtility.drawGraphInLayer(self.frequencyDomainGraphLayers[index],
                                          strokeColor: #colorLiteral(red: 0.3254901961, green: 0.8901960784, blue: 0.7803921569, alpha: 1),
                                          lineWidth: 2,
                                          values: frequencyDomain,
                                          minimum: -20,
                                          maximum: 20,
                                          hScale: 1)
            
            self.frequencyDomainGraphLayers.forEach
            {
                if let alpha = $0.strokeColor?.alpha
                {
                    $0.strokeColor = #colorLiteral(red: 0.3254901961, green: 0.8901960784, blue: 0.7803921569, alpha: 1)
                }
            }
            
            self.frequencyDomainGraphLayerIndex += 1
        }
    }
    //===========================================================================================================================
}
//===========================================================================================================================

//===========================================================================================================================
//Extension For Preparing and Create Engine for Haptic
//===========================================================================================================================

//For Haptic Feedback
extension MusicPlayerViewController
{
    /// - Tag: CreateAndStartEngine
           func createAndStartHapticEngine()
           {
               print("createAndStartHapticEngine Function Worked !")
               // Create and configure a haptic engine.
               do
               {
                   engine = try CHHapticEngine()
                   print("Haptic Engine Created !")
               }
               catch let error
               {
                   fatalError("Engine Creation Error: \(error)")
               }
               
               // Mute audio to reduce latency for collision haptics.
               //engine.playsHapticsOnly = true
               
               // The stopped handler alerts you of engine stoppage.
               engine.stoppedHandler =
                { reason in
                   print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
                   switch reason
                   {
                    case .audioSessionInterrupt: print("Audio session interrupt")
                    case .applicationSuspended: print("Application suspended")
                    case .idleTimeout: print("Idle timeout")
                    case .systemError: print("System error")
                    case .notifyWhenFinished: print("Playback finished")
                    @unknown default:
                       print("Unknown error")
                   }
               }
               
               // The reset handler provides an opportunity to restart the engine.
               engine.resetHandler =
                {
                   print("Reset Handler: Restarting the engine.")
                   
                   do
                   {
                       // Try restarting the engine.
                       try self.engine.start()
                       
                       // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
                       self.engineNeedsStart = false
                       print("Haptic Engine Restarted !")
                   }
                   catch
                   {
                       print("Failed to start the engine")
                   }
               }
               
               // Start the haptic engine for the first time.
               do
               {
                   try self.engine.start()
                   print("Haptic Engine Started for the first time !")
               }
               catch
               {
                   print("Failed to start the engine: \(error)")
               }
           }
           
           /// - Tag: CreateContinuousPattern
           func createContinuousHapticPlayer()
           {
               print("createContinuousHapticPlayer Function Worked !")
            
               // Create an intensity parameter:
               let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
                                                      value: initialIntensity)
               
               // Create a sharpness parameter:
               let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
                                                      value: initialSharpness)
               
               // Create a continuous event with a long duration from the parameters.
               let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
                                                   parameters: [intensity, sharpness],
                                                   relativeTime: 0,
                                                   duration: 100)
               
               print("Haptic Event Created !")
            
               do
               {
                   // Create a pattern from the continuous haptic event.
                   let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
                   
                   // Create a player from the continuous haptic pattern.
                   continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
                
                print("Haptic Pattern Created !")
                   
               }
               catch let error
               {
                   print("Pattern Player Creation Error: \(error)")
               }

           }
        
        private func addObservers()
        {
            print("addObservers Function Worked !")
            backgroundToken = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                                     object: nil,
                                                                     queue: nil)
            { _ in
                guard self.supportsHaptics
                else
                {
                    return
                }
                // Stop the haptic engine.
                self.engine.stop(completionHandler:
                { error in
                    if let error = error
                    {
                        print("Haptic Engine Shutdown Error: \(error)")
                        return
                    }
                    self.engineNeedsStart = true
                })
            }
            foregroundToken = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                                     object: nil,
                                                                     queue: nil)
            { _ in
                guard self.supportsHaptics
                else
                {
                    return
                }
                // Restart the haptic engine.
                self.engine.start(completionHandler:
                    { error in
                    if let error = error
                    {
                        print("Haptic Engine Startup Error: \(error)")
                        return
                    }
                    self.engineNeedsStart = false
                })
            }
        }
        
        func continuousPalettePressed()
        {
            //Semua isinya dipindahin ke fungsi getSignal()
        }
}

//===========================================================================================================================
extension MusicPlayerViewController: GetLyricDelegate{
    func getLyric(sender: UIButton) {
        if let nowPlaying = MPMusicPlayerController.applicationMusicPlayer.nowPlayingItem{
            MXMLyricsAction.sharedExtension()?.findLyricsForSong(withTitle: nowPlaying.title, artist: nowPlaying.artist, album: nowPlaying.albumTitle, artWork: nowPlaying.artwork?.image(at: CGSize(width: 100, height: 100)), currentProgress: mediaPlayer.currentPlaybackTime, trackDuration: nowPlaying.playbackDuration, for: self, sender: sender, competionHandler: nil)
        }
        print("fungsi GetLyric berhasil")
    }
}
