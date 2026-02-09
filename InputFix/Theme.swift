import SwiftUI
import AppKit

enum Theme {
    // MARK: - Colors

    static let lockedAccent = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
            ? NSColor(red: 0.25, green: 0.9, blue: 0.45, alpha: 1)
            : NSColor(red: 0.12, green: 0.47, blue: 0.235, alpha: 1)
    })
    static let unlockedAccent = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
            ? NSColor(red: 1.0, green: 0.76, blue: 0.28, alpha: 1)
            : NSColor(red: 0.73, green: 0.39, blue: 0.11, alpha: 1)
    })

    static let cardBackground = Color.primary.opacity(0.04)
    static let cardBorder = Color.primary.opacity(0.08)
    static let hoverHighlight = Color.primary.opacity(0.06)

    // MARK: - Typography

    static let titleFont = Font.system(size: 14, weight: .semibold)
    static let bodyFont = Font.system(size: 12)
    static let captionFont = Font.system(size: 11)
    static let sectionLabel = Font.system(size: 10, weight: .medium).uppercaseSmallCaps()
    static let buttonFont = Font.system(size: 12, weight: .semibold)

    // MARK: - Layout

    static let popoverWidth: CGFloat = 320
    static let outerPadding: CGFloat = 16
    static let sectionGap: CGFloat = 10
    static let rowSpacing: CGFloat = 8
    static let iconWidth: CGFloat = 20
    static let cardCornerRadius: CGFloat = 10
    static let cardInnerPadding: CGFloat = 12
    static let cardSpacing: CGFloat = 10

    // MARK: - Helpers

    static func accent(locked: Bool) -> Color {
        locked ? lockedAccent : unlockedAccent
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.cardInnerPadding)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .strokeBorder(Theme.cardBorder, lineWidth: 0.5)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
