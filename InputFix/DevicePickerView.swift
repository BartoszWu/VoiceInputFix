import SwiftUI

/// Generic device picker used by both the audio and Bluetooth cards.
/// Identifies items by a String key (audio UID / Bluetooth MAC address).
struct DevicePickerView<Item: Identifiable>: View {
    let items: [Item]
    let name: KeyPath<Item, String>
    let itemID: KeyPath<Item, String>
    @Binding var selectedID: String?
    /// When true, only the selected row is shown until the user expands the list.
    var collapsible: Bool = false

    @State private var isExpanded = false

    /// Nothing selected yet means the user still has to pick — show everything.
    private var expanded: Bool { !collapsible || isExpanded || selectedID == nil }

    private var visibleItems: [Item] {
        expanded ? items : items.filter { $0[keyPath: itemID] == selectedID }
    }

    private var hiddenCount: Int { items.count - visibleItems.count }

    var body: some View {
        VStack(spacing: 2) {
            if items.isEmpty {
                Text("No devices found")
                    .font(Theme.captionFont)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
            }
            ForEach(visibleItems) { item in
                DevicePickerRow(
                    name: item[keyPath: name],
                    isSelected: item[keyPath: itemID] == selectedID
                ) {
                    selectedID = item[keyPath: itemID]
                    if collapsible { isExpanded = false }
                }
            }
            if collapsible && items.count > 1 && selectedID != nil {
                ExpandRow(
                    isExpanded: isExpanded,
                    label: isExpanded ? "Show Less" : "Show All \(items.count) Devices"
                ) {
                    isExpanded.toggle()
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: expanded)
    }
}

private struct ExpandRow: View {
    let isExpanded: Bool
    let label: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: Theme.iconWidth, alignment: .center)
                Text(label)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Theme.hoverHighlight : .clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct DevicePickerRow: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(isSelected ? Theme.lockedAccent : Color.secondary.opacity(0.4))
                    .frame(width: 16, alignment: .center)

                Text(name)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(isHovered ? Theme.hoverHighlight : .clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
