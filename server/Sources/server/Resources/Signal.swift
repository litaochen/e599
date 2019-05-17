//
//  Signal.swift
//  Server
//
//  Created by Anton Pavlov on 3/17/19.
//

import Foundation

final class WeakObject<A:AnyObject> {
    weak var object : A?
    
    init(_ value:A) {
        object = value
    }
}

class Signal <A> {
    private var children : [WeakObject<Signal<A>>] = []
//    var object : A?
    var onNext : ((A) -> Void)?
    
    func associate(_ inputSig: Signal<A>) {
        children.append(WeakObject(inputSig))
    }
    
    func push(_ message:A) {
        let _ = children.filter { (child) -> Bool in
            return child.object != nil ? true : false
            }.map { $0.object! }.map { (child) -> Void in
                child.push(message)
        }
    }
}
