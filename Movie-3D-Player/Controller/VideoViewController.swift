//
//  ViewController.swift
//  3Dplayer
//
//  Created by Яна Латышева on 10.09.2021.
//

import UIKit
import SceneKit
import SpriteKit
import CoreMotion
import AVFoundation
import MediaPlayer


// TODO: Implement a single view


class VideoViewController: UIViewController {

    // MARK: - Properties

    let sceneNameLeft = "SceneKit Asset Catalog.scnassets/DomeZL.dae"
    let sceneNameRight = "SceneKit Asset Catalog.scnassets/DomeZR.dae"
    var sceneViewLeft: SCNView!
    var sceneViewRight: SCNView!

    weak var cameraNodeLeft: SCNNode!
    weak var cameraNodeRight: SCNNode!

    // TODO: - Move to settings
    let fieldOfView = 85.0
    // The space between left and right views
    let space: CGFloat = 20.0

    weak var domeNodeLeft: SCNNode!
    weak var domeNodeRight: SCNNode!

    var videoSKScene: SKScene!
    let videoPlayer = AVPlayer()
    let motionManager = CMMotionManager()

    var document: UIDocument? {
        didSet {
            if let fileUrl = document?.fileURL {
                videoPlayer.replaceCurrentItem(with: AVPlayerItem(url: fileUrl))
            }
        }
    }

    var isPlaying = false {
        didSet {
            if isPlaying {
                play()
            } else {
                pause()
            }
        }
    }


    // MARK: - Lifecycle

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft

        // TODO: - Fix a bug!
        // There is a bug with configuration of views!
        // The view becomes upside down
//        return .landscape
    }

    // For what???
//    override var shouldAutorotate: Bool {
//        return false
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        UIApplication.shared.isIdleTimerDisabled = true
        videoPlayer.preventsDisplaySleepDuringVideoPlayback = true

        sceneViewLeft = createScene(named: sceneNameLeft)
        sceneViewRight = createScene(named: sceneNameRight)
        configureNodes()
        configureCameras()
        configureSceneViews()
        createVideoScene()
        configureVideoNode(at: sceneViewLeft)
        configureVideoNode(at: sceneViewRight)
        configureMotionManager()
        configureGestures()

        setupRemoteTransportControls()
        setupNowPlaying()
        isPlaying = true
    }

    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // consider to move configurations of views here
        // but remember this method gets triggered every appear
    }
    */

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Configure frames...")
        print("safeAreaLayoutGuide frame: \(view.safeAreaLayoutGuide.layoutFrame)")
        print("view's frame: \(view.frame)")

        let height = view.frame.height
        print("height = \(height)")

        let halfWidth = view.frame.width / 2
//        let halfWidth = view.safeAreaLayoutGuide.layoutFrame.width / 2 // - space / 2

        print("half of width = \(halfWidth)")
        print("mix X = \(view.safeAreaLayoutGuide.layoutFrame.minX)")
        let widthOfBox = halfWidth - space / 2 - view.safeAreaLayoutGuide.layoutFrame.minX
        print("width of box = \(widthOfBox)")
        let length = height < widthOfBox ? height : widthOfBox
        print("length of box = \(length)")

        let xPosLeftEye = halfWidth - length - (space/2) // + safe delta (50.0)
        let yPosLeftEye = (height - length) / 2
        sceneViewLeft.frame = CGRect(x: xPosLeftEye, y: yPosLeftEye, width: length, height: length)

        let xPosRightEye = halfWidth + (space/2)
        let yPosRigthEye = (height - length) / 2
        sceneViewRight.frame = CGRect(x: xPosRightEye, y: yPosRigthEye, width: length, height: length)

        print("Left view's frame: \(sceneViewLeft.frame)")
        print("Rigth view's frame: \(sceneViewRight.frame)")
    }

    deinit {
        print("DEBUG: deinit video view controller.")
        UIApplication.shared.isIdleTimerDisabled = false
    }


    // MARK: - Methods

    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [weak self] event in

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
        commandCenter.pauseCommand.addTarget { [weak self] event in

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
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = document?.localizedName

//        if let image = UIImage(named: "picture.jpg") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] =
//            MPMediaItemArtwork(boundsSize: image.size) { size in
//                return image
//            }
//        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = videoPlayer.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = videoPlayer.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = videoPlayer.rate

        // Set the metadata
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

    private func createScene(named sceneName: String) -> SCNView {
        let scene = SCNScene(named: sceneName)!
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        sceneView.isPlaying = true
        return sceneView
    }

    private func configureNodes() {
        domeNodeLeft = sceneViewLeft.scene!.rootNode.childNode(withName: "Sphere", recursively: false)!
        domeNodeRight = sceneViewRight.scene!.rootNode.childNode(withName: "Sphere", recursively: false)!
    }

    private func configureCameras() {
        cameraNodeLeft = sceneViewLeft.scene!.rootNode.childNode(withName: "Camera", recursively: false)!
        cameraNodeRight = sceneViewRight.scene!.rootNode.childNode(withName: "Camera", recursively: false)!

        cameraNodeLeft.camera!.fieldOfView = fieldOfView
        cameraNodeRight.camera!.fieldOfView = fieldOfView
    }

    private func configureSceneViews() {
        sceneViewLeft.translatesAutoresizingMaskIntoConstraints = false
        sceneViewRight.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneViewLeft)
        view.addSubview(sceneViewRight)
    }

    private func createVideoScene() {
        // Create sprite kit scene for video playing
        // TODO: Should we get these parameters from the video
        let width = 3840
        let height = 1920
        videoSKScene = SKScene(size: CGSize(width: width, height: height))
        videoSKScene.scaleMode = .aspectFit
        let videoSKNode = SKVideoNode(avPlayer: videoPlayer)
        videoSKNode.position = CGPoint(x: width / 2, y: height / 2)
        videoSKNode.size = videoSKScene.size
        videoSKScene.addChild(videoSKNode)
    }
/*
    private func createPictureScene() {
        // Create sprite kit scene for picture
        let width = 4096
        let height = 2048
        videoSKScene = SKScene(size: CGSize(width: width, height: height))
        videoSKScene.scaleMode = .aspectFit
        let pictureSKNode = SKSpriteNode(imageNamed: "picture.jpg")
        pictureSKNode.position = CGPoint(x: width / 2, y: height / 2)
        pictureSKNode.size = videoSKScene.size
        videoSKScene.addChild(pictureSKNode)
    }
*/
    private func configureVideoNode(at sceneView: SCNView) {
        let sphereNode = sceneView.scene!.rootNode.childNode(withName: "Sphere", recursively: false)!
        sphereNode.geometry!.firstMaterial!.diffuse.contents = videoSKScene
    }

    private func configureMotionManager() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] deviceMotion, error in
            guard let currentAttitude = deviceMotion?.attitude else { return }


            // TODO: Fix head's rotation!

            /*
            Pitch (the x component) is the rotation about the node’s x-axis.
            Yaw (the y component) is the rotation about the node’s y-axis.
            Roll (the z component) is the rotation about the node’s z-axis.
            */


            // look up at 90 degrees
            let roll = Float(.pi * 0.5 + currentAttitude.roll)
            let yaw = Float(currentAttitude.yaw)
            let yawRight = yaw + .pi
            let pitch = Float(currentAttitude.pitch)
            self?.cameraNodeLeft.eulerAngles = SCNVector3(x: roll, y: -yaw, z: pitch)
            self?.cameraNodeRight.eulerAngles = SCNVector3(x: roll, y: -yawRight, z: -pitch)
        }

    }

    private func play() {
        videoPlayer.play()
    }

    private func pause() {
        videoPlayer.pause()
    }

    private func seekBackward(by seconds: CMTimeValue) {
        // seek backward by 20 seconds
        let delta = CMTime(value: 20, timescale: 1)
        let newTime = videoPlayer.currentTime() - delta
        videoPlayer.seek(to: newTime)
    }

    private func seekForward(by seconds: CMTimeValue) {
        // seek forward by 20 seconds
        let delta = CMTime(value: 20, timescale: 1)
        let newTime = videoPlayer.currentTime() + delta
        videoPlayer.seek(to: newTime)
    }

    private func configureGestures() {

        /*
         Play/pause                 - single tap
         Init position of the scene - single tap by two fingers
         Increase value of FOV      - swipe up
         Decrease value of FOV      - swipe down
         Rewind backward            - swipe left
         Rewind forward             - swipe right
         Dismiss video controller   - swipe down by two fingers
         */

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
    @objc private func handlePlay(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            isPlaying.toggle()
        }
    }

    /** Init view of the scene by rotating the sphere according the camera's view */
    @objc private func handleInitScenePosition(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            domeNodeLeft.eulerAngles.y = cameraNodeLeft.eulerAngles.y
            domeNodeRight.eulerAngles.y = cameraNodeRight.eulerAngles.y + .pi
        }
    }

    /** Increase value of FOV */
    @objc private func handleIncreaseFOV(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            if cameraNodeLeft.camera!.fieldOfView < 115 {
            cameraNodeLeft.camera!.fieldOfView += 5
            cameraNodeRight.camera!.fieldOfView += 5
            }
        }
    }

    /** Decrease value of FOV */
    @objc private func handleDecreaseFOV(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            if cameraNodeLeft.camera!.fieldOfView > 40 {
                cameraNodeLeft.camera!.fieldOfView -= 5
                cameraNodeRight.camera!.fieldOfView -= 5
            }
        }
    }

    /** Rewind backward */
    @objc private func handleRewindBackward(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            seekBackward(by: 20)
        }
    }

    /** Rewind forward */
    @objc private func handleRewindForward(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            seekForward(by: 20)
        }
    }

    /** Dismiss controller */
    @objc private func handleDismiss(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            dismiss(animated: true)
        }
    }

/*
    private func makePlaneNode(scene: SKScene) -> SCNNode {
        print("DEBUG: \(#function)")
        let planeNode = SCNNode()
        let plane = SCNPlane(width: 400, height: 200)
        plane.firstMaterial?.diffuse.contents = scene
        plane.firstMaterial?.isDoubleSided = true
        planeNode.pivot = SCNMatrix4MakeRotation(.pi/2, 0.0, 1.0, 0.0)
        planeNode.geometry = plane
        planeNode.position = SCNVector3(x: -50.0, y: 0.0, z: 0.0)
        return planeNode
    }
*/
/*
    private func makeSphereNode(scene: SKScene) -> SCNNode {
        print("DEBUG: \(#function)")

        // Create geometry
        let sphere = SCNSphere(radius: 30)
        sphere.firstMaterial?.diffuse.contents = scene
        sphere.firstMaterial?.isDoubleSided = true

        // Flip upside down
//        let matrix = SCNMatrix4MakeRotation(.pi, 1.0, 0.0, 0.0)
//        let transform = SCNMatrix4Translate(matrix, 0.0, 1.0, 1.0)

//        let matrix = SCNMatrix4MakeRotation(.pi, 0.0, 0.0, 1.0)
//        let transform = SCNMatrix4Translate(matrix, 1.0, 1.0, 0.0)
//        sphere.firstMaterial?.diffuse.contentsTransform = transform
//        sphereNode.pivot = SCNMatrix4MakeRotation(.pi, 1.0, 0.0, 0.0)

        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.position = SCNVector3(0, 0, 0)
        return sphereNode
    }
*/
}

