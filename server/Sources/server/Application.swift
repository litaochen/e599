//
//  Application.swift
//  Server
//
//  Created by Anton Pavlov on 3/9/19.
//

import Foundation
import Kitura
import LoggerAPI

public class App {
    let serverRouter = ServerRouter()
    
    private func applicationInit() {
        Log.info("Starting application initialization - loading...")
        serverRouter.setupRoutes()
        Log.info("Server routes created")
        MongoDB.shared.initDB()
    }
    
    public func run() {
        if let err = LocalServerConfig.shared.setup() {
            Log.error("Could not load local server config. Exiting")
            Log.error(err.description)
            exit(1)
        }
        
        applicationInit()
        Kitura.addHTTPServer(onPort: 8081, with: serverRouter.router)
        Kitura.run()
    }
}
