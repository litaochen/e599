//
//  Job.swift
//  Server
//
//  Created by Anton Pavlov on 3/26/19.
//

import Foundation
import Kitura
import KituraContracts

protocol Job {
    associatedtype ReturnType
    associatedtype ErrorType
    func execute(completion:@escaping(ReturnType?, ErrorType?) -> Void)
    func dispatch(completion:@escaping(ReturnType?, ErrorType?) -> Void)
}

extension Job {
    func dispatch(completion:@escaping(ReturnType?, ErrorType?) -> Void) {
        Dispatcher.shared.serverQueue.async {
            self.execute(completion: completion)
        }
    }
}
