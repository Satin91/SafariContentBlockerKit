//
//  BackgroundTaskService.swift
//  VeiloKit
//
//  Created by Артур Кулик on 21.10.2025.
//

import UIKit
import Foundation

/// Сервис для выполнения операций с поддержкой фонового режима
/// Автоматически управляет жизненным циклом фоновых задач iOS
public final class BackgroundTaskService {
    
    // MARK: - Private Properties
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private let lock = NSLock()
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    
    /// Выполняет операцию с поддержкой фонового режима
    /// iOS предоставляет ~30 секунд для завершения операции после сворачивания приложения
    ///
    /// - Parameter operation: Асинхронная операция для выполнения
    /// - Returns: Результат выполнения операции
    ///
    /// Пример использования:
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
    
    /// Выполняет операцию с поддержкой фонового режима и обработкой ошибок
    ///
    /// - Parameter operation: Асинхронная операция для выполнения
    /// - Throws: Ошибку, выброшенную операцией
    ///
    /// Пример использования:
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
    
    /// Начинает фоновую задачу
    private func beginBackgroundTask() {
        lock.lock()
        defer { lock.unlock() }
        
        // Если задача уже запущена, не создаем новую
        guard backgroundTaskID == .invalid else {
            print("⚠️ Фоновая задача уже запущена")
            return
        }
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            // Вызывается когда время истекло (~30 секунд)
            print("⚠️ Фоновая задача истекла, принудительное завершение")
            self?.endBackgroundTask()
        }
        
        if backgroundTaskID != .invalid {
            print("✅ Фоновая задача начата (ID: \(backgroundTaskID.rawValue))")
        } else {
            print("❌ Не удалось начать фоновую задачу")
        }
    }
    
    /// Завершает фоновую задачу
    private func endBackgroundTask() {
        lock.lock()
        defer { lock.unlock() }
        
        guard backgroundTaskID != .invalid else { return }
        
        let taskID = backgroundTaskID
        print("✅ Фоновая задача завершена (ID: \(taskID.rawValue))")
        
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}

// MARK: - Convenience Extensions

public extension BackgroundTaskService {
    /// Выполняет операцию без возврата значения
    ///
    /// Пример использования:
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

