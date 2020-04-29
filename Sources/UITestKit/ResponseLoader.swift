//
//  File.swift
//  
//
//  Created by Jan Halozan on 29/04/2020.
//

import Foundation

public enum ResponseLoaderError: Error {
    case fixtureNotFound
    
    public var localizedDescription: String {
        switch self {
        case .fixtureNotFound: return "Fixture not found."
        }
    }
}

public protocol ResponseLoader {
    func response(forRequestPath path: String) throws -> String
}

open class DefaultResponseLoader: ResponseLoader {
    
    public let fixtureDirectory: String
    
    public init(fixtureDirectory dir: String) {
        self.fixtureDirectory = dir
    }
    
    open func response(forRequestPath path: String) throws -> String {
        if let str = try? String(contentsOfFile: "\(self.fixtureDirectory)\(path)/200.json") {
            return str
        }
        
        throw ResponseLoaderError.fixtureNotFound
    }
}
