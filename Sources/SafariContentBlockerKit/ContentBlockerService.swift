//
//  ContentBlockerService.swift
//  SafariContentBlockerKit
//

import Foundation
import SafariServices

/// Universal content blocker service for iOS Safari extensions
public class ContentBlockerService {
    
    // MARK: - Properties
    
    private let configuration: ContentBlockerConfiguration
    
    // MARK: - Cancellation Support
    
    private var shouldCancelOperation = false
    private var isEnabling = false
    
    // MARK: - Initialization
    
    public init(configuration: ContentBlockerConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    
    /// Cancels current operation
    public func cancelAllOperations() {
        if isEnabling {
            shouldCancelOperation = true
        }
    }
    
    /// Get file URL for specific rule set
    public func getFileURL(for ruleSet: RuleSetType) -> URL? {
        return ruleSet.getOutputFilePath()
    }
    
    /// Find rule set by extension bundle ID
    /// - Parameter bundleID: Safari extension bundle identifier
    /// - Returns: Matching RuleSetType or nil
    public func ruleSet(forBundleID bundleID: String) -> (RuleSetType)? {
        return configuration.ruleSets.first { $0.extensionBundleID == bundleID }
    }
    
    /// Get file URL for extension with current bundle ID (for Safari extensions)
    /// - Returns: URL to the rules file, or fallback empty rules if not found
    public func getFileURLForCurrentExtension() -> URL? {
        guard let bundleID = Bundle.main.bundleIdentifier else { return nil }
        guard let ruleSet = ruleSet(forBundleID: bundleID) else { return nil }
        return ruleSet.getOutputFilePath()
    }
    
    /// Apply or remove blocking rules
    /// - Parameter isEnabled: true to enable, false to disable
    /// - Returns: true if successful, false if cancelled
    public func applyBlockingState(_ isEnabled: Bool) async -> Bool {
        if isEnabled {
            isEnabling = true
            shouldCancelOperation = false
            
            await enableContentBlocker()
            
            let wasCancelled = shouldCancelOperation
            isEnabling = false
            shouldCancelOperation = false
            
            if wasCancelled {
                await rollbackAll()
                return false
            }
            
            return true
        } else {
            await generateEmptyRules()
            return true
        }
    }
    
    /// Convert and save all rules (for preloading)
    public func convertAndSaveAllRules() async {
        
        await withTaskGroup(of: Void.self) { group in
            for ruleSet in configuration.ruleSets {
                group.addTask {
                    await self.convertAndSaveRules(for: ruleSet)
                }
            }
        }
        
    }
    
    // MARK: - Private Methods
    
    private func enableContentBlocker() async {
        // Check cache first
        if let cachedRules = loadCachedRules() {
            await saveConvertedRulesToGroup(cachedRules)
            await reloadExtensions(maxRetries: 2)
            return
        }
        
        await convertAndSaveAllRules()
        await reloadExtensions(maxRetries: 3)
    }
    
    private func convertAndSaveRules(for ruleSet: RuleSetType) async {
        guard let sourcePath = ruleSet.getSourceFilePath(in: configuration.sourceBundle) else {
            return
        }
        
        do {
            let rulesString = try String(contentsOf: sourcePath, encoding: .utf8)
            let lines = rulesString.components(separatedBy: .newlines)
            
            let result = ContentBlockerConverter().convertArray(
                rules: lines,
                safariVersion: configuration.safariVersion,
                advancedBlocking: configuration.advancedBlocking,
                maxJsonSizeBytes: configuration.maxJsonSizeBytes,
                progress: nil
            )
            
            try ruleSet.writeRules(result.safariRulesJSON)
            upsertRuleInCache(result.safariRulesJSON, for: ruleSet)
            
        } catch {
        }
    }
    
    // MARK: - Cache Management
    
    private func upsertRuleInCache(_ jsonRule: String, for ruleSet: RuleSetType) {
        var cached = loadCachedRules() ?? []
        
        let requiredCount = configuration.ruleSets.count
        if cached.count < requiredCount {
            cached.append(contentsOf: Array(repeating: "", count: requiredCount - cached.count))
        }
        
        // Compare by identifier instead of using Equatable
        if let idx = configuration.ruleSets.firstIndex(where: { $0.identifier == ruleSet.identifier }) {
            cached[idx] = jsonRule
        }
        
        saveRulesToCache(cached)
    }
    
    private func saveRulesToCache(_ rules: [String]) {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: configuration.appGroupID
        ) else { return }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            try jsonData.write(to: cacheURL)
        } catch {
        }
    }
    
    private func loadCachedRules() -> [String]? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: configuration.appGroupID
        ) else { return nil }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        guard fileManager.fileExists(atPath: cacheURL.path) else { return nil }
        
        do {
            let jsonData = try Data(contentsOf: cacheURL)
            return try JSONSerialization.jsonObject(with: jsonData) as? [String]
        } catch {
            return nil
        }
    }
    
    // MARK: - Extension Management
    
    private func reloadExtensions(maxRetries: Int) async {
        let bundles = configuration.ruleSets.map { $0.extensionBundleID }
        guard !bundles.isEmpty else { return }
        
        let startTime = Date()
        await withTaskGroup(of: Void.self) { group in
            for bundle in bundles {
                group.addTask {
                    await self.reloadSingleExtension(bundle: bundle, maxRetries: maxRetries)
                }
            }
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
    }
    
    @MainActor
    private func reloadSingleExtension(bundle: String, maxRetries: Int) async {
        var attempts = 0
        
        while attempts < maxRetries {
            if isEnabling && shouldCancelOperation {
                return
            }
            
            attempts += 1
            
            do {
                try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundle)
                return
            } catch {
                if attempts == maxRetries {
                }
            }
        }
    }
    
    // MARK: - Empty Rules
    
    private func generateEmptyRules() async {
        let emptyRule = createEmptyRule()
        guard let emptyJSON = convertRulesToJSON([emptyRule]) else { return }
        
        for ruleSet in configuration.ruleSets {
            try? ruleSet.writeRules(emptyJSON)
        }
        
        await reloadExtensions(maxRetries: 2)
    }
    
    private func rollbackAll() async {
        let emptyRule = createEmptyRule()
        guard let emptyJSON = convertRulesToJSON([emptyRule]) else { return }
        
        for ruleSet in configuration.ruleSets {
            try? ruleSet.writeRules(emptyJSON)
        }
        
        await reloadExtensions(maxRetries: 2)
    }
    
    private func saveConvertedRulesToGroup(_ rules: [String]) async {
        for (index, ruleSet) in configuration.ruleSets.enumerated() {
            if let rule = rules[safe: index] {
                try? ruleSet.writeRules(rule)
            } else {
                let emptyRule = createEmptyRule()
                if let emptyJSON = convertRulesToJSON([emptyRule]) {
                    try? ruleSet.writeRules(emptyJSON)
                }
            }
        }
    }
    
    private func createEmptyRule() -> [String: Any] {
        return [
            "trigger": [
                "url-filter": "^https?://never-existing-domain-for-adblocker-disabled\\.com/.*"
            ],
            "action": [
                "type": "block"
            ]
        ]
    }
    
    private func convertRulesToJSON(_ rules: [[String: Any]]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

// MARK: - Array Extension

private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

