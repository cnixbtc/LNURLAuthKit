import Foundation
import LNURLAuthKit

//let k1 = "<...>"
//let url = URL(string: "https://<...>?tag=login&k1=\(k1)")!
//
//let identity = try LNURLAuthIdentity()
//let auth = try LNURLAuth(identity: identity, url: url)
//
//let response = try auth.sign()
//
//var request = URLRequest(url: response)
//request.httpMethod = "GET"
//
//var semaphore = DispatchSemaphore (value: 0)
//let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//    if let error = error {
//        print("Error: \(error)")
//    } else {
//        print("Response: \(String(data: data!, encoding: .utf8)!)")
//    }
//    
//    semaphore.signal()
//}
//
//task.resume()
//semaphore.wait()

