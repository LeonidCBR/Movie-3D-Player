//
//  SceneDelegate.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 10.09.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow.init(windowScene: windowScene)
        window?.rootViewController = DocumentBrowserViewController()
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first,
              let documentBrowserVC = window?.rootViewController as? DocumentBrowserViewController
        else {
            return
        }
        // Close the previous video controller if it's presented
        if let videoVC = documentBrowserVC.presentedViewController as? VideoViewController {
            videoVC.closeVideo()
        }
        documentBrowserVC.presentVideo(at: context.url)
    }

}
