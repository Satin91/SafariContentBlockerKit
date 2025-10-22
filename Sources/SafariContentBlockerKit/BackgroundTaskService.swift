//
//  BackgroundTaskService.swift
//  SafariContentBlockerKit
//

import UIKit
import Foundation

/// Service for executing operations with background mode support
/// Automatically manages iOS background task lifecycle
public final class BackgroundTaskService {
    
    // MARK: - Private Properties
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private let lock = NSLock()
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    
    /// Executes operation with background mode support
    /// iOS provides ~30 seconds to complete after app enters background
    ///
    /// - Parameter operation: Asynchronous operation to execute
    /// - Returns: Result of the operation
    ///
    /// Example usage:
    /// ```swift
    /// let result = await backgroundTaskService.execute {
    ///     await someAsyncOperation()
    ///     return true
    /// }
    /// ```
    public func execute<T>(_ operation: @escaping () async -> T) async -> T {
        beginBackgroundTask()
        
        let result = await operation()
        
        endBackgroundTask()
        
        return result
    }
    
    /// Executes operation with background mode support and error handling
    ///
    /// - Parameter operation: Asynchronous operation to execute
    /// - Throws: Error thrown by the operation
    ///
    /// Example usage:
    /// ```swift
    /// try await backgroundTaskService.execute {
    ///     try await someFunctionThatThrows()
    /// }
    /// ```
    public func execute(_ operation: @escaping () async throws -> Void) async throws {
        beginBackgroundTask()
        
        do {
            try await operation()
            endBackgroundTask()
        } catch {
            endBackgroundTask()
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    /// Begins background task
    private func beginBackgroundTask() {
        lock.lock()
        defer { lock.unlock() }
        
        guard backgroundTaskID == .invalid else {
            return
        }
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    /// Ends background task
    private func endBackgroundTask() {
        lock.lock()
        defer { lock.unlock() }
        
        guard backgroundTaskID != .invalid else { return }
        
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}

// MARK: - Convenience Extensions

public extension BackgroundTaskService {
    /// Executes operation without return value
    ///
    /// Example usage:
    /// ```swift
    /// await backgroundTaskService.execute {
    ///     await performLongOperation()
    /// }
    /// ```
    func execute(_ operation: @escaping () async -> Void) async {
        await execute { () -> Void in
            await operation()
        }
    }
}
