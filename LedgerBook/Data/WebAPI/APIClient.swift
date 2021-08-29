//
//  APIClient.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/25.
//

import Foundation

enum APIClientError: Error {
    case parseError
    case encodingError(encodingError: Error)
    case networkError
    case apiError(detail: APIError)
}

struct APIError {
    
    init(code: HttpStatusCode, message: String) {
        self.code = code
        self.resource = ""
        self.field = ""
        self.message = message
    }
    
    init(code: HttpStatusCode, resource: String, field: String, message: String) {
        self.code = code
        self.resource = resource
        self.field = field
        self.message = message
    }
    
    var code: HttpStatusCode = .BadRequest
    var resource = ""
    var field = ""
    var message = ""
}

class APIClient: NSObject {
    static func sendRequest<T : Request>(request: T, success: @escaping (_ json: T.Response?) -> Void, failure: @escaping (_ error: APIClientError?) -> Void) {
        let requestMethod = request.httpMethod
        var urlComponents = URLComponents(url: request.url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = request.queryParameters
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = requestMethod.rawValue

        do {
            let requestBody = try JSONSerialization.data(withJSONObject: request.parameters, options: [])
            urlRequest.httpBody = requestBody
        } catch let error {
            LBDebugPrint(error.localizedDescription)
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error as NSError?, error.domain == NSURLErrorDomain, error.code == NSURLErrorNotConnectedToInternet {
                LBDebugPrint("not connected")
                failure(.networkError)
                return
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != HttpStatusCode.Ok.rawValue {
                    var httpStatusCode = HttpStatusCode.Unknown
                    if let _httpStatusCode = HttpStatusCode(rawValue: response.statusCode) {
                        httpStatusCode = _httpStatusCode
                    }
                    let apiError = APIError(code: httpStatusCode, message: "some error happened.")
                    failure(.apiError(detail: apiError))
                    return
                }
            }
            do {
                if let data = data {
                    let jsonObject: [String:Any]? = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary
                    if jsonObject != nil {
                        let responseData = request.responseFromJsonObject(jsonObject!)
                        success(responseData)
                    } else {
                        success(nil)
                    }
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    }

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch   = "PATCH"
}

enum HttpStatusCode: Int {
    case Unknown = -1
    case Continue = 100
    case SwitchingProtocols = 101
    case Processing = 102
    case Ok = 200
    case Created = 201
    case Accepted = 202
    case NonAuthoritativeInformation = 203
    case NoContent = 204
    case ResetContent = 205
    case PartialContent = 206
    case MultiStatus = 207
    case IMUsed = 226
    case MultipleChoices = 300
    case MovedPermanently = 301
    case Found = 302
    case SeeOther = 303
    case MotModified = 304
    case UseProxy = 305
    case UnUsed = 306
    case TemporaryRedirect = 307
    case BadRequest = 400
    case Unauthorized = 401
    case PaymentRequired = 402
    case Forbidden = 403
    case NotFound = 404
    case MethodNotAllowed = 405
    case NotAcceptable = 406
    case ProxyAuthenticationRequired = 407
    case RequestTimeout = 408
    case Conflict = 409
    case Gone = 410
    case LengthRequired = 411
    case PreconditionFailed = 412
    case RequestEntityTooLarge = 413
    case RequestURITooLong = 414
    case UnsupportedMediaType = 415
    case RequestedRangeNotSatisfiable = 416
    case ExpectationFailed = 417
    case ImaTeapot = 418
    case UnprocessableEntity = 422
    case Locked = 423
    case FailedDependency = 424
    case UpgradeRequired = 426
    case InternalServerError = 500
    case NotImplemented = 501
    case BadGateway = 502
    case ServiceUnavailable = 503
    case GatewayTimeout = 504
    case HttpVersionNotSupported = 505
    case VariantAlsoNegotiates = 506
    case InsufficientStorage = 507
    case BandwidthLimitExceeded = 509
    case NotExtended = 510
}
