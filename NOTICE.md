# Third-Party Notices and Attributions

## SafariConverterLib

SafariContentBlockerKit includes modified code from the **SafariConverterLib** project.

- **Original Project**: [AdguardTeam/SafariConverterLib](https://github.com/AdguardTeam/SafariConverterLib)
- **Original License**: **GPL-3.0** (GNU General Public License v3.0)
- **Copyright**: © 2018-2024 AdGuard Team
- **Modifications by**: SafariContentBlockerKit Contributors (2025)

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

The original SafariConverterLib code is licensed under the **GPL-3.0 License**.

As per GPL-3.0 requirements, all modifications and derivative works must also be 
licensed under GPL-3.0. Therefore, SafariContentBlockerKit is licensed under GPL-3.0.

For the complete license text, see the [LICENSE](LICENSE) file or visit:
https://www.gnu.org/licenses/gpl-3.0.html

---

## SafariContentBlockerKit Original Components

The following components are original work created for SafariContentBlockerKit:

- **BackgroundTaskService.swift** - Original work for iOS adaptation
- **ContentBlockerService.swift** - Original work for iOS adaptation (uses AdGuard converter)
- **RuleSetType.swift** - Original work for iOS adaptation
- **ContentBlockerConfiguration.swift** - Original work for iOS adaptation
- **ContentBlockerError.swift** - Original work for iOS adaptation
- **SafariContentBlockerKit.swift** - Original work for iOS adaptation

These components are also licensed under the **GPL-3.0 License** to comply with 
the copyleft requirements of the original SafariConverterLib code.

---

## Source Code Availability

In compliance with GPL-3.0, the complete source code of SafariContentBlockerKit 
is available at:

https://github.com/Satin91/SafariContentBlockerKit

You are free to use, modify, and distribute this software under the terms of the 
GPL-3.0 license.

---

## PunycodeSwift

SafariContentBlockerKit uses **PunycodeSwift** for internationalized domain name (IDN) support.

- **Original Project**: [gumob/PunycodeSwift](https://github.com/gumob/PunycodeSwift)
- **License**: **MIT License**
- **Copyright**: © 2017-2024 gumob
- **Version**: 2.1.0+

### MIT License

```
MIT License

Copyright (c) 2017-2024 gumob

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

### License Compatibility

The MIT License is compatible with GPL-3.0. PunycodeSwift is used as a library 
dependency and is not modified or incorporated into the SafariContentBlockerKit 
source code directly. The GPL-3.0 license applies only to SafariContentBlockerKit 
code, while PunycodeSwift remains under its original MIT License.

---

## Acknowledgments

Special thanks to:
- The **AdGuard Team** for their excellent work on SafariConverterLib, which made this iOS adaptation possible
- **gumob** for PunycodeSwift, providing robust internationalized domain name support