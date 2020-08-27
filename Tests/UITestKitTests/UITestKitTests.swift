import XCTest
import Foundation
@testable import UITestKit

//Path not working yet. See https://stackoverflow.com/questions/47177036/use-resources-in-unit-tests-with-swift-package-manager
static let MainFixturesDirectory = "../Fixtures"

final class UITestKitTests: XCTestCase {
    
    struct Box {
        static var kit = UITestKit(port: 4321, fixtureDirectory: MainFixturesDirectory)
    }
    
    static var allTests = [
        ("testListen", testListen),
        ("testNonexistentEndpoint", testNonexistentEndpoint),
        ("testExistentEndpoint", testExistentEndpoint)
    ]
    
    override class func setUp() {
        try! Box.kit.listen()
    }
    
    func testListen() throws {
        let url = URL(string: "http://localhost:1337")!
        var expectation = XCTestExpectation(description: "Expect the request to fail")
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssertNil(data, "Data should be empty as no response should be returned")
            XCTAssertNotNil(error, "There should be an error present")
            expectation.fulfill()
        }).resume()
        
        wait(for: [expectation], timeout: 10)
        
        let dummy = UITestKit(port: 1337, fixtureDirectory: "doesn't matter")
        try dummy.listen()
        
        expectation = XCTestExpectation(description: "Expect the request to succeed")
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssertNotNil(data, "Data should be present as the response should succeed")
            XCTAssertNil(error, "There should be no error")
            expectation.fulfill()
        }).resume()
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testNonexistentEndpoint() {
        let url = URL(string: "http://localhost:4321/doesntexist")!
        var expectation = XCTestExpectation(description: "Expect the request to fail")
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssert((response as? HTTPURLResponse)?.statusCode == 500, "Should fail with a 500")
            expectation.fulfill()
        }).resume()
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testExistentEndpoint() {
        let url = URL(string: "http://localhost:4321")!
        let expectation = XCTestExpectation(description: "Expect the request to succeed")
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssert((response as? HTTPURLResponse)?.statusCode == 200, "Should succeed with 200")
            expectation.fulfill()
        }).resume()
        
        wait(for: [expectation], timeout: 10)
    }
    
//    func testKeepRunningFor10Minutes() {
//        //This test is used for having the server running
//        let expectation = XCTestExpectation(description: "Testing")
//        wait(for: [expectation], timeout: 600)
//    }
}
