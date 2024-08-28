//
//  NilModel.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas on 02/09/2022.
//
// MARK: - This is to be set in the place of 'T' when no data type is needed for an endpoint call

import Foundation

struct NilModel: Decodable, Hashable {
    let isNil: Bool?
}
