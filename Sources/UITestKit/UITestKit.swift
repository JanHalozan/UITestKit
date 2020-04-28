//import Swifter

import HttpSwift
import SocketSwift

open class UITestKit {
    
    private let server: Server
    
    public init(port: SocketSwift.Port = 8080) {
        self.server = Server()
        
        
    }
    
}
