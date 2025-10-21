//
//  RuleSetType.swift
//  SafariContentBlockerKit
//
//  Universal rule set protocol for content blocking
//  Created by Artur Kulik on 21.10.2025
//

import Foundation

/// Protocol that defines a content blocking rule set
/// Implement this protocol in your enum to define custom rule sets
///
/// Example:
/// ```swift
/// enum MyRuleSets: String, RuleSetType {
///     case adBlock
///     case privacy
///     
///     var identifier: String { rawValue }
///     var extensionBundleID: String {
///         switch self {
///         case .adBlock: return "com.app.adblocker"
///         case .privacy: return "com.app.privacy"
///         }
///     }
///     // ... implement other properties
/// }
/// ```
public protocol RuleSetType {
    /// Unique identifier for this rule set
    var identifier: String { get }
    
    /// Safari extension bundle identifier
    var extensionBundleID: String { get }
    
    /// Source filename for rules (without extension)
    /// e.g., "adblock_rules_adBlock" for "adblock_rules_adBlock.txt"
    var sourceFileName: String { get }
    
    /// Output JSON filename (without extension)
    /// e.g., "adBlock" for "adBlock.json"
    var outputFileName: String { get }
}

// MARK: - Helper Methods

public extension RuleSetType {
    /// Get file path in App Group container
    /// - Parameter groupID: App Group identifier
    /// - Returns: URL to the output file or nil if group container not found
    func getOutputFilePath(groupID: String) -> URL? {
        return RuleSetHelper.getOutputFilePath(
            for: self,
            groupID: groupID
        )
    }
    
    /// Get source file path in bundle
    /// - Parameter bundle: Bundle to search in (default: .main)
    /// - Returns: URL to the source file or nil if not found
    func getSourceFilePath(in bundle: Bundle = .main) -> URL? {
        return RuleSetHelper.getSourceFilePath(
            for: self,
            in: bundle
        )
    }
    
    /// Write rules to App Group container
    /// - Parameters:
    ///   - rules: JSON string with rules
    ///   - groupID: App Group identifier
    /// - Throws: ContentBlockerError if write fails
    func writeRules(_ rules: String, groupID: String) throws {
        try RuleSetHelper.writeRules(
            rules,
            for: self,
            groupID: groupID
        )
    }
}

// MARK: - Rule Set Helper

/// Helper class with static methods for working with RuleSetType
public enum RuleSetHelper {
    
    /// Get file path in App Group container
    public static func getOutputFilePath(for ruleSet: RuleSetType, groupID: String) -> URL? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: groupID
        ) else {
            return nil
        }
        return groupURL.appendingPathComponent("\(ruleSet.outputFileName).json")
    }
    
    /// Get source file path in bundle
    public static func getSourceFilePath(for ruleSet: RuleSetType, in bundle: Bundle = .main) -> URL? {
        return bundle.path(forResource: ruleSet.sourceFileName, ofType: "txt")
            .flatMap { URL(fileURLWithPath: $0) }
    }
    
    /// Write rules to App Group container
    public static func writeRules(_ rules: String, for ruleSet: RuleSetType, groupID: String) throws {
        guard let filePath = getOutputFilePath(for: ruleSet, groupID: groupID) else {
            throw ContentBlockerError.invalidGroupID(groupID)
        }
        
        let fileManager = FileManager.default
        
        // Write atomically
        try rules.write(to: filePath, atomically: true, encoding: .utf8)
        
        // Force synchronization
        let fileHandle = try FileHandle(forWritingTo: filePath)
        try fileHandle.synchronize()
        try fileHandle.close()
        
        // Verify
        if fileManager.fileExists(atPath: filePath.path) {
            let attributes = try? fileManager.attributesOfItem(atPath: filePath.path)
            let fileSize = attributes?[.size] as? Int64 ?? 0
            _ = fileSize // Suppress warning
        } else {
            throw ContentBlockerError.fileNotFoundAfterWrite(filePath)
        }
    }
}
