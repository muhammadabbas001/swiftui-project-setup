//
//  AppEventsManager.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas on 26/09/2023.
//

import Combine
import SwiftUI

/// This class will handle some Fryends apps core events
final public class AppEventsManager {
    
    // MARK: - Publishers
    
    var presentSideMenu = PassthroughSubject<Bool, Never>()
    var backToHome = PassthroughSubject<Bool, Never>()
    var switchSideMenuTab = PassthroughSubject<Int, Never>()
    var showLogoutAlert = PassthroughSubject<Bool, Never>()
    var updateCardsList = PassthroughSubject<Bool, Never>()
}

