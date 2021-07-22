import XCTest
import Alamofire
@testable import Request
import Request

final class RequestTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        SampleRequest.request(type: SampleModel.self,
                              config: SampleApi()) { model in
            
        } failure: { code, message in
            
        }

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

class SampleRequest: API {
    static var defaultHeadersConfig: ((inout HTTPHeaders) -> Void)?
    static var host: String {"https://www.xxx.com"}
}

struct SampleApi:APIConfig {
    var path: String {"/api/json"}
    var parameters: [String : Any]? {
        [
            "name":"josercc"
        ]
    }
}

struct SampleModel:Model {
    var _isSuccess: Bool {self._code == 0}
    var _code: Int {0}
    var _message: String {"success"}
}
