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
        print("DEBUG: Deinit of the view controller")
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
        var allAvailableGestures: [PlayerGesture: () -> Void] = [:]
        allAvailableGestures[.singleTap] = createSingleTapGesture
        allAvailableGestures[.singleTapTwoFingers] = createSingleTapTwoFingers
        allAvailableGestures[.swipeUp] = createSwipeUp
        allAvailableGestures[.swipeDown] = createSwipeDown
        allAvailableGestures[.swipeLeft] = createSwipeLeft
        allAvailableGestures[.swipeRight] = createSwipeRight
        allAvailableGestures[.swipeUpTwoFingers] = createSwipeUpTwoFingers
        allAvailableGestures[.swipeDownTwoFingers] = createSwipeDownTwoFingers
        // Create and activate only customized gestures
        for gesture in viewModel.gestures {
            allAvailableGestures[gesture]?()
        }
    }

    func createSingleTapGesture() {
        let singleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTap)
    }

    func createSingleTapTwoFingers() {
        let singleTapTwoFingers = UITapGestureRecognizer(
            target: self,
            action: #selector(handleSingleTapTwoFingers(_:)))
        singleTapTwoFingers.numberOfTapsRequired = 1
        singleTapTwoFingers.numberOfTouchesRequired = 2
        view.addGestureRecognizer(singleTapTwoFingers)
    }

    func createSwipeUp() {
        let swipeUp = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeUp(_:)))
        swipeUp.direction = .up
        swipeUp.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeUp)
    }

    func createSwipeDown() {
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeDown(_:)))
        swipeDown.direction = .down
        swipeDown.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeDown)
    }

    func createSwipeLeft() {
        let swipeLeft = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeLeft(_:)))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeLeft)
    }

    func createSwipeRight() {
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeRight(_:)))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeRight)
    }

    func createSwipeUpTwoFingers() {
        let swipeUpTwoFingers = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeUpTwoFingers(_:)))
        swipeUpTwoFingers.direction = .up
        swipeUpTwoFingers.numberOfTouchesRequired = 2
        view.addGestureRecognizer(swipeUpTwoFingers)
    }

    func createSwipeDownTwoFingers() {
        let swipeDownTwoFingers = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeDownTwoFingers(_:)))
        swipeDownTwoFingers.direction = .down
        swipeDownTwoFingers.numberOfTouchesRequired = 2
        view.addGestureRecognizer(swipeDownTwoFingers)
    }

    // MARK: - Selectors

    @objc func handleSingleTap(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.singleTap)
        }
    }

    @objc func handleSingleTapTwoFingers(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.singleTapTwoFingers)
        }
    }

    @objc func handleSwipeUp(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.swipeUp)
        }
    }

    @objc func handleSwipeDown(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.swipeDown)
        }
    }

    @objc func handleSwipeLeft(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.swipeLeft)
        }
    }

    @objc func handleSwipeRight(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.swipeRight)
        }
    }

    @objc func handleSwipeUpTwoFingers(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.swipeUpTwoFingers)
        }
    }

    @objc func handleSwipeDownTwoFingers(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            viewModel.handleGesture(.swipeDownTwoFingers)
        }
    }

}

// MARK: - VideoViewModelDelegate

extension VideoViewController: VideoViewModelDelegate {

    func closeVideo() {
        dismiss(animated: true)
    }

}
