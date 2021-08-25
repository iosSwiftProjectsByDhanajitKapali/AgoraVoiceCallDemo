//
//  ViewController.swift
//  AgoraVoiceCallDemo
//
//  Created by unthinkable-mac-0025 on 25/08/21.
//

import UIKit
import AgoraRtcKit


let AppID: String = "c3a94e784e6741e9a08779dc87b66cf4"
// assign Token to nil if you have not enabled app certificate
let Token: String? = "006c3a94e784e6741e9a08779dc87b66cf4IAARGbRhEqBJq3XzqOLaSyCk96P2hRDV38a2RSZhQgm0aCMni+gAAAAAEAALrnX4Lk8nYQEAAQAuTydh"

class ViewController: UIViewController {

    @IBOutlet weak var controlButtonsView: UIView!
    @IBOutlet var joinButton: UIButton!
    
    var agoraKit: AgoraRtcEngineKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeAgoraEngine()
        joinChannel()
        
        joinButton.isHidden = true
    }
    
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
}

extension ViewController{
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
        hideControlButtons()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func hideControlButtons() {
        controlButtonsView.isHidden = true
        joinButton.isHidden = false
    }
    
    func unHideControlButtons() {
        controlButtonsView.isHidden = false
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

extension ViewController : AgoraRtcEngineDelegate{
    
}
