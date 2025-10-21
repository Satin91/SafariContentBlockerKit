//
//  ContentBlockerError.swift
//  VeiloKit
//
//  Errors for ContentBlockerService
//  Created by Артур Кулик on 21.10.2025
//

import Foundation

/// Errors that can occur during content blocking operations
public enum ContentBlockerError: LocalizedError {
    case invalidGroupID(String)
    case fileNotFoundAfterWrite(URL)
    case sourceFileNotFound(String)
    case conversionFailed(String)
    case extensionReloadFailed(String, Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidGroupID(let groupID):
            return "Invalid App Group ID: \(groupID)"
        case .fileNotFoundAfterWrite(let url):
            return "File not found after write: \(url.path)"
        case .sourceFileNotFound(let fileName):
            return "Source file not found: \(fileName)"
        case .conversionFailed(let reason):
            return "Conversion failed: \(reason)"
        case .extensionReloadFailed(let bundle, let error):
            return "Extension reload failed for \(bundle): \(error.localizedDescription)"
        }
    }
}

