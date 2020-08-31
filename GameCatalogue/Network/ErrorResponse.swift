//
//  ErrorResponse.swift
//  GameCatalogue
//
//  Created by Jamal on 10/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

enum ErrorResponse: Error {
    case error(Int, String)

    var reason: (code: Int, description: String) {
        switch self {
        case let .error(errorCode, description):
            return (errorCode, description)
        }
    }
}
