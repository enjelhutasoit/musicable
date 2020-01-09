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

class AudioUtilities: NSObject
{
    static var audioRunning = false             // RemoteIO Audio Unit running flag
    static var samplesFirstComparison:[Float] = [0.0]
    static var samplesSecondComparison:[Float] = [0.0]
    
    static var flagAudioUnit: AUAudioUnit?
    static var flagUrl: URL?
    
    static let audioBasic = AudioStreamBasicDescription()
    var referencePlayButtonView: PlayButtonView?
    
    // Returns an array of single-precision values for the specified audio resource.
//    static func getAudioSamples(forResource: String, withExtension: String) -> [Float]?
    static func getAudioSamples(urlFromMusicKit: URL?) -> [Float]?
    {//urlFromMusicKit: URL
//        guard let path = Bundle.main.url(forResource: forResource,
//                                         withExtension: withExtension)
//        else
//        {
//                return nil
//        }
        
//        let asset = AVAsset(url: path.absoluteURL)
        let asset = AVAsset(url: urlFromMusicKit!)
        
        flagUrl = urlFromMusicKit
        print("URL Flag = ", flagUrl)
        
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
        
        print("samples =", samples.count)
        
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

        if samplesFirstComparison.count == 0
        {
            samplesFirstComparison = samples
        }
        else
        {
            samplesFirstComparison = samplesSecondComparison
            samplesSecondComparison = samples
        }
        print("samplesFirstComparison =", samplesFirstComparison.count)
        print("samplesSecondComparison =", samplesSecondComparison.count)
        
        return samples
    }
    
    // Configures audio unit to request and play samples from `signalProvider`.
    static func configureAudioUnit(signalProvider: SignalProvider)
    {
        if audioRunning
        {
            if samplesFirstComparison.count == samplesSecondComparison.count
            {
                return
            }
            else
            {
                
            }
        }
        else
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
            
            flagAudioUnit = ioUnit

            do
            {
                try flagAudioUnit!.inputBusses[0].setFormat(outputRenderFormat)
            }
            catch
            {
                print("Error setting format on ioUnit")
                return
            }
            
            //ioUnit.outputProvider =
            flagAudioUnit!.outputProvider =
            {
                (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                timestamp: UnsafePointer<AudioTimeStamp>,
                frameCount: AUAudioFrameCount,
                busIndex: Int,
                rawBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus in
                
                let bufferList = UnsafeMutableAudioBufferListPointer(rawBufferList)
                if !bufferList.isEmpty
                {//cek timestamp di bagian mana playnya
                    let signal = signalProvider.getSignal()
                    
                    bufferList[0].mData?.copyMemory(from: signal,
                                                    byteCount: sampleCount * MemoryLayout<Float>.size)
                }
//                else
//                {
//                    bufferList[0].mData?.deallocate()
//                }
                return noErr
            }
             
            do
            {
                try flagAudioUnit!.allocateRenderResources()
            }
            catch
            {
                print("Error allocating render resources")
                return
            }
            
            do
            {
                try flagAudioUnit!.startHardware()
                audioRunning = true
            }
            catch
            {
                print("Error starting audio")
            }
        }
        
    }
    
    static func pauseAudio()
    {
        if audioRunning
        {
            flagAudioUnit?.stopHardware()
            audioRunning = false
            timer?.invalidate()
        }
        else
        {
            do
            {
                try flagAudioUnit?.startHardware()
                audioRunning = true
            }
            catch
            {
                print("Error starting audio")
            }
        }
    }
    
    static func stopAudioFirstTime()
    {
        flagAudioUnit?.stopHardware()
        audioRunning = false
    }
}

protocol SignalProvider
{
    func getSignal() -> [Float]
}
