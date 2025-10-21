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
///     var groupID: String { "group.com.app" }
///     var identifier: String { rawValue }
///     var extensionBundleID: String {
///         "com.app.extension.\(rawValue)"
///     }
///     var sourceFileName: String {
///         "adblock_rules_\(rawValue)"
///     }
///     var outputFileName: String { rawValue }
/// }
/// ```
public protocol RuleSetType {
    /// App Group identifier for shared container
    var groupID: String { get }
    
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

// MARK: - Extension Methods

public extension RuleSetType {
    /// Get output file path in App Group container
    /// - Returns: URL to the output JSON file or nil if group container not found
    func getOutputFilePath() -> URL? {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupID
        ) else {
            return nil
        }
        return groupURL.appendingPathComponent("\(outputFileName).json")
    }
    
    /// Get source file path in bundle
    /// - Parameter bundle: Bundle to search in (default: .main)
    /// - Returns: URL to the source TXT file or nil if not found
    func getSourceFilePath(in bundle: Bundle = .main) -> URL? {
        return bundle.path(forResource: sourceFileName, ofType: "txt")
            .flatMap { URL(fileURLWithPath: $0) }
    }
    
    /// Write rules to App Group container
    /// - Parameter rules: JSON string with rules
    /// - Throws: ContentBlockerError if write fails
    func writeRules(_ rules: String) throws {
        guard let filePath = getOutputFilePath() else {
            throw ContentBlockerError.invalidGroupID(groupID)
        }
        
        // Write atomically
        try rules.write(to: filePath, atomically: true, encoding: .utf8)
        
        // Force synchronization
        let fileHandle = try FileHandle(forWritingTo: filePath)
        try fileHandle.synchronize()
        try fileHandle.close()
        
        // Verify file exists
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            throw ContentBlockerError.fileNotFoundAfterWrite(filePath)
        }
    }
}
