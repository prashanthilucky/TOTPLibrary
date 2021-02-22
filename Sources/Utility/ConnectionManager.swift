//
//  File.swift
//  
//
//  Created by E0102 on 15/02/21.
//

import UIKit
import Foundation
import NVActivityIndicatorView

public class ConnectionManager: NSObject{

public func getPostString(params:[String:Any]) -> String

    {

        var data = [String]()

        for(key, value) in params

        {
        
        data.append(key + "=\(value)")

        }

        return data.map { String($0) }.joined(separator: "&")

    }

    

    public func callPost(url:URL,params:[String:Any],headers:String,requestMethod : String, finish: @escaping ((message:String, data:Data?)) -> Void)

    {

        print(url)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = requestMethod

        if headers != "nil"

        {

        request.setValue(headers, forHTTPHeaderField:"Authorization")

        }

        var task:URLSessionDataTask?

        let urlconfig = URLSessionConfiguration.default

        urlconfig.timeoutIntervalForRequest = 20

        urlconfig.timeoutIntervalForResource = 60
         
        let session = URLSession(configuration: urlconfig, delegate: ConnectionManager(), delegateQueue: nil)

        let postString = self.getPostString(params: params)

        request.httpBody = postString.data(using: .utf8)

        var result:(message:String, data:Data?) = (message: "Fail", data: nil)

        task = session.dataTask(with: request) { data, response, error in

            guard let data = data, error == nil else {

                print(error?.localizedDescription ?? "No data")

                result.message = "Failure"

                result.data = nil

                finish(result)

                return

            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200{

                print("statusCode should be 200, but is \(httpStatus.statusCode)")

                result.message = "Success"

                result.data = data

                finish(result)

            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 403{

                print("statusCode should be 403, but is \(httpStatus.statusCode)")

                result.message = "Success"

                result.data = data

                finish(result)

            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 401{

                // print("statusCode should be 401, but is \(httpStatus.statusCode)")

                result.message = "Failure"

                result.data = data

                finish(result)

            }

            if (error != nil){

//                AppUtils.showAlertMessage(message:(Constants.SERVERERROR as AnyObject) as! String)

            }

        }

        task?.resume()

    }

    

    public func convertTorawString(value: AnyObject) -> NSData? {

        do {

            let rawData = try JSONSerialization.data(withJSONObject: value, options: []) as NSData

            return rawData

            // you can now cast it with the right type

        } catch {

            // print(error.localizedDescription)

        }

        return nil

    }

    

    

}



extension ConnectionManager: URLSessionDelegate {
func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                if (errSecSuccess == status) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: "SSLNew1", ofType: "der")
                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    print("Certificate pinning is successfully completed")
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        // Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
    
    
}
