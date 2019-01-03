//
//  ActionError+HasUnderlyingError.swift
//  HasUnderlyingError
//
//  Created by Khoi Truong Minh on 1/3/19.
//  Copyright © 2019 Khoi Truong Minh. All rights reserved.
//

import Foundation
import Action

extension ActionError: HasUnderlyingError {

    var underlyingError: Error? {
        switch self {
        case .underlyingError(let error):
            return error
        case .notEnabled:
            return nil
        }
    }
}
