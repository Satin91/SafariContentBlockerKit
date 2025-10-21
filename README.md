# SafariContentBlockerKit

Swift Package with universal utilities and content blocking services for iOS Safari extensions.

[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📦 Features

- **ContentBlockerService**: Universal service for managing Safari content blocker extensions
- **RuleSetType**: Flexible rule set management with custom configurations
- **BackgroundTaskService**: Manage iOS background tasks with async/await support
- **ContentBlocker**: Convert AdGuard rules to Safari Content Blocker format (iOS-adapted fork of [AdguardTeam/SafariConverterLib](https://github.com/AdguardTeam/SafariConverterLib))

## 🔧 Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## 📥 Installation

### Swift Package Manager

#### Via Xcode:
1. File → Add Package Dependencies...
2. Enter: `https://github.com/Satin91/SafariContentBlockerKit.git`
3. Select version (recommended: "Up to Next Major Version")
4. Add Package

#### Via Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/Satin91/SafariContentBlockerKit.git", from: "1.0.0")
]
```

Add to your target:
```swift
.target(
    name: "YourTarget",
    dependencies: ["SafariContentBlockerKit"]
)
```

## 🚀 Usage

### Quick Start

```swift
import SafariContentBlockerKit

// 1. Define your rule sets using enum (recommended approach)
enum MyRuleSets: String, CaseIterable, RuleSetType {
    case adBlock
    case privacy
    
    var groupID: String { "group.com.yourapp" }
    var identifier: String { rawValue }
    
    var extensionBundleID: String {
        switch self {
        case .adBlock: return "com.yourapp.extension.adblocker"
        case .privacy: return "com.yourapp.extension.privacy"
        }
    }
    
    var sourceFileName: String {
        switch self {
        case .adBlock: return "adblock_rules_adBlock"
        case .privacy: return "adblock_rules_privacy"
        }
    }
    
    var outputFileName: String {
        switch self {
        case .adBlock: return "adBlock"
        case .privacy: return "privacy"
        }
    }
}

// 2. Create configuration
let configuration = ContentBlockerConfiguration(
    appGroupID: "group.com.yourapp.adblocker",
    ruleSets: MyRuleSets.allCases.map { $0 as any RuleSetType }
)

// 3. Initialize service
let contentBlockerService = ContentBlockerService(configuration: configuration)

// 4. Enable content blocking
let success = await contentBlockerService.applyBlockingState(true)

// 5. Preload rules cache (optional, for onboarding)
await contentBlockerService.convertAndSaveAllRules()
```

### Safari Extension Usage

In your Safari extension's `ContentBlockerRequestHandler`:

```swift
import SafariContentBlockerKit

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        // Use the same enum from your main app
        let configuration = ContentBlockerConfiguration(
            appGroupID: "group.com.yourapp",
            ruleSets: MyRuleSets.allCases.map { $0 as any RuleSetType }
        )
        
        let service = ContentBlockerService(configuration: configuration)
        
        // Automatically finds rules for current extension by bundle ID
        guard let rulesURL = service.getFileURLForCurrentExtension() else {
            context.cancelRequest(withError: NSError(...))
            return
        }
        
        let attachment = NSItemProvider(contentsOf: rulesURL)!
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
}
```

### BackgroundTaskService

Manage critical operations that need to complete even when app is backgrounded:

```swift
import SafariContentBlockerKit

class MyRepository {
    private let backgroundTaskService = BackgroundTaskService()
    
    func performCriticalOperation() async -> Bool {
        // iOS gives ~30 seconds to complete
        await backgroundTaskService.execute {
            await heavyTask()
            return true
        }
    }
}
```

**⚠️ Important:** Only use `BackgroundTaskService` for critical operations. For preloading/optimization, use regular `Task` to avoid excessive memory usage.

### ContentBlockerConverter (Direct Usage)

```swift
import SafariContentBlockerKit

let converter = ContentBlockerConverter()
let rules = [
    "||example.com^",
    "||ads.com^",
    "##.ad-banner"
]

let result = converter.convertArray(
    rules: rules,
    safariVersion: .safari16,
    advancedBlocking: true
)

print("Converted: \(result.totalRulesCount) rules")
print("Safari rules: \(result.safariRulesCount)")
print("JSON: \(result.safariRulesJSON)")
```

## 📋 Components

### RuleSetType Protocol

Define your content blocking rules using a protocol-based approach:

```swift
public protocol RuleSetType: Equatable {
    var groupID: String { get }
    var identifier: String { get }
    var extensionBundleID: String { get }
    var sourceFileName: String { get }
    var outputFileName: String { get }
}
```

**Benefits:**
- ✅ Type-safe enum-based approach
- ✅ Compile-time checks for all cases
- ✅ Easy to iterate with `allCases`
- ✅ Centralized configuration with groupID
- ✅ Self-sufficient protocol extensions (no helper needed)
- ✅ Equatable for comparison operations

**Example:**
```swift
enum MyRuleSets: String, CaseIterable, RuleSetType {
    case adBlock, privacy, trackers
    
    var groupID: String { "group.com.app" }
    var identifier: String { rawValue }
    var extensionBundleID: String {
        "com.app.extension.\(rawValue)"
    }
    var sourceFileName: String {
        "adblock_rules_\(rawValue)"
    }
    var outputFileName: String { rawValue }
}

// Usage - protocol is self-sufficient:
let ruleSet = MyRuleSets.adBlock
let url = ruleSet.getOutputFilePath()  // No groupID parameter needed!
try ruleSet.writeRules(jsonString)      // groupID is built-in
```

### ContentBlockerService

Universal service for managing Safari content blocker extensions:

- ✅ Rule conversion (AdGuard format → Safari format)
- ✅ Extension reloading with retry logic
- ✅ Caching for faster subsequent loads
- ✅ App Group container management
- ✅ Cancellation support
- ✅ Parallel/sequential rule processing

### RuleSetType

Flexible rule set management:

```swift
let ruleSet = RuleSetType(
    identifier: "adBlock",                           // Unique ID
    extensionBundleID: "com.app.extension.adblocker", // Safari extension bundle
    sourceFileName: "adblock_rules_adBlock",         // Input file (no .txt)
    outputFileName: "adBlock"                        // Output file (no .json)
)
```

### ContentBlockerConfiguration

Configuration for ContentBlockerService:

- `appGroupID`: App Group identifier
- `ruleSets`: Array of RuleSetType
- `sourceBundle`: Bundle to load source files from
- `safariVersion`: Target Safari version
- `advancedBlocking`: Enable advanced rules
- `maxJsonSizeBytes`: Size limit (optional)

### BackgroundTaskService

iOS background task management:

- ✅ Automatic lifecycle management
- ✅ Thread-safe (NSLock)
- ✅ Async/await support
- ✅ Error handling
- ✅ ~30 seconds execution time

### ContentBlockerConverter

AdGuard rules → Safari Content Blocker format:

- ✅ Network rules (blocking)
- ✅ Cosmetic rules (element hiding)
- ✅ Scriptlet rules
- ✅ Advanced blocking
- ✅ Domain-specific rules
- ✅ Exceptions and whitelisting

## 🎯 File Structure

### Source Files Required

Your app bundle should include `.txt` files with AdGuard rules:

```
YourApp.app/
└── adblock_rules_adBlock.txt
└── adblock_rules_privacy.txt
└── ...
```

### Output Files (App Group)

SafariContentBlockerKit saves converted rules to App Group container:

```
group.com.yourapp/
└── adBlock.json
└── privacy.json
└── cached_rules.json (cache)
```

## 📚 Advanced Usage

### Memory Optimization

For Onboarding/preloading, avoid using `BackgroundTaskService`:

```swift
// ❌ Bad: Uses excessive memory (6GB+)
await backgroundTaskService.execute {
    await contentBlockerService.convertAndSaveAllRules()
}

// ✅ Good: Normal memory usage (~500MB)
Task(priority: .utility) {
    await contentBlockerService.convertAndSaveAllRules()
}
```

**Why?** `UIApplication.beginBackgroundTask` tells iOS this is a critical operation, causing iOS to allocate more memory. For non-critical preloading, use regular Task.

### Rule Set Examples

**Custom rule sets:**
```swift
let customSets = [
    RuleSetType(
        identifier: "social",
        extensionBundleID: "com.app.social",
        sourceFileName: "social_rules",
        outputFileName: "social"
    ),
    RuleSetType(
        identifier: "annoyances",
        extensionBundleID: "com.app.annoyances",
        sourceFileName: "annoyances_rules",
        outputFileName: "annoyances"
    )
]

let configuration = ContentBlockerConfiguration(
    appGroupID: "group.com.app",
    ruleSets: customSets
)
```

### Error Handling

```swift
do {
    try ruleSet.writeRules(jsonString, groupID: groupID)
} catch ContentBlockerError.invalidGroupID(let id) {
    print("Invalid group: \(id)")
} catch ContentBlockerError.fileNotFoundAfterWrite(let url) {
    print("Write failed: \(url)")
} catch {
    print("Unknown error: \(error)")
}
```

## 📝 Attribution

This package includes modified code from [AdguardTeam/SafariConverterLib](https://github.com/AdguardTeam/SafariConverterLib) (MIT License). See [NOTICE.md](NOTICE.md) for detailed attribution.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 👨‍💻 Authors

- **Artur Kulik** - iOS adaptations, universal service layer, BackgroundTaskService
- **AdGuard Team** - Original SafariConverterLib (macOS)

## 🙏 Acknowledgments

Special thanks to the AdGuard Team for their excellent [SafariConverterLib](https://github.com/AdguardTeam/SafariConverterLib) which made this iOS adaptation possible.

## 📚 Related Projects

- [AdguardTeam/SafariConverterLib](https://github.com/AdguardTeam/SafariConverterLib) - Original macOS library
- [Veilo](https://github.com/Satin91/Veilo) - iOS app using SafariContentBlockerKit

---

## 🐛 Troubleshooting

### Package not updating

```bash
# Clear SPM cache
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm
```

In Xcode: File → Packages → Reset Package Caches

### Compilation errors

Make sure:
- iOS 15.0+ deployment target
- Swift 5.9+ language version
- All source `.txt` files are in app bundle
- App Group is configured correctly

### Rules not applying

1. Check Safari extension is enabled in Settings
2. Verify App Group ID is correct
3. Check console for error messages
4. Try reloading extension manually

## 📖 Documentation

For more examples and detailed documentation, see:
- [NOTICE.md](NOTICE.md) - Attribution and licenses
- [Examples/](Examples/) - Code examples (coming soon)

## 🔄 Versioning

We use [Semantic Versioning](http://semver.org/). For available versions, see the [tags on this repository](https://github.com/Satin91/SafariContentBlockerKit/tags).

Current version: **1.0.0**

