//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation
import JSONUtilities

extension API.User {

    /** This can only be done by the logged in user. */
    public enum CreateUser {

      public static let service = APIService<Response>(id: "createUser", tag: "user", method: "POST", path: "/user", hasBody: true)

      public class Request: APIRequest<Response> {

          public var body: User

          public init(body: User) {
              self.body = body
              super.init(service: CreateUser.service)
          }

          public override var jsonBody: Any? {
              return body.encode()
          }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** successful operation */
            case failureDefault(statusCode: Int)

            public var success: Void? {
                switch self {
                default: return nil
                }
            }

            public var response: Any {
                switch self {
                default: return ()
                }
            }

            public var statusCode: Int {
              switch self {
              case .failureDefault(let statusCode, _): return statusCode
              }
            }

            public var successful: Bool {
              switch self {
              case .failureDefault: return false
              }
            }

            public init(statusCode: Int, data: Data) throws {
                switch statusCode {
                default: self = .failureDefault(statusCode: statusCode)
                }
            }

            public var description: String {
                return "\(statusCode) \(successful ? "success" : "failure")"
            }

            public var debugDescription: String {
                var string = description
                let responseString = "\(response)"
                if responseString != "()" {
                    string += "\n\(responseString)"
                }
                return string
            }
        }
    }
}
