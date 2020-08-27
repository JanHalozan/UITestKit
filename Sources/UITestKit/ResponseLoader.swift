//
//  File.swift
//  
//
//  Created by Jan Halozan on 29/04/2020.
//

import Foundation

public enum ResponseLoaderError: Error {
    case fixtureNotFound, scenarioNotFound
    
    public var localizedDescription: String {
        switch self {
        case .fixtureNotFound: return "Fixture not found."
        case .scenarioNotFound: return "Scenario folder not found."
        }
    }
}

public protocol ResponseLoader {
    var scenario: String? { get set }
    
    func response(forMethod: String, requestPath path: String, queryParameters: [String: String]) throws -> String
}

open class DefaultResponseLoader: ResponseLoader {
    
    public let fixtureDirectory: String
    
    public var scenario: String?
    
    public init(fixtureDirectory dir: String) {
        self.fixtureDirectory = dir
    }
    
    open func response(forMethod method: String, requestPath path: String, queryParameters: [String: String]) throws -> String {
        let query = queryParameters.map({ (key, value) in
                return "\(key.lowercased())-\(value.lowercased())"
            })
            .sorted()
            .joined(separator: "&")
        
        if let scenario = self.scenario {
            let folder: String
            let folderPath: String
            if let index = scenario.lastIndex(of: "/") {
                folder = String(scenario[scenario.index(after: index) ..< scenario.endIndex])
                folderPath = "\(self.fixtureDirectory)/\(scenario[scenario.startIndex ..< index])"
            } else {
                folder = scenario
                folderPath = self.fixtureDirectory
            }
            if !self.folderExists(atPath: folderPath, folderName: folder) {
                throw ResponseLoaderError.scenarioNotFound
            }
            
            if let content = self.readScenarioFile(path: path, query: query, method: method, folderPath: "\(folderPath)/\(folder)") {
                return content
            }
        } else {
            if let content = self.readFile(query: query, method: method, path: "\(self.fixtureDirectory)\(path)") {
                return content
            }
            
            let components = path.split(separator: "/").map({ return String($0) })
            var fullPath = self.fixtureDirectory
            for component in components {
                if self.folderExists(atPath: fullPath, folderName: component) {
                    fullPath += "/\(component)"
                } else if self.folderExists(atPath: fullPath, folderName: "*") {
                    fullPath += "/*"
                } else {
                    throw ResponseLoaderError.fixtureNotFound
                }
            }
            
            if let content = self.readFile(query: query, method: method, path: fullPath) {
                return content
            }
        }

        throw ResponseLoaderError.fixtureNotFound
    }
    
    private func folderExists(atPath path: String, folderName folder: String) -> Bool {
        let manager = FileManager.default
        guard let contents = try? manager.contentsOfDirectory(atPath: path) else {
            return false
        }
        
        return contents.contains(folder)
    }
    
    private func readScenarioFile(path: String, query: String, method: String, folderPath: String, statusCode: Int = 200) -> String? {
        var filename = method.uppercased()// query.count > 0 ? "\(method.uppercased())_\(query).json" : "\(method.uppercased()).json"
        if query.count > 0 {
            filename += "_\(query)"
        }
        if let endpoint = path.components(separatedBy: "/").last, endpoint.count > 0 {
            filename += "_\(endpoint)"
        }
        filename += ".json"
        let statusFolder = "/"//statusCode == 200 ? "/" : "/\(statusCode)/"
        var file = "\(folderPath)\(statusFolder)\(filename)"
        if let str = try? String(contentsOfFile: file) { //First try the longest filename
            return str
        }

        if let endpoint = path.components(separatedBy: "/").last, endpoint.count > 0 {
            filename = "\(endpoint).json"
        } else {
            filename = "default.json"
        }
        file = "\(folderPath)\(statusFolder)\(filename)" //Then try the default for that method
        if let str = try? String(contentsOfFile: file) {
            return str
        }

        return nil
    }
    
    private func readFile(query: String, method: String, path: String, statusCode: Int = 200) -> String? {
        let filename = query.count > 0 ? "\(method.uppercased())_\(query).json" : "\(method.uppercased()).json"
        let statusFolder = "/\(statusCode)/"//statusCode == 200 ? "/" : "/\(statusCode)/"
        var file = "\(path)\(statusFolder)\(filename)"
        if let str = try? String(contentsOfFile: file) { //First try the longest filename
            return str
        }
        
        file = "\(path)\(statusFolder)\(method)_default.json" //Then try the default for that method
        if let str = try? String(contentsOfFile: file) {
            return str
        }
        
        file = "\(path)\(statusFolder)default.json" //Then try the default for that path
        if let str = try? String(contentsOfFile: file) {
            return str
        }
        
        return nil
    }
}
