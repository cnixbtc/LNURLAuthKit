// Code largely taken from: https://github.com/LN-Zap/SwiftBTC

import Foundation

// See: https://github.com/fiatjaf/lnurl-rfc/blob/luds/01.md
internal enum Bech32 {
    static func decode(lnurl: String) throws -> URL {
        guard let (hrp, decodedData) = decode(lnurl, limit: false) else {
            throw LNURLAuthError.invalidLNURL
        }
        
        guard hrp.lowercased() == "lnurl" else {
            throw LNURLAuthError.invalidLNURL
        }
        
        guard let data = decodedData.convertBits(fromBits: 5, toBits: 8, pad: false) else {
            throw LNURLAuthError.invalidLNURL
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw LNURLAuthError.invalidLNURL
        }
        
        guard let url = URL(string: string) else {
            throw LNURLAuthError.invalidLNURL
        }
        
        return url
    }
}

// See: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
private extension Bech32 {
    static let alphabet = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
    static let generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
    
    static func decode(_ bechString: String, limit: Bool = true) -> (humanReadablePart: String, data: Data)? {
        guard bechString.onlyHasValidBech32Characters() else { return nil }

        let lowercasedBechString = bechString.lowercased()
        guard let endOfHrpIdx = lowercasedBechString.lastIndex(of: "1") else { return nil }
        
        let endOfHrpPos = lowercasedBechString.distance(from: lowercasedBechString.startIndex, to: endOfHrpIdx)

        if endOfHrpPos < 1 || (endOfHrpPos + 7) > lowercasedBechString.count {
            return nil
        }
        
        if limit && lowercasedBechString.count > 90 {
           return nil
        }

        let humanReadablePart = String(lowercasedBechString.prefix(endOfHrpPos))
        let dataPart = lowercasedBechString.suffix(lowercasedBechString.count - humanReadablePart.count - 1)

        var data = Data()
        for character in dataPart {
            print(character)
            guard let charIdx = Bech32.alphabet.firstIndex(of: character) else { return nil }
            let charPos = Bech32.alphabet.distance(from: Bech32.alphabet.startIndex, to: charIdx)
            data.append(UInt8(charPos))
        }
        
        guard verifyChecksum(humanReadablePart: humanReadablePart, data: data) else { return nil }

        return (humanReadablePart, Data(data[..<(data.count - 6)]))
    }
    
    static func verifyChecksum(humanReadablePart: String, data: Data) -> Bool {
        return polymod(values: expandHumanReadablePart(humanReadablePart) + data) == 1
    }
    
    static func polymod(values: Data) -> Int {
        var chk = 1
        for p in values {
            let top = chk >> 25
            chk = (chk & 0x1ffffff) << 5 ^ Int(p)
            for (i, g) in Bech32.generator.enumerated() where ((top >> i) & 1) != 0 {
                chk ^= g
            }
        }
        return chk
    }
    
    static func expandHumanReadablePart(_ humanReadablePart: String) -> Data {
        guard let stringBytes = humanReadablePart.data(using: .utf8) else { return Data() }
        var data = Data()

        for character in stringBytes {
            data.append(UInt8(UInt32(character) >> 5))
        }
        data.append(0)
        for character in stringBytes {
            data.append(UInt8(UInt32(character) & 31))
        }
        return data
    }
}

private extension String {
    func onlyHasValidBech32Characters() -> Bool {
        guard let stringBytes = self.data(using: .utf8) else { return false }

        var hasLower = false
        var hasUpper = false

        for character in stringBytes {
            let code = UInt32(character)
            if code < 33 || code > 126 {
                return false
            } else if code >= 97 && code <= 122 {
                hasLower = true
            } else if code >= 65 && code <= 90 {
                hasUpper = true
            }
        }

        return !(hasLower && hasUpper)
    }
}

private extension Data {
    // ConvertBits converts a byte slice where each byte is encoding fromBits bits,
    // to a byte slice where each byte is encoding toBits bits.
    func convertBits(fromBits: Int, toBits: Int, pad: Bool) -> Data? {
        var acc: Int = 0
        var bits: Int = 0
        var result = Data()
        let maxv: Int = (1 << toBits) - 1

        for value in self {
            if value < 0 || (value >> fromBits) != 0 {
                return nil
            }

            acc = (acc << fromBits) | Int(value)
            bits += fromBits

            while bits >= toBits {
                bits -= toBits
                result.append(UInt8((acc >> bits) & maxv))
            }
        }

        if pad {
            if bits > 0 {
                result.append(UInt8((acc << (toBits - bits)) & maxv))
            }
        } else if bits >= fromBits || ((acc << (toBits - bits)) & maxv) != 0 {
            return nil
        }

        return result
    }
}
