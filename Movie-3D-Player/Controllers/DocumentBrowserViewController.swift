//
//  DocumentBrowserViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 13.09.2021.
//

import UIKit
import CoreMotion

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(settingsButtonTapped))
        additionalTrailingNavigationBarButtonItems = [settingsBarButtonItem]
    }

    // MARK: UIDocumentBrowserViewControllerDelegate

    func documentBrowser(_ controller: UIDocumentBrowserViewController,
                         didRequestDocumentCreationWithHandler importHandler:
                         @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        // Set the URL for the new document here.
        // Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        presentVideo(at: sourceURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController,
                         didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentVideo(at: destinationURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController,
                         failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        // TODO: - Show error message
        print("DEBUG: ERROR: Import is failed!")
    }

    // MARK: Video Presentation

    func presentVideo(at videoURL: URL) {
        let document = Document(fileURL: videoURL)
        let motionManager = CMMotionManager()
        let settings = SettingsProvider()
        let delegate: RendererDelegate
        switch settings.orientation {
        case .leftSideDown:
            delegate = RendererWithLeftOrientation(motionManager: motionManager)
        case .rightSideDown:
            delegate = RendererWithRightOrientation(motionManager: motionManager)
        }
        let videoViewController = VideoViewController(with: document,
                                                      settingsProvider: settings,
                                                      motionManager: motionManager,
                                                      rendererDelegate: delegate)
        videoViewController.modalPresentationStyle = .fullScreen
        present(videoViewController, animated: true)
    }

    // MARK: - Selectors

    @objc func settingsButtonTapped() {
        let settingsViewController = SettingsViewController()
        let closeAction = UIAction { _ in
            self.dismiss(animated: true)
        }
        settingsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close,
                                                                                  primaryAction: closeAction)
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
