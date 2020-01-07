//
//  NewMusicPlayerViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 23/12/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import MediaPlayer
import Accelerate
import CoreHaptics

//===========================================================================================================================
//Global Property For Signal Sample Count (from: rajabun)
//===========================================================================================================================
let sampleCount = 1024
//===========================================================================================================================

//===========================================================================================================================
//Global Property For Sample Sound (from: rajabun)
//===========================================================================================================================
var samples: [Float] = [0.0]
//===========================================================================================================================

class NewMusicPlayerViewController: UIViewController {

    @IBOutlet var songTitle: MarqueeLabel!
    @IBOutlet var songSinger: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var albumView: UIView!
    @IBOutlet var waveformView: UIView!
    @IBOutlet var playButtonView: UIView!
    @IBOutlet var footerView: UIView!
    
    var referenceHeaderView: HeaderView?
    var referenceAlbumView: AlbumView?
    var referenceWaveformView: WaveformView?
    var referencePlayButtonView: PlayButtonView?
    var referenceFooterView: FooterView?
    
    var songDuration: Int = 0
    var (minute, second) = (0,0)
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
        UserDefaults.standard.set("false", forKey: "isPlaying")
        getData()
        referenceAlbumView?.timeProgress.trackColor = #colorLiteral(red: 0.6783789396, green: 0.6743485928, blue: 0.6814785004, alpha: 1)
        // Do any additional setup after loading the view.
        
        //===========================================================================================================================
        //Condition to prevent error if song isn't called from iTunes (from: rajabun)
        //===========================================================================================================================
        if mediaPlayer.nowPlayingItem?.assetURL == nil
        {
            return
        }
        //===========================================================================================================================
        
//        //===========================================================================================================================
//        //Function For Get Sample From Music Kit and Play Audio from AudioUtilities Model (from: rajabun)
//        //===========================================================================================================================
//        getSampleFromMusicKit()
//        playConvertedSong()
//        //===========================================================================================================================
        
        
    }
    
    //===========================================================================================================================
    //Function For Add Waveform View to SubView (from: rajabun)
    //===========================================================================================================================
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        frequencyDomainGraphLayers.forEach
        {
            $0.frame = waveformView.frame.insetBy(dx: 0, dy: 50)
        }
        
        envelopeLayer.frame = waveformView.frame.insetBy(dx: 0, dy: 50)
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
    
    //===========================================================================================================================
    //Function For Prepare Waveform View And Haptics
    //===========================================================================================================================
    func prepareWaveformAndHaptics()
    {
        //===========================================================================================================================
        //Function For Render Waveform View (from: rajabun)
        //===========================================================================================================================
        renderGraphView()
        //===========================================================================================================================

        //getLibrary()
        //playLibrary()
        
        //AudioUtilities.configureAudioUnit(signalProvider: self)
       
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
    
    func playConvertedSong()
    {
        AudioUtilities.configureAudioUnit(signalProvider: self)
    }
    
    func pauseConvertedSong()
    {
        AudioUtilities.pauseAudio()
    }
    
    //===========================================================================================================================
    //Global Function For Get Sample and Play Sound (from: rajabun)
    //===========================================================================================================================
    func getSampleFromMusicKit()
    {
        //let musicPlayerVC = MusicPlayerViewController()
        //===========================================================================================================================
        //Stop the Audio Hardware in Audio Unit
        //===========================================================================================================================
        AudioUtilities.stopAudioFirstTime()
        //===========================================================================================================================
        
        //===========================================================================================================================
        //Function For Play Selected Song From MusicKit
        //===========================================================================================================================
        mediaPlayer.prepareToPlay()
        mediaPlayer.play()
        //===========================================================================================================================
        
        //===========================================================================================================================
        //Property For Get Sample Sound From MusicKit
        //===========================================================================================================================
        let samplesFromMusicKit: [Float] =
        {
            guard let samples = AudioUtilities.getAudioSamples(
                urlFromMusicKit: mediaPlayer.nowPlayingItem?.assetURL)
            else
            {
                    fatalError("Unable to parse the audio resource.")
            }
        
            return samples
        }()
        samples = samplesFromMusicKit
        print("Asset = ", mediaPlayer.nowPlayingItem?.assetURL)
        print("samplesFromMusicKit =", samplesFromMusicKit.count)
        //===========================================================================================================================
        mediaPlayer.stop()
        DispatchQueue.global(qos: .userInitiated).async
        {
            AudioUtilities.configureAudioUnit(signalProvider: self)
        }
    }
    //===========================================================================================================================
    
    func setView(){
//        if let referenceHeaderView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView{
//            headerView.addSubview(referenceHeaderView)
//            referenceHeaderView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
//            self.referenceHeaderView = referenceHeaderView
//        }
        
        if let referenceAlbumView = Bundle.main.loadNibNamed("AlbumView", owner: self, options: nil)?.first as? AlbumView{
            albumView.addSubview(referenceAlbumView)
            referenceAlbumView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceAlbumView = referenceAlbumView
            referenceAlbumView.albumImage.layer.cornerRadius = referenceAlbumView.albumImage.frame.height/2
        }
        
        if let referenceWaveformView = Bundle.main.loadNibNamed("WaveformView", owner: self, options: nil)?.first as? WaveformView{
            waveformView.addSubview(referenceWaveformView)
            referenceWaveformView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceWaveformView = referenceWaveformView
        }
        
        if let referencePlayButtonView = Bundle.main.loadNibNamed("PlayButtonView", owner: self, options: nil)?.first as? PlayButtonView{
            playButtonView.addSubview(referencePlayButtonView)
            referencePlayButtonView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referencePlayButtonView = referencePlayButtonView
        }
        
        if let referenceFooterView = Bundle.main.loadNibNamed("FooterView", owner: self, options: nil)?.first as? FooterView{
            footerView.addSubview(referenceFooterView)
            referenceFooterView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceFooterView = referenceFooterView
        }
    }
    
    func getData(){
        if UserDefaults.standard.string(forKey: "isPlaying") == "true"{
            if let nowPlaying = MPMusicPlayerApplicationController.applicationQueuePlayer.nowPlayingItem{
                referenceAlbumView?.albumImage.image = nowPlaying.artwork?.image(at: CGSize(width: (referenceAlbumView?.albumImage.frame.height)!, height: (referenceAlbumView?.albumImage.frame.width)!))
                songTitle.text = nowPlaying.title
                songSinger.text = nowPlaying.artist
                referencePlayButtonView?.playButton.setImage(#imageLiteral(resourceName: "Pause Button Wide"), for: .normal)
            }
            
        }else{
            referenceAlbumView?.albumImage.image = #imageLiteral(resourceName: "tidak sedang memutar image")
            songTitle.text = "Tidak sedang memutar lagu - "
            songSinger.text = " "
//            referenceAlbumView?.currentTime.text = "00:00"
        }
    }
    
    func getSongDuration(){
        if let nowPlaying = MPMusicPlayerApplicationController.applicationQueuePlayer.nowPlayingItem{
                songDuration = Int(nowPlaying.playbackDuration)
                currentTime = Int(mediaPlayer.currentPlaybackTime)
                duration = nowPlaying.playbackDuration
                referenceAlbumView?.timeProgress.setProgressWithAnimation(duration: duration!, value: 1)
                referenceAlbumView?.timeProgress.progressColor = #colorLiteral(red: 0, green: 0.8623425364, blue: 0.690444231, alpha: 1)
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime),
                userInfo: nil, repeats: true)
    //            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(songDurationProgress),
    //            userInfo: nil, repeats: true)
        }
        print(songDuration)
    }
    
    @objc func updateTime(){
//        currentTime = Int(mediaPlayer.currentPlaybackTime)
//        let minutes = currentTime/60
//        let seconds = currentTime - minutes * 60
//        referenceAlbumView?.currentTime.text = String(String(format: "%02d:%02d", minutes,seconds) as String)
//        if currentTime == Int(duration!){
//            UserDefaults.standard.set("false", forKey: "isPlaying")
//        }
        
        second += 1
        if second == 60{
            minute += 1
            second = 0
        }
        
        let secondString = second > 9 ? "\(second)" : "0\(second)"
        let minuteString = minute > 9 ? "\(minute)" : "0\(minute)"
        referenceAlbumView?.currentTime.text = "\(minuteString):\(secondString)"
        
    }
        
    func songDurationProgress(){
        referenceAlbumView?.timeProgress.trackColor = #colorLiteral(red: 0.6783789396, green: 0.6743485928, blue: 0.6814785004, alpha: 0.8032962329)
        referenceAlbumView?.timeProgress.progressColor = #colorLiteral(red: 0, green: 0.8623425364, blue: 0.690444231, alpha: 1)
    //        timeProgress.setProgressWithAnimation(duration: duration!, value: Float(currentTime/songDuration))
    }
    
    @IBAction func addSongAction(_ sender: UIButton) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = false
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
        prepareWaveformAndHaptics()
    }
    
}

extension NewMusicPlayerViewController: MPMediaPickerControllerDelegate{
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        mediaPlayer.play()
        mediaPicker.dismiss(animated: true) {
            self.getSongDuration()
            self.getData()
        }
        print("lagu diplay")
        
        print("get data berhasil")
        print("get duration berhasil")
        mediaPicker.showsItemsWithProtectedAssets = false
//        getSongDuration()
//        getData()
        UserDefaults.standard.set("true", forKey: "isPlaying")
        getSampleFromMusicKit()
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}

//===========================================================================================================================
//Extension For Convert Signal (from: rajabun)
//===========================================================================================================================
extension NewMusicPlayerViewController: SignalProvider
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
        
        //For Damage Control/High Gain Sound :
        let signalToParameter = forHapticParameter[100]
        
        //For Laskar Pelangi/Low Gain Sound :
        //let signalToParameter = outputSignal[100]
        
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
extension NewMusicPlayerViewController
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
}

//===========================================================================================================================
