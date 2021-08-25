//
//  ViewController.swift
//  AgoraVoiceCallDemo
//
//  Created by unthinkable-mac-0025 on 25/08/21.
//

import UIKit
import AgoraRtcKit


//MARK: - Global Variables
let AppID: String = "c3a94e784e6741e9a08779dc87b66cf4"
// assign Token to nil if you have not enabled app certificate
let Token: String? = "006c3a94e784e6741e9a08779dc87b66cf4IAARGbRhEqBJq3XzqOLaSyCk96P2hRDV38a2RSZhQgm0aCMni+gAAAAAEAALrnX4Lk8nYQEAAQAuTydh"
let EFFECT_ID:Int32 = 1


class ViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var controlButtonsView: UIView!
    @IBOutlet var joinButton: UIButton!
    
    //MARK: - Private Variables
    var agoraKit: AgoraRtcEngineKit?
    
    
    //MARK: - IBActions
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        joinChannel()
        joinButton.isHidden = true
        unHideControlButtons()
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        leaveChannel()
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        // Stops/Resumes sending the local audio stream.
        agoraKit?.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickSwitchSpeakerButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        // Enables/Disables the audio playback route to the speakerphone.
        //
        // This method sets whether the audio is routed to the speakerphone or earpiece. After calling this method, the SDK returns the onAudioRouteChanged callback to indicate the changes.
        agoraKit?.setEnableSpeakerphone(sender.isSelected)
    }
    
    @IBAction func startAudioEffectButtonPressed(_ sender: UIButton) {
        playEffect()
    }
    
    @IBAction func stopAudioEffectButtonpressed(_ sender: UIButton) {
        agoraKit?.stopAllEffects()
    }
    
    @IBAction func startAudioMixingButtonPressed(_ sender: UIButton) {
        startAudioMixing()
    }
    
    @IBAction func stopAudioMixingButtonPressed(_ sender: UIButton) {
        agoraKit?.stopAudioMixing()
    }
}

//MARK: - Lifecycle Methods
extension ViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeAgoraEngine()
        joinChannel()
        
        joinButton.isHidden = true
    }
}

//MARK: - Agora RTC Manager
extension ViewController{
    
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
        hideControlButtons()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func initializeAgoraEngine() {
        // Initializes the Agora engine with your app ID.
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
    }
    
    func joinChannel() {
        print("Joining a channel")
        // Allows a user to join a channel.
        agoraKit?.joinChannel(byToken: Token, channelId: "demoChannel", info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
            print("Joined the channel")
            self.agoraKit?.setEnableSpeakerphone(true)
            UIApplication.shared.isIdleTimerDisabled = true
        })
    }
}

//MARK: - Audio Mixing methods
extension ViewController{
    func startAudioMixing(){
        // Specifies the absolute path of the local or online music file that you want to play.
        guard let filePath = Bundle.main.path(forResource: "audiomixing", ofType: "mp3") else {return}
        // Sets whether to only play a music file on the local client. true represents that only the local user can hear the music; false represents that both the local user and remote users can hear the music.
        let loopback = false
        // Sets whether to replace the audio captured by the microphone with a music file. true represents that the user can only hear music; false represents that the user can hear both the music and the audio captured by the microphone.
        let replace = false
        // Sets the number of times to play the music file. 1 represents play the file once.
        let cycle = 1
        // Sets the playback position (ms) of the music file. 500 represents that the playback starts at the 500 ms mark of the music file.
        let startPos = 500
        // Starts to play the music file.
        agoraKit?.startAudioMixing(filePath, loopback: loopback, replace: replace, cycle: cycle, startPos: startPos)
    }
}

//MARK: - Audio Effects methods
extension ViewController{
    func preLoadEffect(){
        //get the fiel path of the sound track
        guard let filepath = Bundle.main.path(forResource: "audioeffect", ofType: "mp3") else {return}
        
        agoraKit?.preloadEffect(EFFECT_ID, filePath: filepath)
    }
    
    func unloadEffect(){
        agoraKit?.unloadEffect(EFFECT_ID)
    }
    
    func playEffect(){
        // Sets the number of times the audio effect loops. -1 represents an infinite loop.
        let loopCount = 1
        // Sets the pitch of the audio effect. The value range is 0.5 to 2.0, where 1.0 is the original pitch.
        let pitch = 1
        // Sets the spatial position of the audio effect. The value range is -1.0 to 1.0.
        // -1.0 represents the audio effect occurs on the left; 0 represents the audio effect occurs in the front; 1.0 represents the audio effect occurs on the right.
        let pan = 1
        // Sets the volume of the audio effect. The value range is 0 to 100. 100 represents the original volume.
        let gain = 100.0
        // Sets whether to publish the audio effect to the remote users. true represents that both the local user and remote users can hear the audio effect; false represents that only the local user can hear the audio effect.
        let publish = true
        // Sets the playback position (ms) of the audio effect file. 500 represents that the playback starts at the 500 ms mark of the audio effect file.
        let startPos = 500;
        
        guard let filePath = Bundle.main.path(forResource: "audioeffect", ofType: "mp3") else {return}
        // Plays the specified audio effect file.
        agoraKit?.playEffect(EFFECT_ID, filePath: filePath, loopCount: Int32(loopCount), pitch: Double(pitch), pan: Double(pan), gain: gain, publish: publish, startPos: Int32(startPos))
       
    }
}

extension ViewController : AgoraRtcEngineDelegate{
    
    // Occurs when the local audio effect playback finishes.
    func rtcEngineDidAudioEffectFinish(_ engine: AgoraRtcEngineKit, soundId: Int) {
        print("done Playing the sound track")
        // Stops playing a specified audio effect file.
        agoraKit?.stopEffect(EFFECT_ID)
        // Stops playing all audio effect files.
        agoraKit?.stopAllEffects()
    }
    
    // Occurs when the state of the local user's music file changes.
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioMixingStateDidChanged state: AgoraAudioMixingStateCode, reason: AgoraAudioMixingReasonCode) {
        
        print("music playback state changed")
        
        // Stops playing the music file.
        //agoraKit?.stopAudioMixing()
    }
}


//MARK: - Private Functions
private extension ViewController{
    func hideControlButtons() {
        controlButtonsView.isHidden = true
        joinButton.isHidden = false
    }
    
    func unHideControlButtons() {
        controlButtonsView.isHidden = false
    }
}
