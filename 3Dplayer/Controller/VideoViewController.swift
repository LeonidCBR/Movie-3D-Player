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


// TODO: Implement a single view


class VideoViewController: UIViewController {

    // MARK: - Properties

    let sceneNameLeft = "SceneKit Asset Catalog.scnassets/DomeZL.dae"
    let sceneNameRight = "SceneKit Asset Catalog.scnassets/DomeZR.dae"
    var sceneViewLeft: SCNView!
    var sceneViewRight: SCNView!

    weak var cameraNodeLeft: SCNNode!
    weak var cameraNodeRight: SCNNode!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        sceneViewLeft = createScene(named: sceneNameLeft)
        sceneViewRight = createScene(named: sceneNameRight)
        configureNodes()
        configureSceneViews()
        createVideoScene()
        configureVideoNode(at: sceneViewLeft)
        configureVideoNode(at: sceneViewRight)
        configureMotionManager()
        configureGestures()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPlaying = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isPlaying = false
    }

    deinit {
        print("DEBUG: deinit video view controller.")
    }


    // MARK: - Methods

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
        cameraNodeLeft = sceneViewLeft.scene!.rootNode.childNode(withName: "Camera", recursively: false)!
        cameraNodeRight = sceneViewRight.scene!.rootNode.childNode(withName: "Camera", recursively: false)!
        domeNodeLeft = sceneViewLeft.scene!.rootNode.childNode(withName: "Sphere", recursively: false)!
        domeNodeRight = sceneViewRight.scene!.rootNode.childNode(withName: "Sphere", recursively: false)!
    }

    private func configureSceneViews() {
        let stackView = UIStackView(arrangedSubviews: [sceneViewLeft, sceneViewRight])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func createVideoScene() {
        // Create sprite kit scene for video playing
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
        sceneViewLeft.isPlaying = true
        sceneViewRight.isPlaying = true
        videoPlayer.play()
    }

    private func pause() {
        sceneViewLeft.isPlaying = false
        sceneViewRight.isPlaying = false
        videoPlayer.pause()
    }

    private func configureGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTap)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDown.direction = .down
        swipeDown.numberOfTouchesRequired = 2
        view.addGestureRecognizer(swipeDown)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp(_:)))
        swipeUp.direction = .up
        swipeUp.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeUp)
    }


    // MARK: - Selectors

    /** Play/pause */
    @objc func handleSingleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            isPlaying.toggle()
        }
    }

    /** Dismiss controller */
    @objc func handleSwipeDown(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            dismiss(animated: true)
        }
    }

    /** Rotate the sphere according the camera's view */
    @objc func handleSwipeUp(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }

        if gestureRecognizer.state == .ended {
            domeNodeLeft.eulerAngles.y = cameraNodeLeft.eulerAngles.y
            domeNodeRight.eulerAngles.y = cameraNodeRight.eulerAngles.y + .pi
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

