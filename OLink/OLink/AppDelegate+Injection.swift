//
//  AppDelegate+Injection.swift
//  OLink
//
//  Created by SJQ on 2021/1/21.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register {
            AuthenticationService()
        }
        .scope(.application)
        
        register {
            FirestoreTaskRepository() as TaskRepository
        }
        .scope(.application)
    }
}
