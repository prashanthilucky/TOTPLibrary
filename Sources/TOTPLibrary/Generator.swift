//
//  File.swift
//  
//
//  Created by E0102 on 10/02/21.
//

import Foundation

#if canImport(Crypto)
// Where available, use Swift Crypto
// On Apple platforms, this will just re-expose CryptoKit's API
import Crypto
#else
import CryptoKit
#endif

internal class Generator {

    // Generator singleton
    static let shared = Generator()
    
    /// Generates a one time password string
    /// - parameter secret: The secret key data
    /// - parameter algorithm: The hashing algorithm to use of type OTPAlgorithm
    /// - parameter counter: UInt64 Counter value
    /// - parameter digits: Number of digits for generated string in range 6...8, defaults to 6
    /// - returns: One time password string, nil if error
    @available(OSX 10.15, *)
    func generateOTP(secret: Data, algorithm: OTPAlgorithm = .sha1, counter: UInt64, digits: Int = 6) -> String? {
        // HMAC message data from counter as big endian
        let counterMessage = counter.bigEndian.data

        // HMAC hash counter data with secret key
        var hmac = Data()

        switch algorithm {
        case .sha1:
            if #available(OSX 10.15, *) {
                hmac = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterMessage, using: SymmetricKey.init(data: secret)))
            } else {
                // Fallback on earlier versions
            }
        case .sha256:
            hmac = Data(HMAC<SHA256>.authenticationCode(for: counterMessage, using: SymmetricKey.init(data: secret)))
        case .sha512:
            hmac = Data(HMAC<SHA512>.authenticationCode(for: counterMessage, using: SymmetricKey.init(data: secret)))
        }

        
        // Get last 4 bits of hash as offset
        let offset = Int((hmac.last ?? 0x00) & 0x0f)
        
        // Get 4 bytes from the hash from [offset] to [offset + 3]
        let truncatedHMAC = Array(hmac[offset...offset + 3])
        
        // Convert byte array of the truncated hash to data
        let data =  Data(truncatedHMAC)
        
        // Convert data to UInt32
        var number = UInt32((data.bytes.toHexString(), nil, 16))
        
        // Mask most significant bit
        number &= 0x7fffffff
        
        // Modulo number by 10^(digits)
        number = number % UInt32(pow(10, Float(digits)))

        // Convert int to string
        let strNum = String(number)
        
        // Return string if adding leading zeros is not required
        if strNum.count == digits {
            return strNum
        }
        
        // Add zeros to start of string if not present and return
        let prefixedZeros = String(repeatElement("0", count: (digits - strNum.count)))
        return (prefixedZeros + strNum)
    }
}
