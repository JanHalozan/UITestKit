//import Swifter

import HttpSwift
import SocketSwift
import Foundation

open class UITestKit {
    
    private let server: Server
    private let port: SocketSwift.Port
    
    public var responseLoader: ResponseLoader
    
    public init(port: SocketSwift.Port = 8080, fixtureDirectory: String) {
        self.responseLoader = DefaultResponseLoader(fixtureDirectory: fixtureDirectory)
        
        self.port = port
        self.server = Server()
        self.server.middlewares.append(self.handleRequest)
    }
    
    open func listen() throws {
        do {
            try server.run(port: self.port)
        }
    }
    
    open func loadScenario(_ scenario: String) {
        self.responseLoader.scenario = scenario
    }
    
    open func resetScenario() {
        self.responseLoader.scenario = nil
    }
    
    func handleRequest(req: Request, next: RouteHandler) throws -> Response {
        do {
            let content = try self.responseLoader.response(forMethod: req.method, requestPath: req.path, queryParameters: req.queryParams)
            return .ok(content, headers: ["Content-Type": "application/json"])
        } catch {
            throw error
        }
    }
}
