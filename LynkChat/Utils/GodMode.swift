//
//  GodMode.swift
//  LynkChat
//

import Foundation
import CryptoKit
import Security

@Observable
final class GodMode {
    // SHA256 of the activation passphrase — the passphrase itself is never stored.
    private static let activationHash = "c08ee0e9f1600152d85c4b3137460a6e49966176b90c6e360186a1372977b08f"
    private static let keychainKey = "com.lynkchat.godmode.activated"

    private(set) var isActivated: Bool = false

    var availableCases: [ChatModel] {
        isActivated ? ChatModel.allCases : [.gemini_flash]
    }

    init() {
        isActivated = Keychain.read(key: GodMode.keychainKey) == "1"
    }

    /// Returns true if the passphrase is correct and god mode was activated.
    @discardableResult
    func tryActivate(passphrase: String) -> Bool {
        let digest = SHA256.hash(data: Data(passphrase.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        guard hex == GodMode.activationHash else { return false }
        Keychain.write(key: GodMode.keychainKey, value: "1")
        isActivated = true
        return true
    }

    func deactivate() {
        Keychain.delete(key: GodMode.keychainKey)
        isActivated = false
    }
}

// MARK: - Minimal Keychain wrapper

private enum Keychain {
    static func write(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }

    static func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
