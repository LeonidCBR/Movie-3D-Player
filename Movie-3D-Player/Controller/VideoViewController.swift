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

class VideoViewController: UIViewController {

    // MARK: - Properties
    // TODO: - Consider to use ViewModel

//    let fieldOfView = SettingsProperties.FieldOfView.defaultValue

    /// The space between left and right views
    let space: CGFloat = {
        if let spaceObject = UserDefaults.standard.object(forKey: SettingsProperties.Space.id),
           let spaceValue = (spaceObject as? CGFloat) {
            return spaceValue
        } else {
            return SettingsProperties.Space.defaultValue
        }
    }()

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
        let scene = SKScene(size: CGSize(width: SceneProperties.width, height: SceneProperties.height))
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

    init(with video: Document) {
        self.videoFile = video
        let videoItem = AVPlayerItem(url: video.fileURL)
        self.videoPlayer = AVPlayer(playerItem: videoItem)
        self.motionManager = CMMotionManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
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
        videoSKNode.position = CGPoint(x: SceneProperties.width / 2,
                                       y: SceneProperties.height / 2)
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
        sceneViewLeft.delegate = self
        sceneViewRight.delegate = self
    }

    func configureCameras() {
        // Set values from DB if it exists
        if let fieldOfView = UserDefaults.standard.object(forKey: SettingsProperties.FieldOfView.id),
           let value = (fieldOfView as? CGFloat) {
            cameraNodeLeft.camera?.fieldOfView = value
            cameraNodeRight.camera?.fieldOfView = value
        } else {
            // Setup default values
            cameraNodeLeft.camera?.fieldOfView = SettingsProperties.FieldOfView.defaultValue
            cameraNodeRight.camera?.fieldOfView = SettingsProperties.FieldOfView.defaultValue
        }
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

    /**
     Play/pause                 - single tap
     Init position of the scene - single tap by two fingers
     Increase value of FOV      - swipe up
     Decrease value of FOV      - swipe down
     Rewind backward            - swipe left
     Rewind forward             - swipe right
     Dismiss video controller   - swipe down by two fingers
     */
    func configureGestures() {
        let singleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(handlePlay(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTap)

        let singleTapTwoFingers = UITapGestureRecognizer(target: self,
                                                         action: #selector(handleInitScenePosition(_:)))
        singleTapTwoFingers.numberOfTapsRequired = 1
        singleTapTwoFingers.numberOfTouchesRequired = 2
        view.addGestureRecognizer(singleTapTwoFingers)

        let swipeUp = UISwipeGestureRecognizer(target: self,
                                               action: #selector(handleIncreaseFOV(_:)))
        swipeUp.direction = .up
        swipeUp.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(handleDecreaseFOV(_:)))
        swipeDown.direction = .down
        swipeDown.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeDown)

        let swipeLeft = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(handleRewindBackward(_:)))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(handleRewindForward(_:)))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeRight)

        let swipeDownTwoFingers = UISwipeGestureRecognizer(target: self,
                                                           action: #selector(handleDismiss(_:)))
        swipeDownTwoFingers.direction = .down
        swipeDownTwoFingers.numberOfTouchesRequired = 2
        view.addGestureRecognizer(swipeDownTwoFingers)
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

// MARK: - SCNSceneRendererDelegate

extension VideoViewController: SCNSceneRendererDelegate {

    // Capture quaternion via motion manager 60 times per second
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let deviceMotion = motionManager.deviceMotion,
              let cameraNode = renderer.scene?.rootNode.childNode(withName: "Camera", recursively: false)
        else {
            return
        }
        let cmQuaternion = deviceMotion.attitude.quaternion
        let scnQuaternion = SCNQuaternion(x: Float(-cmQuaternion.y),
                                          y: Float(cmQuaternion.x),
                                          z: Float(cmQuaternion.z),
                                          w: Float(cmQuaternion.w))
        cameraNode.orientation = scnQuaternion
    }

}
