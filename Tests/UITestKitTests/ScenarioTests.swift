import XCTest
import Foundation
@testable import UITestKit

final class ScenarioTests: XCTestCase {
    
    struct Box {
        static var kit = UITestKit(port: 4321, fixtureDirectory: MainFixturesDirectory)
    }
    
    static var allTests = [
        ("testScenario", testScenario)
    ]
    
    override class func setUp() {
        try! Box.kit.listen()
    }
    
    func testScenario() {
        Box.kit.loadScenario("DummyScenario")
        
        let url = URL(string: "http://localhost:4321/partial/endpoint")!
        let expectation = XCTestExpectation(description: "Expect the request to succeed")
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssert((response as? HTTPURLResponse)?.statusCode == 200, "Should succeed with 200")
            expectation.fulfill()
        }).resume()
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testSubscenario() {
        Box.kit.loadScenario("DummyScenario/Subscenario")
        
        let url = URL(string: "http://localhost:4321")!
        let expectation = XCTestExpectation(description: "Expect the request to succeed")
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssert((response as? HTTPURLResponse)?.statusCode == 200, "Should succeed with 200")
            expectation.fulfill()
        }).resume()
        
        wait(for: [expectation], timeout: 10)
    }
}
