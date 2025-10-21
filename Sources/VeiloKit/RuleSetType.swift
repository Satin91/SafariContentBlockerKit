//
//  RuleSetType.swift
//  VeiloKit
//
//  Universal rule set type for content blocking
//  Created by Артур Кулик on 21.10.2025
//

import Foundation

/// Represents a set of content blocking rules with metadata
public struct RuleSetType: Hashable, Codable {
    /// Unique identifier for this rule set
    public let identifier: String
    
    /// Safari extension bundle identifier
    public let extensionBundleID: String
    
    /// Source filename for rules (without extension)
    /// e.g., "adblock_rules_adBlock" for "adblock_rules_adBlock.txt"
    public let sourceFileName: String
    
    /// Output JSON filename (without extension)
    /// e.g., "adBlock" for "adBlock.json"
    public let outputFileName: String
    
    public init(
        identifier: String,
        extensionBundleID: String,
        sourceFileName: String,
        outputFileName: String
    ) {
        self.identifier = identifier
        self.extensionBundleID = extensionBundleID
        self.sourceFileName = sourceFileName
        self.outputFileName = outputFileName
    }
    
    /// Get file path in App Group container
    public func getOutputFilePath(groupID: String) -> URL? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: groupID
        ) else {
            return nil
        }
        return groupURL.appendingPathComponent("\(outputFileName).json")
    }
    
    /// Get source file path in bundle
    public func getSourceFilePath(in bundle: Bundle = .main) -> URL? {
        return bundle.path(forResource: sourceFileName, ofType: "txt")
            .flatMap { URL(fileURLWithPath: $0) }
    }
    
    /// Write rules to App Group container
    public func writeRules(_ rules: String, groupID: String) throws {
        guard let filePath = getOutputFilePath(groupID: groupID) else {
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
            print("✅ \(identifier) saved: \(filePath.path) (size: \(fileSize) bytes)")
        } else {
            throw ContentBlockerError.fileNotFoundAfterWrite(filePath)
        }
    }
}

// MARK: - Predefined Rule Sets for Veilo

public extension RuleSetType {
    /// Predefined rule sets for Veilo app
    static func veiloRuleSets() -> [RuleSetType] {
        return [
            RuleSetType(
                identifier: "adBlock",
                extensionBundleID: "com.veilodev.adblocker.adblocker",
                sourceFileName: "adblock_rules_adBlock",
                outputFileName: "adBlock"
            ),
            RuleSetType(
                identifier: "privacy",
                extensionBundleID: "com.veilodev.adblocker.privacy",
                sourceFileName: "adblock_rules_privacy",
                outputFileName: "privacy"
            ),
            RuleSetType(
                identifier: "banners",
                extensionBundleID: "com.veilodev.adblocker.banners",
                sourceFileName: "adblock_rules_banners",
                outputFileName: "banners"
            ),
            RuleSetType(
                identifier: "trackers",
                extensionBundleID: "com.veilodev.adblocker.trackers",
                sourceFileName: "adblock_rules_trackers",
                outputFileName: "trackers"
            ),
            RuleSetType(
                identifier: "advanced",
                extensionBundleID: "com.veilodev.adblocker.advanced",
                sourceFileName: "adblock_rules_advanced",
                outputFileName: "advanced"
            ),
            RuleSetType(
                identifier: "basic",
                extensionBundleID: "com.veilodev.adblocker.basic",
                sourceFileName: "adblock_rules_basic",
                outputFileName: "basic"
            )
        ]
    }
}

