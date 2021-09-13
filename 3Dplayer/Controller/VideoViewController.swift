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

class VideoViewController: UIViewController {

    // MARK: - Properties

    let sceneViews = [SCNView(), SCNView()]
    let cameraNodes = [SCNNode(), SCNNode()]
    let motionManager = CMMotionManager()
    let videoPlayer = AVPlayer()
    var document: UIDocument? {
        didSet {
            if let fileUrl = document?.fileURL {
                videoPlayer.replaceCurrentItem(with: AVPlayerItem(url: fileUrl))
            }
        }
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSceneViews()
        print("DEBUG: The scene views has been loded.")
    }


    // MARK: - Methods

    private func configureSceneViews() {
        createStackView()
        configureCameras()

        // turn to the left by 90 degrees
//        cameraNodeLeft.eulerAngles.y += .pi/2

        // turn to the right by 90 degrees
//        cameraNodeRight.eulerAngles.y -= .pi/2

        createScene()
        start()

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { deviceMotion, error in
            guard let currentAttitude = deviceMotion?.attitude else { return }
            // look up at 90 degrees
            let roll = Float(.pi * 0.5 + currentAttitude.roll)
            let yaw = Float(currentAttitude.yaw)
            let yawRight = yaw + .pi
            let pitch = Float(currentAttitude.pitch)
//            self.cameraNodeLeft.eulerAngles = SCNVector3(x: roll, y: -yaw, z: pitch)
//            self.cameraNodeRight.eulerAngles = SCNVector3(x: roll, y: -yawRight, z: -pitch)
            // Left camera
            self.cameraNodes[0].eulerAngles = SCNVector3(x: roll, y: -yaw, z: pitch)
            // Right camera
            self.cameraNodes[1].eulerAngles = SCNVector3(x: roll, y: -yawRight, z: -pitch)
        }

    }

    private func createStackView() {
        // Create stack view for scenes' views
//        let stackView = UIStackView(arrangedSubviews: [sceneViewLeft, sceneViewRight])
        let stackView = UIStackView(arrangedSubviews: sceneViews)
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

    private func configureCameras() {
        for cameraNode in cameraNodes {
            let camera = SCNCamera()
            camera.zFar = 100.0
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        }
    }

    /** Create single scene with two cameras */
    private func createScene() {

        let scene = SCNScene()

        for i in 0...1 {
            scene.rootNode.addChildNode(cameraNodes[i])
            sceneViews[i].scene = scene
            sceneViews[i].pointOfView = cameraNodes[i]
        }

        // Create sprite kit scene for video playing
        let width = 3840 // for pic 4096
        let height = 1920 // for pic 2048
        let videoSKScene = SKScene(size: CGSize(width: width, height: height))
        videoSKScene.scaleMode = .aspectFit
        let videoSKNode = SKVideoNode(avPlayer: videoPlayer)
//        let videoSKNode = SKSpriteNode(imageNamed: "picture.jpg")
        videoSKNode.position = CGPoint(x: width / 2, y: height / 2)
        videoSKNode.size = videoSKScene.size
        videoSKScene.addChild(videoSKNode)

        let videoNode = makeSphereNode(scene: videoSKScene)
        scene.rootNode.addChildNode(videoNode)
    }

    private func start() {
        for sceneView in sceneViews {
            sceneView.isPlaying = true
        }

        videoPlayer.play()
    }

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

}

