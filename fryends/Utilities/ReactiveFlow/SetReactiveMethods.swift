//
//  SetReactiveMethods.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas on 26/09/2023.
//

import SwiftUI
import Combine
import Swinject

class SetReactiveMethods: ObservableObject{
    
    private var appEventsManager = Container.default.resolver.resolve(AppEventsManager.self)!
    
    @Published var selectedTab = 1
    
    /// Present Chat Side Menu
    @Published var presentSideMenu = false
    
    private var cancellable = Set<AnyCancellable>()
    
    init(){
        presentSideMenuObserver()
        switchSideMenuTabObserver()
    }
    
    /// Present side menu
    private func presentSideMenuObserver() {
        appEventsManager.presentSideMenu
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] isPresent in
                presentSideMenu = isPresent
            })
            .store(in: &cancellable)
    }
    
    /// Switch side menu tab observer
    private func switchSideMenuTabObserver() {
        appEventsManager.switchSideMenuTab
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] tab in
                selectedTab = tab
            })
            .store(in: &cancellable)
    }
}
