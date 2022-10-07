import Foundation
import LNURLAuthKit

@main struct LNURLAuthExample {
    static func main() async throws {
        let lnurl = "lnurl1..."

        let identity = try LNURLAuthIdentity()
        let auth = try LNURLAuth(identity: identity, lnurl: lnurl)

        let url = try auth.sign()

        let response = try await login(signed: url)
            
        print(response)
    }
}

extension LNURLAuthExample {
    static func login(signed url: URL) async throws -> String {
        guard #available(macOS 12.0, *)  else { fatalError() }
        
        let (data, _) = try await URLSession.shared.data(from: url)
            
        return String(data: data, encoding: .utf8)!
    }
}
