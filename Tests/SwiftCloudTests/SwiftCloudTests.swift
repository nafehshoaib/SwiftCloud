import XCTest
@testable import SwiftCloud

final class SwiftCloudTests: XCTestCase {
    enum TestURL: String, CloudServerURLRepresentable {
        case httpBin = "https://httpbin.org/"
    }
    
    enum TestPath: String, CloudServicePathRepresentable {
        case get = "get"
        case post = "post"
        case bearer = "bearer"
    }
    
    var cloudService: CloudService<TestURL, TestPath>!
    
    override func setUp() async throws {
        try await super.setUp()
        cloudService = CloudService(serverURL: .httpBin)
    }
    
    func testGET() async throws {
        let (_, response) = try await cloudService.sendRequest(at: .get, using: .get)
        
        XCTAssertEqual(response.statusCode, 200)
    }
    
    func testPOST() async throws {
        let params = [
            "data": "json body"
        ]
        
        let body = try JSONEncoder().encode(params)
        
        let (data, response) = try await cloudService.sendRequest(at: .post, using: .post, body: body)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            XCTFail("Response is not a json object")
            return
        }
        
        guard let responseJSON = json["json"] as? [String: String] else {
            XCTFail("Response.json is nil")
            return
        }
        
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(responseJSON, params)
    }
    
    func testBearerAuth() async throws {
        cloudService.setAccessToken("feiwoweijewoiwe")
        print(cloudService.isLoggedIn)
        let (_, response) = try await cloudService.sendRequest(at: .bearer, using: .get, authorize: true)
        
        XCTAssertEqual(response.statusCode, 200)
    }
}
