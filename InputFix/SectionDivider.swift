import SwiftUI

/// Lightweight intra-card divider.
struct SectionDivider: View {
    var body: some View {
        Divider()
            .opacity(0.5)
            .padding(.vertical, 4)
    }
}
