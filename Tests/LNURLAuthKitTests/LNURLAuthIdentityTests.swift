import XCTest
import Security
@testable import LNURLAuthKit

final class LNURLAuthIdentityTests: XCTestCase {
    let dummyPrivateKeyMaterial = "ca55310396106f374407df91538759625bee0c524b1c32b79f63d2cca858e474"
    let dummyChallenge = "94971a330a68361fb9c64d33d4b59e8d13ff6c3e823541e6a0024ace02b5504e"
    
    func testSignatureResultIsSameForSameDomain() throws {
        let identity = try LNURLAuthIdentity(privateKey: dummyPrivateKeyMaterial)
        
        let domain = "auth.example.com"
        
        let signature = try identity.sign(challenge: Data(hex: dummyChallenge), for: domain)
        
        let repeatedSignatureResults = Array(
            repeating: try identity.sign(challenge: Data(hex: dummyChallenge), for: domain),
            count: 5
        )
            
        let allSignaturesAreTheSame = repeatedSignatureResults
            .map { $0.signature }
            .allSatisfy {
                $0.rawRepresentation == signature.signature.rawRepresentation
            }
        
        let allLinkingPublicKeysAreTheSame = repeatedSignatureResults
            .map { $0.linkingPublicKey }
            .allSatisfy {
                $0.rawRepresentation == signature.linkingPublicKey.rawRepresentation
            }

        
        XCTAssert(allSignaturesAreTheSame)
        XCTAssert(allLinkingPublicKeysAreTheSame)
    }
    
    func testSignatureResultIsDifferentForDifferentDomain() throws {
        let identity = try LNURLAuthIdentity(privateKey: dummyPrivateKeyMaterial)
        
        let signatureResult = try identity.sign(challenge: Data(hex: dummyChallenge), for: "auth.example.com")
        let otherSignatureResult = try identity.sign(challenge: Data(hex: dummyChallenge), for: "login.example.com")
        
        XCTAssertNotEqual(
            signatureResult.signature.rawRepresentation,
            otherSignatureResult.signature.rawRepresentation
        )
        
        XCTAssertNotEqual(
            signatureResult.linkingPublicKey.rawRepresentation,
            otherSignatureResult.linkingPublicKey.rawRepresentation
        )
    }
    
    func testLinkingKeyIsDifferentForDifferentIdentities() throws {
        let otherDummyPrivateKeyMaterial = "417a6a5e9a6a4a879aeaba11a11838764c8fa2b959c242d43dea682b3e409b01"
        
        let identity = try LNURLAuthIdentity(privateKey: dummyPrivateKeyMaterial)
        let otherIdentity = try LNURLAuthIdentity(privateKey: otherDummyPrivateKeyMaterial)
        
        let signatureResult = try identity.sign(challenge: Data(hex: dummyChallenge), for: "auth.example.com")
        let otherSignatureResult = try otherIdentity.sign(challenge: Data(hex: dummyChallenge), for: "auth.example.com")
        
        XCTAssertNotEqual(
            signatureResult.signature.rawRepresentation,
            otherSignatureResult.signature.rawRepresentation
        )
        
        XCTAssertNotEqual(
            signatureResult.linkingPublicKey.rawRepresentation,
            otherSignatureResult.linkingPublicKey.rawRepresentation
        )
    }
}
