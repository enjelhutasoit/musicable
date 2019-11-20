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

class MusicPlayerViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var albumImageView: UIView!
    @IBOutlet weak var equalizerView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet var lyricView: UIVisualEffectView!
    @IBOutlet var lyricSubView: UIView!
    
    //    var trackId: Int = 0
//    var library = MusicLibrary().library
    
    var updater: CADisplayLink! = nil
    var effect: UIVisualEffect!
    
    var referenceHeaderView: MusicPlayerLyricHeader?
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
        defaultSong()
        MPVolumeView()
        
        albumImageSmall = referenceHeaderView?.albumImage.image
        albumImageSmallView = referenceHeaderView?.albumImage
        albumImageSmallView?.layer.cornerRadius = 7
        albumImageSmallView?.isHidden = true
        
        albumImageViewIsHidden = albumImageView
        referenceAlbumImageView?.nowPlayingAlbumImage.layer.cornerRadius = 10
        
        equalizerViewIsHidden = equalizerView
        lyricViewIsHidden = lyricView
        lyricViewIsHidden?.isHidden = true
        effect = lyricViewIsHidden?.effect
       
        nowPlayingTitle = referenceHeaderView?.nowPlayingSongTitle
        nowPlayingSinger = referenceHeaderView?.nowPlayingSinger
        nowPlayingAlbum = referenceAlbumImageView?.nowPlayingAlbumImage
        albumImageSmall = nowPlayingAlbum?.image
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
    //===========================================================================================================================
    
    override func viewWillAppear(_ animated: Bool) {
//        setUpdater()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        updater.invalidate()
    }
    
    func defaultSong() {
        if musicIsPlaying == true {
            do {
                let audioPath = Bundle.main.path(forResource: dummyProduct[thisSong].songTitle , ofType: ".mp3")
                try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            } catch {
                print("Eror!")
            }
        }
    }
    
    func setUpdater() {
        updater = CADisplayLink(target: self, selector: #selector(updatingProgressItems))
        updater.preferredFramesPerSecond = 2
        updater.add(to: .current, forMode: .default)
    }
    
    @objc func updatingProgressItems() {

        audioPlayer?.delegate = self
                
        referencePlayView?.timeSlider.setValue(Float(audioPlayer!.currentTime), animated: true)
        referencePlayView?.timeSlider.maximumValue = Float(audioPlayer!.duration)
        
        
        // making normal time format of song
        let currentTimePlaying = Int(audioPlayer!.currentTime)
        let minutesPlaying = currentTimePlaying / 60
        let secondsPlaying = currentTimePlaying - minutesPlaying * 60
        referencePlayView?.currentTime.text = NSString(format: "%02d:%02d", minutesPlaying, secondsPlaying) as String
        
        let currentTimeDuration = Int(audioPlayer!.duration)
        let minutesDuration = currentTimeDuration / 60
        let secondsDuration = currentTimeDuration - minutesDuration * 60
        referencePlayView?.timeDuration.text = NSString(format: "%02d:%02d", minutesDuration, secondsDuration) as String
        
        if nowPlayingSongTitle == "Menunggu Kamu (OST Jelita Sejuba)"{
            switch (minutesDuration,secondsDuration) {
            case (0,18...29): referenceLyricView?.lblLirik.text = "'Ku selalu mencoba untuk menguatkan hati"
            case (0,31...37): referenceLyricView?.lblLirik.text = "Dari kamu yang belum juga kembali"
            case (0,38...51): referenceLyricView?.lblLirik.text = "Ada satu keyakinan yang membuatku bertahan"
            case (0,52...58): referenceLyricView?.lblLirik.text = "Penantian ini 'kan terbayar pasti"
            case (1,0...5): referenceLyricView?.lblLirik.text = "Lihat aku, sayang, yang sudah berjuang"
            case (1,6...12): referenceLyricView?.lblLirik.text = "Menunggumu datang, menjemputmu pulang"
            case (1,13...20): referenceLyricView?.lblLirik.text = "Ingat selalu, sayang, hatiku kau genggam"
            case (1,21...30): referenceLyricView?.lblLirik.text = "Aku tak 'kan pergi, menunggu kamu di sini"
            case (1,34...38): referenceLyricView?.lblLirik.text = "Tetap di sini"
            case (1,43...47): referenceLyricView?.lblLirik.text = "Jika bukan kepadamu"
            case (1,48...55): referenceLyricView?.lblLirik.text = "aku tidak tahu lagi"
            case (1,56...59): referenceLyricView?.lblLirik.text = "Pada siapa rindu ini 'kan kuberi"
            case (2,2...11): referenceLyricView?.lblLirik.text = "Pada siapa rindu ini 'kan kuberi, oh"
            case (2,12...20): referenceLyricView?.lblLirik.text = "Lihat aku, sayang, yang sudah berjuang"
            case (2,21...26): referenceLyricView?.lblLirik.text = "Menunggumu datang, menjemputmu pulang"
            case (2,27...34): referenceLyricView?.lblLirik.text = "Ingat selalu, sayang, hatiku kau genggam"
            case (2,35...44): referenceLyricView?.lblLirik.text = "Aku tak 'kan pergi, menunggu kamu di sini"
            case (2,49...51): referenceLyricView?.lblLirik.text = "Di sini"
            case (3,0...4): referenceLyricView?.lblLirik.text = "Lihat aku, sayang, sudah berjuang"
            case (3,5...12): referenceLyricView?.lblLirik.text = "Menunggumu datang, menjemputmu pulang"
            case (3,14...21): referenceLyricView?.lblLirik.text = "Ingat selalu, sayang, hatiku kau genggam"
            case (3,22...27): referenceLyricView?.lblLirik.text = "Aku tak 'kan pergi"
            case (3,28...40): referenceLyricView?.lblLirik.text = "Aku tak 'kan pergi, menunggu kamu di sini"
            default:
            referenceLyricView?.lblLirik.text = ""
            }
        }
//        if audioPlayer.isPlaying {
//            playButton.setImage(#imageLiteral(resourceName: "pause-btn"), for: .normal)
//        } else {
//            playButton.setImage(#imageLiteral(resourceName: "play-btn"), for: .normal)
//        }
    }
    
    func setView(){
        if let referenceHeaderView = Bundle.main.loadNibNamed("MusicPlayerLyricHeader", owner: self, options: nil)?.first as? MusicPlayerLyricHeader{
            headerView.addSubview(referenceHeaderView)
            referenceHeaderView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceHeaderView = referenceHeaderView
        }
        
        if let referenceAlbumImageView = Bundle.main.loadNibNamed("MusicPlayerAlbumImage", owner: self, options: nil)?.first as? MusicPlayerAlbumImage{
            albumImageView.addSubview(referenceAlbumImageView)
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
        
        if let referenceLyricView = Bundle.main.loadNibNamed("Lirik", owner: self, options: nil)?.first as? Lirik{
            lyricSubView.addSubview(referenceLyricView)
            referenceLyricView.frame = CGRect(x: 0, y: 0, width: lyricSubView.frame.width, height: lyricSubView.frame.height)
            self.referenceLyricView = referenceLyricView
        }
    }
    
    func getData(){
        if UserDefaults.standard.string(forKey: "isPlaying") == "true"{
            songTitle = nowPlayingSongTitle
            songSinger = nowPlayingSongSinger
            referenceHeaderView?.nowPlayingSongTitle.text = songTitle
            referenceHeaderView?.nowPlayingSinger.text = songSinger
            referenceAlbumImageView?.nowPlayingAlbumImage.image = albumImage
            referencePlayView?.btnPrevious.isEnabled = true
            referencePlayView?.btnNext.isEnabled = true
            referencePlayView?.btnPlay.setImage(#imageLiteral(resourceName: "Pause Button (Big)"), for: .normal)
            referenceAlbumImageView?.nowPlayingAlbumImage.image = nowPlayingAlbumImage
            referenceHeaderView?.albumImage.image = nowPlayingAlbumImage
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatingProgressItems), userInfo: nil, repeats: true)
        }else{
            songTitle = "Tidak Sedang Memutar Lagu"
            referenceHeaderView?.nowPlayingSongTitle.text = songTitle
            referenceHeaderView?.nowPlayingSinger.text = ""
            referencePlayView?.btnPrevious.isEnabled = false
            referencePlayView?.btnNext.isEnabled = false
            referenceAlbumImageView?.nowPlayingAlbumImage.image = #imageLiteral(resourceName: "tidak sedang memutar image")
            referenceHeaderView?.albumImage.image = #imageLiteral(resourceName: "tidak sedang memutar image")
        }
        
    }
    
    func updateTotalDuration(){
        let minutes = totalDuration/60
        let seconds = totalDuration - minutes * 60
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
            audioPlayer!.play()
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
                                          strokeColor: UIColor.blue.withAlphaComponent(1).cgColor,
                                          lineWidth: 2,
                                          values: frequencyDomain,
                                          minimum: -20,
                                          maximum: 20,
                                          hScale: 1)
            
            self.frequencyDomainGraphLayers.forEach
            {
                if let alpha = $0.strokeColor?.alpha
                {
                    $0.strokeColor = UIColor.blue.withAlphaComponent(alpha * 0.75).cgColor
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
