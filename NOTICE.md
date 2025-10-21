# Third-Party Notices and Attributions

## SafariConverterLib

SafariContentBlockerKit includes modified code from the **SafariConverterLib** project.

- **Original Project**: [AdguardTeam/SafariConverterLib](https://github.com/AdguardTeam/SafariConverterLib)
- **Original License**: MIT License
- **Copyright**: © 2018-2024 AdGuard Team
- **Modifications by**: Артур Кулик (2025)

### Modifications Made:

The following modifications were made to adapt the code for iOS:

1. **Platform Adaptation**: 
   - Adapted from macOS to iOS
   - Modified imports and dependencies for iOS compatibility
   - Added UIKit integration for iOS-specific features

2. **API Changes**:
   - Updated for iOS-specific WKWebView integration
   - Modified for iOS Safari Content Blocker extensions
   - Created universal configuration system

3. **File Changes**:
   - All files under `Sources/SafariContentBlockerKit/ContentBlocker/` - iOS compatibility updates
   - Added `ContentBlockerService.swift` - Universal service layer
   - Added `RuleSetType.swift` - Flexible rule set management
   - Added `ContentBlockerConfiguration.swift` - Configuration system
   - Added `BackgroundTaskService.swift` - iOS background task support

### Original License

The original SafariConverterLib code is licensed under the MIT License:

```
MIT License

Copyright (c) 2018-2024 AdGuard Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## SafariContentBlockerKit Original Components

The following components are original work created for SafariContentBlockerKit:

- **BackgroundTaskService.swift** - Original work by Артур Кулик
- **ContentBlockerService.swift** - Original work by Артур Кулик (uses AdGuard converter)
- **RuleSetType.swift** - Original work by Артур Кулик
- **ContentBlockerConfiguration.swift** - Original work by Артур Кулик
- **ContentBlockerError.swift** - Original work by Артур Кулик
- **SafariContentBlockerKit.swift** - Original work by Артур Кулик

These components are also licensed under the MIT License (see LICENSE file).

---

## Acknowledgments

Special thanks to the AdGuard Team for their excellent work on SafariConverterLib, which made this iOS adaptation possible.

