//
//  AppDelegate.swift
//  3Dplayer
//
//  Created by Яна Латышева on 10.09.2021.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .moviePlayback)

/*
        let videoDirName = "Video"
        if let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let videoURL = baseDir.appendingPathComponent(videoDirName)
            if !FileManager.default.fileExists(atPath: videoURL.path) {
                do {
                    print("DEBUG: Creating video directory...")
                    try FileManager.default.createDirectory(at: videoURL, withIntermediateDirectories: false, attributes: nil)
                    // TODO: Look at => attributes: [FileAttributeKey : Any]?)
                } catch {
                    print("ERROR: Creating directory is faild! \(error)")
                }
            } else {
                print("DEBUG: Video directory exists.")
            }
        }
*/
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

