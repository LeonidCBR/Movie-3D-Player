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
//import AVFoundation

class MainViewController: UIViewController {

    // Views
    let sceneViewLeft = SCNView()
    let sceneViewRight = SCNView()

    // Cameras
    let cameraNodeLeft = SCNNode()
    let cameraNodeRight = SCNNode()

    let motionManager = CMMotionManager()

//    let player = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        createScene()
    }

    private func createScene() {
        createStackView()

        // Create scenes
        let sceneLeft = SCNScene()
        sceneViewLeft.scene = sceneLeft
        let sceneRight = SCNScene()
        sceneViewRight.scene = sceneRight



        // set up camera
        let cameraLeft = SCNCamera()
//        camera.zFar = 100.0
        cameraNodeLeft.camera = cameraLeft
        cameraNodeLeft.position = SCNVector3(x: -0.5, y: 0.0, z: 0.0)
//        cameraNode.eulerAngles.y += .pi/4
//        cameraNode.eulerAngles = SCNVector3(x: .pi/20, y: -.pi/4, z: 0)
        sceneLeft.rootNode.addChildNode(cameraNodeLeft)
        sceneViewLeft.pointOfView = cameraNodeLeft

        let cameraRight = SCNCamera()
        cameraNodeRight.camera = cameraRight
        cameraNodeRight.position = SCNVector3(x: 0.5, y: 0.0, z: 0.0)
        sceneRight.rootNode.addChildNode(cameraNodeRight)
        sceneViewRight.pointOfView = cameraNodeRight

//        let width = 4096 // 3840
//        let height = 2048 // 1920
//
//        let skScene = SKScene(size: CGSize(width: width, height: height))

        let geometryLeft = SCNSphere(radius: 30.0)
        let contentLeft = UIColor.blue //UIImage(named: "picture.jpg")
        geometryLeft.firstMaterial?.diffuse.contents = contentLeft
        geometryLeft.firstMaterial?.isDoubleSided = true
        let simpleNodeLeft = SCNNode(geometry: geometryLeft)
        simpleNodeLeft.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        simpleNodeLeft.pivot = SCNMatrix4MakeRotation(.pi, 1.0, 0.0, 0.0)
        sceneLeft.rootNode.addChildNode(simpleNodeLeft)

        let geometryRight = SCNSphere(radius: 30.0)
        let contentRight = UIColor.red
        geometryRight.firstMaterial?.diffuse.contents = contentRight
        geometryRight.firstMaterial?.isDoubleSided = true
        let simpleNodeRight = SCNNode(geometry: geometryRight)
        simpleNodeRight.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        simpleNodeRight.pivot = SCNMatrix4MakeRotation(.pi, 1.0, 0.0, 0.0)
        sceneRight.rootNode.addChildNode(simpleNodeRight)

        sceneViewLeft.isPlaying = true
        sceneViewRight.isPlaying = true


        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { deviceMotion, error in
            guard let currentAttitude = deviceMotion?.attitude else { return }
            let roll = Float(.pi * 0.5 + currentAttitude.roll)
            let yaw = Float(currentAttitude.yaw)
            let pitch = Float(currentAttitude.pitch)
            self.cameraNodeLeft.eulerAngles = SCNVector3(x: roll, y: -yaw, z: -pitch)
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
}

