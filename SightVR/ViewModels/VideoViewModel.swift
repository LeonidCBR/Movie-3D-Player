//
//  VideoViewModel.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 07.03.2024.
//

import Foundation
import CoreMotion
import SpriteKit
import SceneKit
import MediaPlayer

protocol VideoViewModelDelegate: AnyObject {
    func videoDidClose()
}

/// A view model of the video view controller
final class VideoViewModel {
    let rendererDelegate: RendererDelegate
    let settingsProvider: SettingsProvider
    let videoPlayer: AVPlayer
    let motionManager: CMMotionManager
    let videoFile: UIDocument
    let leftScene: SCNScene
    let rightScene: SCNScene
    var allAvailableActions: [PlayerAction: () -> Void] = [:]
    weak var delegate: VideoViewModelDelegate?

    /// Left camera
    lazy var cameraNodeLeft: SCNNode = {
        guard let cameraNode = leftScene.rootNode.childNode(
            withName: SceneProperties.camera,
            recursively: false) else {
            return SCNNode()
        }
        return cameraNode
    }()

    /// Right camera
    lazy var cameraNodeRight: SCNNode = {
        guard let cameraNode = rightScene.rootNode.childNode(
            withName: SceneProperties.camera,
            recursively: false) else {
            return SCNNode()
        }
        return cameraNode
    }()

    /// Left dome represents a video scene
    lazy var domeNodeLeft: SCNNode = {
        guard let domeNode = leftScene.rootNode.childNode(
            withName: SceneProperties.sphere,
            recursively: false) else {
            return SCNNode()
        }
        domeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
        return domeNode
    }()

    /// Right dome represents a video scene
    lazy var domeNodeRight: SCNNode = {
        guard let domeNode = rightScene.rootNode.childNode(
            withName: SceneProperties.sphere,
            recursively: false) else {
            return SCNNode()
        }
        domeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, .pi)
        return domeNode
    }()

    var orientation: DeviceOrientation {
        return settingsProvider.orientation
    }

    var space: CGFloat {
        return settingsProvider.space
    }

    var gestures: Set<PlayerGesture> {
        return getGestures()
    }

    var isPlaying = false {
        didSet {
            if isPlaying {
                videoPlayer.play()
            } else {
                videoPlayer.pause()
            }
        }
    }

    init(with video: UIDocument,
         settingsProvider: SettingsProvider,
         motionManager: CMMotionManager,
         rendererDelegate: RendererDelegate,
         leftScene: SCNScene,
         rightScene: SCNScene) {
        self.videoFile = video
        let videoItem = AVPlayerItem(url: video.fileURL)
        self.videoPlayer = AVPlayer(playerItem: videoItem)
        self.settingsProvider = settingsProvider
        self.motionManager = motionManager
        self.rendererDelegate = rendererDelegate
        self.leftScene = leftScene
        self.rightScene = rightScene
    }

    func configurePlayer() {
        videoPlayer.preventsDisplaySleepDuringVideoPlayback = true
        createVideoScene()
        initScenePosition()
        configureCameras()
        configureActions()
        setupRemoteTransportControls()
        setupNowPlaying()
    }

    /// Create and prepare the video scene
    func createVideoScene() {
        // Create video scene
        let videoSKScene = SKScene(size: CGSize(width: SceneProperties.defaultWidth,
                                         height: SceneProperties.defaultHeight))
        videoSKScene.scaleMode = .aspectFit
        // Create a node for the video scene
        let videoSKNode = SKVideoNode(avPlayer: videoPlayer)
        videoSKNode.position = CGPoint(x: SceneProperties.defaultWidth / 2,
                                       y: SceneProperties.defaultHeight / 2)
        videoSKNode.size = videoSKScene.size
        videoSKScene.addChild(videoSKNode)
        domeNodeLeft.geometry?.firstMaterial?.diffuse.contents = videoSKScene
        domeNodeRight.geometry?.firstMaterial?.diffuse.contents = videoSKScene
    }

    /// Init view of the scene by rotating the sphere according the camera's view
    func initScenePosition() {
        domeNodeLeft.eulerAngles.z = cameraNodeLeft.eulerAngles.z
        domeNodeRight.eulerAngles.z = cameraNodeRight.eulerAngles.z + .pi
    }

    func configureCameras() {
        cameraNodeLeft.camera?.fieldOfView = settingsProvider.fieldOfView
        cameraNodeRight.camera?.fieldOfView = settingsProvider.fieldOfView
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [weak self] _ in // event
            guard let self = self else {
                return .noActionableNowPlayingItem
            }
            if self.videoPlayer.rate == 0.0 {
                self.videoPlayer.play()
                return .success
            }
            return .commandFailed
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] _ in // event
            guard let self = self else {
                return .noActionableNowPlayingItem
            }
            if self.videoPlayer.rate == 1.0 {
                self.videoPlayer.pause()
                return .success
            }
            return .commandFailed
        }
    }

    func setupNowPlaying() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = videoFile.localizedName
//        if let image = UIImage(named: "picture.jpg") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] =
//            MPMediaItemArtwork(boundsSize: image.size) { size in
//                return image
//            }
//        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = videoPlayer.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = videoPlayer.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = videoPlayer.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func startDeviceMotionUpdates() {
        let attitudeReferenceFrame = CMMotionManager.availableAttitudeReferenceFrames()
        if attitudeReferenceFrame.contains(.xArbitraryZVertical) {
            motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        } else {
            motionManager.startDeviceMotionUpdates()
        }
    }

    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    func play() {
        isPlaying = true
    }

    /// Play/pause
    func playPause() {
        isPlaying.toggle()
    }

    func seekBackward(by seconds: CMTimeValue) {
        let delta = CMTime(value: seconds, timescale: 1)
        let newTime = videoPlayer.currentTime() - delta
        videoPlayer.seek(to: newTime)
    }

    func rewindBackward() {
        seekBackward(by: 20)
    }

    func seekForward(by seconds: CMTimeValue) {
        let delta = CMTime(value: seconds, timescale: 1)
        let newTime = videoPlayer.currentTime() + delta
        videoPlayer.seek(to: newTime)
    }

    func rewindForward() {
        seekForward(by: 20)
    }

    /// Increase value of FOV
    func increaseFOV() {
        if let leftCamera = cameraNodeLeft.camera,
           leftCamera.fieldOfView < SettingsProperties.FieldOfView.maxThreshold {
            leftCamera.fieldOfView += 5
        }
        if let rightCamera = cameraNodeRight.camera,
           rightCamera.fieldOfView < SettingsProperties.FieldOfView.maxThreshold {
            rightCamera.fieldOfView += 5
        }
    }

    /// Decrease value of FOV
    func decreaseFOV() {
        if let leftCamera = cameraNodeLeft.camera,
           leftCamera.fieldOfView > SettingsProperties.FieldOfView.minThreshold {
            leftCamera.fieldOfView -= 5
        }
        if let rightCamera = cameraNodeRight.camera,
           rightCamera.fieldOfView > SettingsProperties.FieldOfView.minThreshold {
            rightCamera.fieldOfView -= 5
        }
    }

    /// Get all gestures from settings
    func getGestures() -> Set<PlayerGesture> {
        var gestures: Set<PlayerGesture> = []
        let actionSettings = settingsProvider.actionSettings
        // key -> .play - action
        // value -> .singleTwoFingersTap - gesture
        for (_, value) in actionSettings where value != .none {
            gestures.insert(value)
        }
        return gestures
    }

    func configureActions() {
        // In order to prevent retain cycle, consider to use closures instead of functions' names
        allAvailableActions[.closeVC] = closeVideo
        allAvailableActions[.play] = playPause
        allAvailableActions[.resetScenePosition] = initScenePosition
        allAvailableActions[.increaseFOV] = increaseFOV
        allAvailableActions[.decreaseFOV] = decreaseFOV
        allAvailableActions[.rewindBackward] = rewindBackward
        allAvailableActions[.rewindForward] = rewindForward
    }

    func closeVideo() {
        // In order to prevent retain cycle, reset the dict
        allAvailableActions = [:]
        delegate?.videoDidClose()
    }

    func handleGesture(_ gesture: PlayerGesture) {
        let actionSettings = settingsProvider.actionSettings
        if let action = actionSettings.first(where: { (_: PlayerAction, value: PlayerGesture) in
            value == gesture
        })?.key {
            allAvailableActions[action]?()
        }
    }

}
