//
//  ViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 10.09.2021.
//

import UIKit
import SceneKit

class VideoViewController: UIViewController {

    // MARK: - Properties

    let viewModel: VideoViewModel

    let sceneViewLeft: SCNView = {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        return sceneView
    }()

    let sceneViewRight: SCNView = {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        return sceneView
    }()

    // MARK: - Lifecycle

    init(with videoViewModel: VideoViewModel) {
        self.viewModel = videoViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch viewModel.orientation {
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
        configureUI()
        viewModel.configurePlayer()
        configureGestures()
        viewModel.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneViewLeft.isPlaying = true
        sceneViewRight.isPlaying = true
        viewModel.startDeviceMotionUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopDeviceMotionUpdates()
        sceneViewLeft.isPlaying = false
        sceneViewRight.isPlaying = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // calculate with of the scene's views
        let height = view.frame.height
        let halfWidth = view.frame.width / 2
        let space = viewModel.space
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

    // MARK: - Methods

    func configureUI() {
        sceneViewLeft.translatesAutoresizingMaskIntoConstraints = false
        sceneViewRight.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneViewLeft)
        view.addSubview(sceneViewRight)
        sceneViewLeft.scene = viewModel.leftScene
        sceneViewRight.scene = viewModel.rightScene
        sceneViewLeft.delegate = viewModel.rendererDelegate
        sceneViewRight.delegate = viewModel.rendererDelegate
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        switch key.keyCode {
        case .keyboardLeftArrow:
            viewModel.seekBackward(by: 20)
        case .keyboardRightArrow:
            viewModel.seekForward(by: 20)
        default:
            super.pressesEnded(presses, with: event)
        }
    }

    func configureGestures() {
/*

        // TODO: Consider to refactor it
        // and move to VM
        // There would be only gestures

        for gesture in PlayerGesture.allCases {
            switch gesture {
            case .none:
                break
            case .singleTap:
                <#code#>
            case .singleTapTwoFingers:
                <#code#>
            case .swipeUp:
                <#code#>
            case .swipeDown:
                <#code#>
            case .swipeLeft:
                <#code#>
            case .swipeRight:
                <#code#>
            case .swipeUpTwoFingers:
                <#code#>
            case .swipeDownTwoFingers:
                <#code#>
            }
        }


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
*/
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

    // TODO: Or we should use like:
    // func handleSwipeDown {
    // ...
    // viewModel.handle(.swipeDown)

    /** Play/pause */
    @objc func handlePlay(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.isPlaying.toggle()
        }
    }

    /** Init view of the scene by rotating the sphere according the camera's view */
    @objc func handleInitScenePosition(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.initScenePosition()
        }
    }

    /** Increase value of FOV */
    @objc func handleIncreaseFOV(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.increaseFOV()
        }
    }

    /** Decrease value of FOV */
    @objc func handleDecreaseFOV(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.decreaseFOV()
        }
    }

    /** Rewind backward */
    @objc func handleRewindBackward(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.seekBackward(by: 20)
        }
    }

    /** Rewind forward */
    @objc func handleRewindForward(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.seekForward(by: 20)
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
