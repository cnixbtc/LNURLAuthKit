import Foundation
import secp256k1
import Crypto

public struct LNURLAuthIdentity {
    private let privateKey: secp256k1.Signing.PrivateKey
    
    public init() throws {
        do {
            privateKey = try secp256k1.Signing.PrivateKey()
        } catch {
            throw LNURLAuthError.privateKeyGenerationFailed(description: error.localizedDescription)
        }
    }
    
    public init(privateKey: String) throws {
        try self.init(privateKey: .init(hex: privateKey))
    }
    
    public init(privateKey: Data) throws {
        do {
            self.privateKey = try secp256k1.Signing.PrivateKey(rawRepresentation: privateKey)
        } catch {
            throw LNURLAuthError.privateKeyGenerationFailed(description: error.localizedDescription)
        }
    }
}

internal extension LNURLAuthIdentity {
    typealias SigningResult = (
        signature: secp256k1.Signing.ECDSASignature,
        linkingPublicKey: secp256k1.Signing.PublicKey
    )
    
    func sign(challenge: Data, for domain: String) throws -> SigningResult {
        let linkingPrivateKey = try linkingPrivateKey(for: domain)
        let linkingPublicKey = linkingPrivateKey.publicKey
        
        return (
            signature: try linkingPrivateKey.ecdsa.signature(for: HashDigest(challenge.bytes)),
            linkingPublicKey: linkingPublicKey
        )
    }
    
    private func linkingPrivateKey(for domain: String) throws -> secp256k1.Signing.PrivateKey {
        // See: https://github.com/fiatjaf/lnurl-rfc/blob/luds/13.md
        
        // 1. The following canonical phrase is defined:
        let canonicalPhrase = """
            DO NOT EVER SIGN THIS TEXT WITH YOUR PRIVATE KEYS! \
            IT IS ONLY USED FOR DERIVATION OF LNURL-AUTH HASHING-KEY, \
            DISCLOSING ITS SIGNATURE WILL COMPROMISE YOUR LNURL-AUTH IDENTITY AND MAY LEAD TO LOSS OF FUNDS!
            """

        // 2. LN WALLET obtains a deterministic signature of sha256(utf8ToBytes(canonical phrase)) using secp256k1.
        let canonicalPhraseDigest = Crypto.SHA256.hash(
            data: canonicalPhrase.data(using: .utf8)!
        )
        let deterministicSignature = try privateKey.ecdsa.signature(
            for: HashDigest(canonicalPhraseDigest.bytes)
        ).rawRepresentation
        
        // 3. LN WALLET defines hashingKey as PrivateKey(sha256(obtained signature)).
        let hashingKey = Crypto.SymmetricKey(
            data: Crypto.SHA256.hash(data: deterministicSignature).bytes
        )
        
        // 4. The service-specific linkingPrivKey is defined as PrivateKey(hmacSha256(hashingKey, service domain name)).
        let linkingPrivateKeyBytes = HMAC<Crypto.SHA256>.authenticationCode(
            for: domain.data(using: .utf8)!, using: hashingKey
        ).bytes
        
        return try secp256k1.Signing.PrivateKey(rawRepresentation: linkingPrivateKeyBytes)
    }
}
