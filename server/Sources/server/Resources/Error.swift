//
//  Error.swift
//  Server
//
//  Created by Anton Pavlov on 3/17/19.
//

import Foundation

//protocol ServerError:Error {
//    func component() -> String
//    func description() -> String
//    func code() -> Int
//}
//
//enum LocalSystemError: ServerError {
//    case CouldNotSpawnProcess
//
//    func component() -> String {
//        return "Local System Error"
//    }
//
//    func description() -> String {
//        switch self {
//        case .CouldNotSpawnProcess:
//            return "Could not spawn process"
//        default:
//            return "Unknown Error"
//        }
//    }
//
//    func code() -> Int {
//        return 1001
//    }
//}

struct ServerError : Error, CustomStringConvertible {
    let shortDesctiption : String
    var detailedDescription: String?
    var description: String {
        var _sd = "SERVER ERROR: \(shortDesctiption)."
        if let _dd = detailedDescription { _sd.append(_dd) }
        return _sd
    }
    
    init(_ shortDesctiption: String, _ detailedDescription:String? = nil) {
        self.shortDesctiption = shortDesctiption
        self.detailedDescription = detailedDescription
    }
}

