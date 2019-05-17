//
//  Dispatcher.swift
//  Server
//
//  Created by Anton Pavlov on 3/17/19.
//

import Foundation

class Dispatcher {
    static let shared = Dispatcher()
    let serverQueue = DispatchQueue(label: "com.harvard.capstone.serverqueue", attributes: .concurrent)
    let systemQueue = DispatchQueue(label: "com.harvard.capstone.systemqueue", attributes: .concurrent)
}
