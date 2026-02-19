import Foundation
import Security

/// Helper class for secure Keychain storage
/// More secure than UserDefaults as it's encrypted and harder to tamper with
class KeychainHelper {
    static let shared = KeychainHelper()
    
    private let service = "com.whio.waterreminder"
    
    private init() {}
    
    /// Store a value in Keychain
    func set(key: String, value: String) {
        // Delete existing item first
        delete(key: key)
        
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: .utf8)!
        ]
        
        // Add item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("❌ Keychain save failed for key '\(key)': \(status)")
        }
    }
    
    /// Retrieve a value from Keychain
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    /// Delete a value from Keychain
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
