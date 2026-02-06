import SwiftUI

enum Theme {
    // MARK: - Colors

    static let lockedAccent = Color.green
    static let unlockedAccent = Color.orange

    static let groupBackground = Color(.quaternarySystemFill)

    // MARK: - Typography

    static let titleFont = Font.system(size: 13, weight: .semibold)
    static let bodyFont = Font.system(size: 12)
    static let captionFont = Font.system(size: 11)

    // MARK: - Layout

    static let outerPadding: CGFloat = 16
    static let groupPadding: CGFloat = 10
    static let sectionGap: CGFloat = 12
    static let rowSpacing: CGFloat = 8
    static let iconWidth: CGFloat = 20
    static let groupRadius: CGFloat = 8

    // MARK: - Helpers

    static func accent(locked: Bool) -> Color {
        locked ? lockedAccent : unlockedAccent
    }
}
