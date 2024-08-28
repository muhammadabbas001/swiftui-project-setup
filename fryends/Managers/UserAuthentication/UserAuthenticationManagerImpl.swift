//
//  UserAuthenticationManagerImpl.swift
//  Fryends (iOS)
//
//  Created by Muhammad Abbas on 5/17/22.
//

import Combine
//import IterableSDK
import Foundation
//import OneSignal
import Swinject
import UIKit

class UserAuthenticationManagerFactory {

    static func register(with container: Container) {
        let threadSafeResolver = container.synchronize()
        container.register(UserAuthenticationManager.self) { _ in
            logger.debug("Creating user authentication manager...", category: .userContext)
            return UserAuthenticationManagerImpl(with: threadSafeResolver)
        }
        .initCompleted { resolver, initialUserAuthenticationManager in
            let userAuthenticationManager = initialUserAuthenticationManager as! UserAuthenticationManagerImpl
            userAuthenticationManager.setDependencies(withResolver: resolver)
        }
        .inObjectScope(.container)
    }
    
}

private final class UserAuthenticationManagerImpl: UserAuthenticationManager {

    var refreshDetailsCallBack: () -> ()?
        
    // MARK: - Lifecycle

    init(with resolver: Resolver) {

        logger.debug("Constructing UserAuthenticationManager...", category: .lifecycle)
        
        self.refreshDetailsCallBack = { }
        if let jwt = jwt {
            if jwt != "" {
                refreshUserDetails()
            } else {
                logout()
            }
        }
    }

    deinit {
        logger.debug("~UserAuthenticationManager.", category: .lifecycle)
    }
    
    func setDependencies(withResolver resolver: Resolver) {
       
    }

    // MARK: - Variables

    var jwt: String? {
        set {
            modelQueue.sync {
                UserDefaults.standard.jwt = newValue
            }
        }
        get {
            modelQueue.sync {
                UserDefaults.standard.jwt
            }
        }
    }
    
    // MARK: - Functions
    
    func setUserLoggedInWith(jwt: String) {

        modelQueue.sync {
            self.jwt = jwt

            refreshUserDetails()
        }
    }
    
    func refreshUserDetails() {
        // TODO: - Implement get user profile api
    }
    
    func logout() {
        removeJwt()
        setUserLoggedInWith(jwt: "")
    }

    func removeJwt() {
        modelQueue.sync {
            jwt = ""
        }
    }
    
    // MARK: - Private
    
    private let modelQueue = DispatchQueue(
        label: "\(NetworkConstants.ProductDefinition.appDomain).userAuthenticationManager",
        qos: .utility
    )
}
