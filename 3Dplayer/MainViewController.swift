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
        // turn to the left by 90 degrees
        cameraNodeLeft.eulerAngles.y += .pi/2
//        cameraNode.eulerAngles = SCNVector3(x: .pi/20, y: -.pi/4, z: 0)
        sceneLeft.rootNode.addChildNode(cameraNodeLeft)
        sceneViewLeft.pointOfView = cameraNodeLeft

        let cameraRight = SCNCamera()
        cameraNodeRight.camera = cameraRight
        cameraNodeRight.position = SCNVector3(x: 0.5, y: 0.0, z: 0.0)
        // turn to the right by 90 degrees
        cameraNodeRight.eulerAngles.y -= .pi/2
        sceneRight.rootNode.addChildNode(cameraNodeRight)
        sceneViewRight.pointOfView = cameraNodeRight

//        let width = 4096 // 3840
//        let height = 2048 // 1920
//
//        let skScene = SKScene(size: CGSize(width: width, height: height))

        let geometryLeft = SCNSphere(radius: 30.0)
//        let contentLeft = UIColor.blue
        let contentLeft = UIImage(named: "picture.jpg")
        geometryLeft.firstMaterial?.diffuse.contents = contentLeft

        // Flip upside down
        let matrix = SCNMatrix4MakeRotation(.pi, 1.0, 0.0, 0.0)
        let transform = SCNMatrix4Translate(matrix, 0.0, 1.0, 1.0)
        geometryLeft.firstMaterial?.diffuse.contentsTransform = transform
        geometryLeft.firstMaterial?.isDoubleSided = true
        let simpleNodeLeft = SCNNode(geometry: geometryLeft)
        simpleNodeLeft.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
//        let rotation = SCNMatrix4MakeRotation(.pi, 1.0, 0.0, 0.0)
//        simpleNodeLeft.pivot = rotation
        sceneLeft.rootNode.addChildNode(simpleNodeLeft)

        let geometryRight = SCNSphere(radius: 30.0)
//        let contentRight = UIColor.red
        let contentRight = contentLeft
        geometryRight.firstMaterial?.diffuse.contents = contentRight
        geometryRight.firstMaterial?.diffuse.contentsTransform = transform
        geometryRight.firstMaterial?.isDoubleSided = true
        let simpleNodeRight = SCNNode(geometry: geometryRight)
        simpleNodeRight.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
//        simpleNodeRight.pivot = rotation
        sceneRight.rootNode.addChildNode(simpleNodeRight)

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
}

