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

class MainViewController: UIViewController {

    let sceneView = SCNView()
    let cameraNode = SCNNode()
    let motionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        createScene()
    }

    private func createScene() {
        sceneView.frame = view.frame
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sceneView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        sceneView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        let scene = SCNScene()
        sceneView.scene = scene

        // set up camera
        let camera = SCNCamera()
//        camera.zFar = 100.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 0)
//        cameraNode.eulerAngles.y += .pi/4
//        cameraNode.eulerAngles = SCNVector3(x: .pi/20, y: -.pi/4, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode

//        let width = 4096 // 3840
//        let height = 2048 // 1920
//
//        let skScene = SKScene(size: CGSize(width: width, height: height))

        let geometry = SCNSphere(radius: 30.0)
        let image = UIImage(named: "picture.jpg")
        geometry.firstMaterial?.diffuse.contents = image
        geometry.firstMaterial?.isDoubleSided = true
        let simpleNode = SCNNode(geometry: geometry)
        simpleNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        simpleNode.pivot = SCNMatrix4MakeRotation(.pi, 1.0, 0.0, 0.0)
        scene.rootNode.addChildNode(simpleNode)

        sceneView.isPlaying = true


        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { deviceMotion, error in
            guard let currentAttitude = deviceMotion?.attitude else { return }
            let roll = Float(.pi * 0.5 + currentAttitude.roll)
            let yaw = Float(currentAttitude.yaw)
            let pitch = Float(currentAttitude.pitch)
            self.cameraNode.eulerAngles = SCNVector3(x: roll, y: -yaw, z: -pitch)
        }

    }


}

