//
//  MoyaError+HasUnderlyingError.swift
//  HasUnderlyingError
//
//  Created by Khoi Truong Minh on 1/4/19.
//  Copyright © 2019 Khoi Truong Minh. All rights reserved.
//

import Foundation
import Moya

extension MoyaError: HasUnderlyingError {

    var underlyingError: Error? {
        switch self {
        case .underlying(let error, _):
            return error
        default:
            return nil
        }
    }
}
