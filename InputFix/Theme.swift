import SwiftUI
import AppKit

enum Theme {
    // MARK: - Colors

    static let lockedAccent = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
            ? NSColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1)
            : NSColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1)
    })
    static let unlockedAccent = Color(red: 0.55, green: 0.55, blue: 0.6)

    // MARK: - Typography

    static let titleFont = Font.system(size: 13, weight: .semibold)
    static let bodyFont = Font.system(size: 12)
    static let captionFont = Font.system(size: 11)

    // MARK: - Layout

    static let popoverWidth: CGFloat = 320
    static let outerPadding: CGFloat = 16
    static let sectionGap: CGFloat = 10
    static let rowSpacing: CGFloat = 8
    static let iconWidth: CGFloat = 20

    // MARK: - Helpers

    static func accent(locked: Bool) -> Color {
        locked ? lockedAccent : unlockedAccent
    }
}
