//
//  AuthenticationService.swift
//  OLink
//
//  Created by SJQ on 2021/1/21.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthenticationService: ObservableObject {
    @Published var user: User?
    
    func signIn() {
        registerStateListener()
    }
    
    private func registerStateListener() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Sign in state has changed.")
            self.user = user
            
            if let user = user {
                let anonymous = user.isAnonymous ? "anonymously" : ""
                print("User sined in \(anonymous) with user ID \(user.uid).")
            }
            else {
                print("User signed out.")
            }
        }
    }
}
