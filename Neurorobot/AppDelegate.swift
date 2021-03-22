//
//  AppDelegate.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 8/30/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit
import Firebase
import SideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        determineFlow()
        FirebaseApp.configure()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession handleEventsForBackgroundURLSessionidentifier: String,
                     completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
}

extension AppDelegate {
    
    func determineFlow() {
        let vc = SplashViewController.loadFromNib()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func goToConnect() {
        
        let vc = ConnectViewController.loadFromNib()
        let nc = SideMenuNavigationController(rootViewController: vc)
        window?.rootViewController = nc
        
        SideMenuManager.default.rightMenuNavigationController = SideMenuNavigationController(rootViewController: SettingsController())
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: vc.view)
    }
    
    func goToTest() {
        let vc = VideoStreamWithoutRobotViewController.loadFromNib()
        let nc = BaseNavigationViewController(rootViewController: vc)
        moveTo(vc: nc)
    }
}

// MARK: - Utilities
private extension AppDelegate {
    
    func moveTo(vc: UIViewController) {
        performTransitionCrossDissolve(destinationViewController: vc)
    }
    
    func performTransitionCrossDissolve(destinationViewController: UIViewController) {
        guard let window = window, let srcVC = window.rootViewController else { print("Window or rootViewController does not exist"); return }
        
        let dstnVC = destinationViewController
        let mock = createMockView(view: dstnVC.view)
        
        srcVC.view.addSubview(mock)
        mock.alpha = 0
        
        UIView.animate(withDuration: 0.35, delay: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            mock.alpha = 1
        }, completion: { (finished) -> Void in
            srcVC.modalPresentationStyle = .fullScreen
            dstnVC.modalPresentationStyle = .fullScreen
            srcVC.present(dstnVC, animated: false, completion: {
                mock.removeFromSuperview()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    window.rootViewController = dstnVC
                    window.makeKeyAndVisible()
                }
            })
        })
    }
    
    
    func createMockView(view: UIView) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, UIScreen.main.scale)

        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        return UIImageView(image: image)
    }
}
