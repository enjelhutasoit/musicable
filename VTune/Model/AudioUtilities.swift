//
//  AudioUtilities.swift
//  VTune
//
//  Created by Muhammad Rajab Priharsanto on 19/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

/*
Abstract:
Class containing methods for tone generation.
*/

import AudioToolbox
import AVFoundation
import Accelerate
import MediaPlayer

class AudioUtilities: NSObject
{
    var myMediaPlayer = MPMusicPlayerController.systemMusicPlayer
    
    // Returns an array of single-precision values for the specified audio resource.
    static func getAudioSamples(forResource: String, withExtension: String) -> [Float]?
    {//urlFromMusicKit: URL
        guard let path = Bundle.main.url(forResource: forResource,
                                         withExtension: withExtension)
        else
        {
                return nil
        }
        
        let asset = AVAsset(url: path.absoluteURL)
        
        guard
            let reader = try? AVAssetReader(asset: asset),
            let track = asset.tracks.first
        else
        {
                return nil
        }
        
        let outputSettings: [String: Int] =
        [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVNumberOfChannelsKey: 1,
            AVLinearPCMIsBigEndianKey: 0,
            AVLinearPCMIsFloatKey: 1,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsNonInterleaved: 1
        ]
        
        let output = AVAssetReaderTrackOutput(track: track,
                                              outputSettings: outputSettings)
        
        reader.add(output)
        reader.startReading()
        
        var samples = [Float]()
        
        while reader.status == .reading
        {
            if
                let sampleBuffer = output.copyNextSampleBuffer(),
                let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer)
            {
                
                    let bufferLength = CMBlockBufferGetDataLength(dataBuffer)
                
                    var data = [Float](repeating: 0,
                                       count: bufferLength / 4)
                    CMBlockBufferCopyDataBytes(dataBuffer,
                                               atOffset: 0,
                                               dataLength: bufferLength,
                                               destination: &data)
                
                    samples.append(contentsOf: data)
            }
        }

        return samples
    }
    
    // Configures audio unit to request and play samples from `signalProvider`.
    static func configureAudioUnit(signalProvider: SignalProvider)
    {
        let kOutputUnitSubType = kAudioUnitSubType_RemoteIO
        
        let ioUnitDesc = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kOutputUnitSubType,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        
        guard
            let ioUnit = try? AUAudioUnit(componentDescription: ioUnitDesc,
                                          options: AudioComponentInstantiationOptions()),
            let outputRenderFormat = AVAudioFormat(
                standardFormatWithSampleRate: ioUnit.outputBusses[0].format.sampleRate,
                channels: 1)
            else
            {
                    print("Unable to create outputRenderFormat")
                    return
            }
        
        do
        {
            try ioUnit.inputBusses[0].setFormat(outputRenderFormat)
        }
        catch
        {
            print("Error setting format on ioUnit")
            return
        }
        
        ioUnit.outputProvider =
        {
            (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
            timestamp: UnsafePointer<AudioTimeStamp>,
            frameCount: AUAudioFrameCount,
            busIndex: Int,
            rawBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus in
            
            let bufferList = UnsafeMutableAudioBufferListPointer(rawBufferList)
            if !bufferList.isEmpty
            {
                let signal = signalProvider.getSignal()
                
                bufferList[0].mData?.copyMemory(from: signal,
                                                byteCount: sampleCount * MemoryLayout<Float>.size)
            }
            
            return noErr
        }
        
        do
        {
            try ioUnit.allocateRenderResources()
        }
        catch
        {
            print("Error allocating render resources")
            return
        }
        
        do
        {
            try ioUnit.startHardware()
        }
        catch
        {
            print("Error starting audio")
        }
    }
}

protocol SignalProvider
{
    func getSignal() -> [Float]
}

extension AudioUtilities: MPMediaPickerControllerDelegate
{
    func getLibrary()
    {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        //myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        //self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    
    func playLibrary()
    {
        // Instantiate a new music player
        let myMediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
        // Add a playback queue containing all songs on the device
        myMediaPlayer.setQueue(with: .songs())
        // Start playing from the beginning of the queue
        myMediaPlayer.play()
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)
    {
        myMediaPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        //myMediaPlayer.play()
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)
    {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
