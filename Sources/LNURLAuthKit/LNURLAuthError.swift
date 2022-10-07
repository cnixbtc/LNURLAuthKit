import secp256k1

public enum LNURLAuthError: Error {
    // LNURLAuth Errors
    case invalidUrl(description: String? = nil)
    case signingFailed(description: String)
    
    // LNURLAuthIdentity Errors
    case privateKeyGenerationFailed(description: String)
    
    // Bech32 Errors
    case invalidLNURL
}
