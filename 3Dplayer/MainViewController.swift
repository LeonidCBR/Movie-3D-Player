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

class MainViewController: UIViewController {

    // TODO: - Add arrays
    // like sceneViews = [SCNView(), SCNView()]

    // Views
    let sceneViewLeft = SCNView()
    let sceneViewRight = SCNView()

    // Cameras
    let cameraNodeLeft = SCNNode()
    let cameraNodeRight = SCNNode()

    let motionManager = CMMotionManager()

    let videoPlayer = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        createScene()
    }

    private func createScene() {
        createStackView()

        /** Configure cameras */
        configureCamera(cameraNodeLeft)
        // turn to the left by 90 degrees
//        cameraNodeLeft.eulerAngles.y += .pi/2

        configureCamera(cameraNodeRight)
        // turn to the right by 90 degrees
//        cameraNodeRight.eulerAngles.y -= .pi/2

        /** Create scenes */
        let sceneLeft = SCNScene()
        sceneViewLeft.scene = sceneLeft
        sceneLeft.rootNode.addChildNode(cameraNodeLeft)
        sceneViewLeft.pointOfView = cameraNodeLeft
        // Create sprite kit scene for video playing
        let width = 4096 // 3840
        let height = 2048 // 1920
        let videoSKSceneLeft = SKScene(size: CGSize(width: width, height: height))
        videoSKSceneLeft.scaleMode = .aspectFit
//        let videoSKNodeLeft = SKVideoNode(avPlayer: videoPlayer)
        let videoSKNodeLeft = SKSpriteNode(imageNamed: "picture.jpg")
        videoSKNodeLeft.position = CGPoint(x: width / 2, y: height / 2)
        videoSKNodeLeft.size = videoSKSceneLeft.size
        videoSKSceneLeft.addChild(videoSKNodeLeft)
        let videoNodeLeft = makeSphereNode(scene: videoSKSceneLeft)
//        let videoNodeLeft = makeSphereNode(scene: videoSKSceneLeft)
        sceneLeft.rootNode.addChildNode(videoNodeLeft)



        let sceneRight = SCNScene()
        sceneViewRight.scene = sceneRight
        sceneRight.rootNode.addChildNode(cameraNodeRight)
        sceneViewRight.pointOfView = cameraNodeRight
        let videoSKSceneRight = SKScene(size: CGSize(width: width, height: height))
        videoSKSceneRight.scaleMode = .aspectFit
//        let videoSKNodeRight = SKVideoNode(avPlayer: videoPlayer)
        let videoSKNodeRight = SKSpriteNode(imageNamed: "picture.jpg")
        videoSKNodeRight.position = CGPoint(x: width / 2, y: height / 2)
        videoSKNodeRight.size = videoSKSceneRight.size
        videoSKSceneRight.addChild(videoSKNodeRight)
        let videoNodeRight = makeSphereNode(scene: videoSKSceneRight)
//        let videoNodeLeft = makeSphereNode(scene: videoSKSceneLeft)
        sceneRight.rootNode.addChildNode(videoNodeRight)




        sceneViewLeft.isPlaying = true
        sceneViewRight.isPlaying = true


        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { deviceMotion, error in
            guard let currentAttitude = deviceMotion?.attitude else { return }
            // look up at 90 degrees
            let roll = Float(.pi * 0.5 + currentAttitude.roll)
            let yaw = Float(currentAttitude.yaw)
            let yawRight = yaw + .pi
            let pitch = Float(currentAttitude.pitch)
            self.cameraNodeLeft.eulerAngles = SCNVector3(x: roll, y: -yaw, z: pitch)
            self.cameraNodeRight.eulerAngles = SCNVector3(x: roll, y: -yawRight, z: -pitch)
        }

    }

    private func createStackView() {
        // Create stack view for scenes' views
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

    private func configureCamera(_ cameraNode: SCNNode) {
        let camera = SCNCamera()
        camera.zFar = 100.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
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

