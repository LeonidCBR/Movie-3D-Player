//
//  DocumentBrowserViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 13.09.2021.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        allowsDocumentCreation = false
        allowsPickingMultipleItems = false

        // TODO: Find settings image

        let settingsBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(settingsButtonTapped))
        additionalTrailingNavigationBarButtonItems = [settingsBarButtonItem]

        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white

        // Specify the allowed content types of your application via the Info.plist.
    }


    // MARK: UIDocumentBrowserViewControllerDelegate

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil

        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }

        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }

    // MARK: Video Presentation

    func presentDocument(at documentURL: URL) {

        let videoViewController = VideoViewController(withFieldOfView: 85.0, andSpace: 20.0)
        videoViewController.document = Document(fileURL: documentURL)
        videoViewController.modalPresentationStyle = .fullScreen
        present(videoViewController, animated: true, completion: nil)
    }


    // MARK: - Selectors

    @objc func settingsButtonTapped() {
        let settingsViewController = SettingsViewController(withFieldOfView: 85.0, andSpace: 20.0)
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        present(navigationController, animated: true, completion: nil)
    }
}

