//
//  OLinkApp.swift
//  OLink
//
//  Created by SJQ on 2021/1/5.
//

import SwiftUI

@main
struct OLinkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
    }
}
