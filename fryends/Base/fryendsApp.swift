//
//  fryendsApp.swift
//  fryends
//
//  Created by Muhammad Abbas on 28/08/2024.
//

import SwiftUI
import Swinject

var logger = Logger()

@main
struct fryendsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Set global DI objects container
private let container = Container.default.container

/// It is important to use the AppDelegate class because self is mutating.
/// In struct self is not  mutating so that's why SDK code is in class
/// In SwiftUI @main will be a struct, we can use the @main with class but in that case also we will call the AppDelegate method
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Registrations
        registerDIObjects()
        
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        return true
    }
}

extension AppDelegate {
    
    /// Register the DI objects that will be used in this app and also run some methods
    private func registerDIObjects() {
        
        // Register DI objects
        
        // Register UserAuthenticationManager
        UserAuthenticationManagerFactory.register(with: container)
        
        // Register AppEventsManager
        let tempAppEventsManager = AppEventsManager()
        container.register(AppEventsManager.self) { _ in  tempAppEventsManager }
    }
}

