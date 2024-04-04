//
//  RendererDelegate.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 06.03.2024.
//

import Foundation
import SceneKit
import CoreMotion

/**
 Renderer delegate set a rotation of the cameras accordingly motions of the device
 */
protocol RendererDelegate: AnyObject, SCNSceneRendererDelegate {
    var motionManager: CMMotionManager { get }
    init(motionManager: CMMotionManager)
}

class RendererWithLeftOrientation: NSObject, RendererDelegate {
    let motionManager: CMMotionManager

    required init(motionManager: CMMotionManager) {
        self.motionManager = motionManager
    }

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

class RendererWithRightOrientation: NSObject, RendererDelegate {
    let motionManager: CMMotionManager

    required init(motionManager: CMMotionManager) {
        self.motionManager = motionManager
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let deviceMotion = motionManager.deviceMotion,
              let cameraNode = renderer.scene?.rootNode.childNode(withName: "Camera", recursively: false)
        else {
            return
        }
        let cmQuaternion = deviceMotion.attitude.quaternion
        let scnQuaternion = SCNQuaternion(x: Float(cmQuaternion.y),
                                          y: Float(-cmQuaternion.x),
                                          z: Float(cmQuaternion.z),
                                          w: Float(cmQuaternion.w))
        cameraNode.orientation = scnQuaternion
    }
}
