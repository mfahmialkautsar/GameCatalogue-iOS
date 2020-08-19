//
//  Result.swift
//  GameCatalogue
//
//  Created by Jamal on 10/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}
