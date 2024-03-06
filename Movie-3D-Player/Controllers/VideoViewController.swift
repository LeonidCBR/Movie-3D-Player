//
//  ViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 10.09.2021.
//

import UIKit
import SceneKit
import SpriteKit
import CoreMotion
import AVFoundation
import MediaPlayer

// swiftlint:disable type_body_length
class VideoViewController: UIViewController {

    // MARK: - Properties
    let rendererDelegate: RendererDelegate
    let settingsProvider: SettingsProvider
    let videoPlayer: AVPlayer
    let motionManager: CMMotionManager
    let videoFile: Document

    let sceneViewLeft: SCNView = {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene(named: SceneProperties.left)
        return sceneView
    }()

    let sceneViewRight: SCNView = {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene(named: SceneProperties.right)
        return sceneView
    }()

    lazy var cameraNodeLeft: SCNNode = {
        guard let cameraNode = sceneViewLeft.scene?.rootNode.childNode(withName: SceneProperties.camera,
                                                                       recursively: false) else {
            return SCNNode()
        }
        return cameraNode
    }()

    lazy var cameraNodeRight: SCNNode = {
        guard let cameraNode = sceneViewRight.scene?.rootNode.childNode(withName: SceneProperties.camera,
                                                                        recursively: false) else {
            return SCNNode()
        }
        return cameraNode
    }()

    lazy var domeNodeLeft: SCNNode = {
        guard let domeNode = sceneViewLeft.scene?.rootNode.childNode(withName: SceneProperties.sphere,
                                                                     recursively: false) else {
            return SCNNode()
        }
        domeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
        return domeNode
    }()

    lazy var domeNodeRight: SCNNode = {
        guard let domeNode = sceneViewRight.scene?.rootNode.childNode(withName: SceneProperties.sphere,
                                                                      recursively: false) else {
            return SCNNode()
        }
        domeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, .pi)
        return domeNode
    }()

    let videoSKScene: SKScene = {
        let scene = SKScene(size: CGSize(width: SceneProperties.defaultWidth,
                                         height: SceneProperties.defaultHeight))
        scene.scaleMode = .aspectFit
        return scene
    }()

    var isPlaying = false {
        didSet {
            if isPlaying {
                videoPlayer.play()
            } else {
                videoPlayer.pause()
            }
        }
    }

    // MARK: - Lifecycle

    init(with video: Document,
         settingsProvider: SettingsProvider,
         motionManager: CMMotionManager,
         rendererDelegate: RendererDelegate) {
        self.videoFile = video
        let videoItem = AVPlayerItem(url: video.fileURL)
        self.videoPlayer = AVPlayer(playerItem: videoItem)
        self.settingsProvider = settingsProvider
        self.motionManager = motionManager
        self.rendererDelegate = rendererDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch settingsProvider.orientation {
        case .leftSideDown:
            return .landscapeRight
        case .rightSideDown:
            return .landscapeLeft
        }
    }

//    override var shouldAutorotate: Bool {
//        return false
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        UIApplication.shared.isIdleTimerDisabled = true
        videoPlayer.preventsDisplaySleepDuringVideoPlayback = true
        initScene()
        configureGestures()
        setupRemoteTransportControls()
        setupNowPlaying()
        isPlaying = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneViewLeft.isPlaying = true
        sceneViewRight.isPlaying = true
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
        sceneViewLeft.isPlaying = false
        sceneViewRight.isPlaying = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // calculate with of the scene's views
        let height = view.frame.height
        let halfWidth = view.frame.width / 2
        let space = settingsProvider.space
        let widthOfSceneView = halfWidth - space / 2 - view.safeAreaLayoutGuide.layoutFrame.minX
        let length = height < widthOfSceneView ? height : widthOfSceneView
        // calculate position of the left scene's view
        let xPosLeftEye = halfWidth - length - (space/2) // + safe delta (50.0)
        let yPosLeftEye = (height - length) / 2
        sceneViewLeft.frame = CGRect(x: xPosLeftEye, y: yPosLeftEye, width: length, height: length)
        // calculate position of the right scene's view
        let xPosRightEye = halfWidth + (space/2)
        let yPosRigthEye = (height - length) / 2
        sceneViewRight.frame = CGRect(x: xPosRightEye, y: yPosRigthEye, width: length, height: length)
    }

    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: - Methods

    func initScene() {
        let videoSKNode = SKVideoNode(avPlayer: videoPlayer)
        videoSKNode.position = CGPoint(x: SceneProperties.defaultWidth / 2,
                                       y: SceneProperties.defaultHeight / 2)
        videoSKNode.size = videoSKScene.size
        videoSKScene.addChild(videoSKNode)
        domeNodeLeft.geometry?.firstMaterial?.diffuse.contents = videoSKScene
        domeNodeRight.geometry?.firstMaterial?.diffuse.contents = videoSKScene
        initScenePosition()
        configureSceneViews()
        configureCameras()
    }

    func initScenePosition() {
        domeNodeLeft.eulerAngles.z = cameraNodeLeft.eulerAngles.z
        domeNodeRight.eulerAngles.z = cameraNodeRight.eulerAngles.z + .pi
    }

    func configureSceneViews() {
        sceneViewLeft.translatesAutoresizingMaskIntoConstraints = false
        sceneViewRight.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneViewLeft)
        view.addSubview(sceneViewRight)
        sceneViewLeft.delegate = rendererDelegate
        sceneViewRight.delegate = rendererDelegate
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

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        switch key.keyCode {
        case .keyboardLeftArrow:
            seekBackward(by: 20)
        case .keyboardRightArrow:
            seekForward(by: 20)
        default:
            super.pressesEnded(presses, with: event)
        }
    }

    func seekBackward(by seconds: CMTimeValue) {
        let delta = CMTime(value: seconds, timescale: 1)
        let newTime = videoPlayer.currentTime() - delta
        videoPlayer.seek(to: newTime)
    }

    func seekForward(by seconds: CMTimeValue) {
        let delta = CMTime(value: seconds, timescale: 1)
        let newTime = videoPlayer.currentTime() + delta
        videoPlayer.seek(to: newTime)
    }

    func configureGestures() {
        // TODO: Consider to refactor it
//        let myActions: [PlayerAction: Selector]
//        for action in PlayerAction.allCases {
//            switch action {
//            case .closeVC:
//                myActions[.closeVC] = #selector(handleDismiss(_:))
//            case .play:
//                myActions[.play] = #selector(handlePlay(_:))
//            case .resetScenePosition:
//                myActions[.resetScenePosition] = #selector(handleInitScenePosition(_:))
//            case .increaseFOV:
//                myActions[.increaseFOV] = #selector(handleIncreaseFOV(_:))
//            case .decreaseFOV:
//                myActions[.decreaseFOV] = #selector(handleDecreaseFOV(_:))
//            case .rewindBackward:
//                myActions[.rewindBackward] = #selector(handleRewindBackward(_:))
//            case .rewindForward:
//                myActions[.rewindForward] = #selector(handleRewindForward(_:))
//            }
//        }
        let actions: [PlayerAction: Selector] = [.closeVC: #selector(handleDismiss(_:)),
                                                 .play: #selector(handlePlay(_:)),
                                                 .resetScenePosition: #selector(handleInitScenePosition(_:)),
                                                 .increaseFOV: #selector(handleIncreaseFOV(_:)),
                                                 .decreaseFOV: #selector(handleDecreaseFOV(_:)),
                                                 .rewindBackward: #selector(handleRewindBackward(_:)),
                                                 .rewindForward: #selector(handleRewindForward(_:))]
        let gestures: [PlayerGesture: (Selector) -> UIGestureRecognizer] = [
            .singleTap: getSingleTapGesture,
            .singleTapTwoFingers: getSingleTapTwoFingersGesture,
            .swipeUp: getSwipeUpGesture,
            .swipeDown: getSwipeDownGesture,
            .swipeLeft: getSwipeLeftGesture,
            .swipeRight: getSwipeRightGesture,
            .swipeUpTwoFingers: getSwipeUpTwoFingersGesture,
            .swipeDownTwoFingers: getSwipeDownTwoFingersGesture]
        // Prepare gesture recognizers and register it.
        let actionSettings = settingsProvider.actionSettings
        for (key, value) in actionSettings {
            // key -> .play - action
            // value -> .singleTwoFingersTap - gesture
            if let selector = actions[key],
               let gesture = gestures[value]?(selector) {
                view.addGestureRecognizer(gesture)
            }
        }
    }

    func getSingleTapGesture(_ selector: Selector) -> UIGestureRecognizer {
        let singleTap = UITapGestureRecognizer(target: self, action: selector)
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        return singleTap
    }

    func getSingleTapTwoFingersGesture(_ selector: Selector) -> UIGestureRecognizer {
        let singleTapTwoFingers = UITapGestureRecognizer(target: self, action: selector)
        singleTapTwoFingers.numberOfTapsRequired = 1
        singleTapTwoFingers.numberOfTouchesRequired = 2
        return singleTapTwoFingers
    }

    func getSwipeUpGesture(_ selector: Selector) -> UIGestureRecognizer {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: selector)
        swipeUp.direction = .up
        swipeUp.numberOfTouchesRequired = 1
        return swipeUp
    }

    func getSwipeDownGesture(_ selector: Selector) -> UIGestureRecognizer {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: selector)
        swipeDown.direction = .down
        swipeDown.numberOfTouchesRequired = 1
        return swipeDown
    }

    func getSwipeLeftGesture(_ selector: Selector) -> UIGestureRecognizer {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: selector)
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 1
        return swipeLeft
    }

    func getSwipeRightGesture(_ selector: Selector) -> UIGestureRecognizer {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: selector)
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 1
        return swipeRight
    }

    func getSwipeUpTwoFingersGesture(_ selector: Selector) -> UIGestureRecognizer {
        let swipeUpTwoFingers = UISwipeGestureRecognizer(target: self, action: selector)
        swipeUpTwoFingers.direction = .up
        swipeUpTwoFingers.numberOfTouchesRequired = 2
        return swipeUpTwoFingers
    }

    func getSwipeDownTwoFingersGesture(_ selector: Selector) -> UIGestureRecognizer {
        let swipeDownTwoFingers = UISwipeGestureRecognizer(target: self, action: selector)
        swipeDownTwoFingers.direction = .down
        swipeDownTwoFingers.numberOfTouchesRequired = 2
        return swipeDownTwoFingers
    }

    // MARK: - Selectors

    /** Play/pause */
    @objc func handlePlay(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            isPlaying.toggle()
        }
    }

    /** Init view of the scene by rotating the sphere according the camera's view */
    @objc func handleInitScenePosition(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            initScenePosition()
        }
    }

    /** Increase value of FOV */
    @objc func handleIncreaseFOV(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            if let leftCamera = cameraNodeLeft.camera,
               leftCamera.fieldOfView < SettingsProperties.FieldOfView.maxThreshold {
                leftCamera.fieldOfView += 5
            }
            if let rightCamera = cameraNodeRight.camera,
               rightCamera.fieldOfView < SettingsProperties.FieldOfView.maxThreshold {
                rightCamera.fieldOfView += 5
            }
        }
    }

    /** Decrease value of FOV */
    @objc func handleDecreaseFOV(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            if let leftCamera = cameraNodeLeft.camera,
               leftCamera.fieldOfView > SettingsProperties.FieldOfView.minThreshold {
                leftCamera.fieldOfView -= 5
            }
            if let rightCamera = cameraNodeRight.camera,
               rightCamera.fieldOfView > SettingsProperties.FieldOfView.minThreshold {
                rightCamera.fieldOfView -= 5
            }
        }
    }

    /** Rewind backward */
    @objc func handleRewindBackward(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            seekBackward(by: 20)
        }
    }

    /** Rewind forward */
    @objc func handleRewindForward(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            seekForward(by: 20)
        }
    }

    /** Dismiss controller */
    @objc func handleDismiss(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            dismiss(animated: true)
        }
    }

}
// swiftlint:enable type_body_length
