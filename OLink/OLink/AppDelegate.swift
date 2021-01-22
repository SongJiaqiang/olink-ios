//
//  AppDelegate.swift
//  OLink
//
//  Created by SJQ on 2021/1/21.
//

import Foundation
import UIKit
import Firebase
import Resolver

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    @Injected var authenticcationService: AuthenticationService
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
        FirebaseApp.configure()
        authenticcationService.signIn()
        
        return true
    }
}
