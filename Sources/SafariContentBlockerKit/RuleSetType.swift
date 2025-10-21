//
//  RuleSetType.swift
//  SafariContentBlockerKit
//
//  Universal rule set type for content blocking
//  Created by Artur Kulik on 21.10.2025
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
        } else {
            throw ContentBlockerError.fileNotFoundAfterWrite(filePath)
        }
    }
}
