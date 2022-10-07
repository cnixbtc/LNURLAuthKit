import Foundation
import secp256k1
import Crypto

public struct LNURLAuth {
    private let identity: LNURLAuthIdentity
    private let url: URL
    
    private let domain: String
    private let tag: String
    private let k1: String
    private let action: String?
    
    public init(identity: LNURLAuthIdentity, lnurl: String) throws {
        let url = try Bech32.decode(lnurl: lnurl)
        
        try self.init(identity: identity, url: url)
    }
    
    public init(identity: LNURLAuthIdentity, url: String) throws {
        guard let url = URL(string: url) else {
            throw LNURLAuthError.invalidUrl()
        }
        
        try self.init(identity: identity, url: url)
    }

    public init(identity: LNURLAuthIdentity, url: URL) throws {
        self.identity = identity
        self.url = url
        
        // Make sure the `URL` <-> `URLComponents` transformation
        // is safe so we can use it in the `sign()` function below.
        guard URLComponents(string: url.absoluteString)?.url != nil else { throw LNURLAuthError.invalidUrl() }
        
        guard let domain = url.host else {
            throw LNURLAuthError.invalidUrl(description: "URL doesn't have a domain.")
        }
        guard let tag = url.valueOf("tag") else {
            throw LNURLAuthError.invalidUrl(description: "Missing required query parameter 'tag'.")
        }
        guard let k1 = url.valueOf("k1") else {
            throw LNURLAuthError.invalidUrl(description: "Missing required query parameter 'k1'.")
        }
        
        self.domain = domain
        self.tag = tag
        self.k1 = k1
        
        action = url.valueOf("action")
    }
    
    public func sign() throws -> URL {
        do {
            let sigResult = try identity.sign(challenge: Data(hex: k1), for: domain)
        
            // This is safe. We checked it in `init()`.
            var urlComponents = URLComponents(string: url.absoluteString)!
            
            urlComponents.queryItems?.append(contentsOf: [
                URLQueryItem(name: "sig", value: try sigResult.signature.derRepresentation.hex()),
                URLQueryItem(name: "key", value: sigResult.linkingPublicKey.rawRepresentation.hex())
            ])
            
            // Again, this is safe. We checked it in `init()`.
            return urlComponents.url!
        } catch {
            throw LNURLAuthError.signingFailed(description: error.localizedDescription)
        }
    }
}

private extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}
