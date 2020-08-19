//
//  ErrorResponse.swift
//  GameCatalogue
//
//  Created by Jamal on 10/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

enum ErrorResponse: Error {
    case errorCode(Int)
    case responseCode(Int)

    var reason: Int {
        switch self {
        case let .errorCode(errorCode):
            return errorCode
        case let .responseCode(responseCode):
            return responseCode
        }
    }
}
