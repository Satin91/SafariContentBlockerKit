//
//  ContentBlockerConfiguration.swift
//  VeiloKit
//
//  Configuration for ContentBlockerService
//  Created by Артур Кулик on 21.10.2025
//

import Foundation

/// Configuration for content blocker service
public struct ContentBlockerConfiguration {
    /// App Group identifier for shared container
    public let appGroupID: String
    
    /// Rule sets to manage
    public let ruleSets: [RuleSetType]
    
    /// Bundle to load source files from
    public let sourceBundle: Bundle
    
    /// Safari version for conversion
    public let safariVersion: SafariVersion
    
    /// Enable advanced blocking rules
    public let advancedBlocking: Bool
    
    /// Maximum JSON size in bytes (nil = no limit)
    public let maxJsonSizeBytes: Int?
    
    public init(
        appGroupID: String,
        ruleSets: [RuleSetType],
        sourceBundle: Bundle = .main,
        safariVersion: SafariVersion = .safari16,
        advancedBlocking: Bool = true,
        maxJsonSizeBytes: Int? = nil
    ) {
        self.appGroupID = appGroupID
        self.ruleSets = ruleSets
        self.sourceBundle = sourceBundle
        self.safariVersion = safariVersion
        self.advancedBlocking = advancedBlocking
        self.maxJsonSizeBytes = maxJsonSizeBytes
    }
}

// MARK: - Predefined Configurations

public extension ContentBlockerConfiguration {
    /// Default configuration for Veilo app
    static func veilo(appGroupID: String) -> ContentBlockerConfiguration {
        return ContentBlockerConfiguration(
            appGroupID: appGroupID,
            ruleSets: RuleSetType.veiloRuleSets(),
            sourceBundle: .main,
            safariVersion: .safari16,
            advancedBlocking: true,
            maxJsonSizeBytes: nil
        )
    }
}

