import Foundation
import Security

class SecureDataManager {
    static let shared = SecureDataManager()
    
    private init() {}
    
    // MARK: - Keychain Operations
    
    private func saveToKeychain(data: Data, key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func loadFromKeychain(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess ? result as? Data : nil
    }
    
    // MARK: - Symptom History
    
    func saveSymptomHistory(_ history: [SymptomEntry]) throws {
        let data = try JSONEncoder().encode(history)
        if !saveToKeychain(data: data, key: "symptomHistory") {
            throw SecureDataError.saveFailed
        }
    }
    
    func loadSymptomHistory() throws -> [SymptomEntry] {
        guard let data = loadFromKeychain(key: "symptomHistory") else {
            return []
        }
        return try JSONDecoder().decode([SymptomEntry].self, from: data)
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) throws {
        let data = try JSONEncoder().encode(profile)
        if !saveToKeychain(data: data, key: "userProfile") {
            throw SecureDataError.saveFailed
        }
    }
    
    func loadUserProfile() throws -> UserProfile? {
        guard let data = loadFromKeychain(key: "userProfile") else {
            return nil
        }
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
}

enum SecureDataError: Error {
    case saveFailed
    case loadFailed
} 