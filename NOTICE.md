# Third-Party Notices and Attributions

## SafariConverterLib

SafariContentBlockerKit includes modified code from the **SafariConverterLib** project.

- **Original Project**: [AdguardTeam/SafariConverterLib](https://github.com/AdguardTeam/SafariConverterLib)
- **Original License**: **GPL-3.0** (GNU General Public License v3.0)
- **Copyright**: © 2018-2024 AdGuard Team
- **Modifications by**: Artur Kulik (2025)

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

- **BackgroundTaskService.swift** - Original work by Artur Kulik
- **ContentBlockerService.swift** - Original work by Artur Kulik (uses AdGuard converter)
- **RuleSetType.swift** - Original work by Artur Kulik  
- **ContentBlockerConfiguration.swift** - Original work by Artur Kulik
- **ContentBlockerError.swift** - Original work by Artur Kulik
- **SafariContentBlockerKit.swift** - Original work by Artur Kulik

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

## Acknowledgments

Special thanks to the AdGuard Team for their excellent work on SafariConverterLib, 
which made this iOS adaptation possible.