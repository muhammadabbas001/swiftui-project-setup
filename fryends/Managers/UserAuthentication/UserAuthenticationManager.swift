//
//  UserAuthenticationManager.swift
//  Fryends (iOS)
//
//  Created by Muhammad Abbas on 5/17/22.
//

import Foundation
import Swinject

protocol UserAuthenticationManager: AnyObject {

    // MARK: - Callbacks
    
    var refreshDetailsCallBack:() -> ()? { get set }
    
    // MARK: - Variables

    var jwt: String? { get set }
    
    // MARK: - Functions

    func setUserLoggedInWith(jwt: String)
    func refreshUserDetails()
    func logout()
    func removeJwt()
}
