import SwiftUI

struct StatusHeaderView: View {
    let isLocked: Bool
    let currentInputName: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(isLocked ? Color.green : Color.orange)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(isLocked ? "Input Locked" : "Using \(currentInputName)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isLocked ? Color(red: 0.15, green: 0.55, blue: 0.25) : Color.orange)

                Text(isLocked ? "Input is locked to preferred device." : "Input lock is off.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isLocked
                      ? Color.green.opacity(0.1)
                      : Color.orange.opacity(0.1))
        )
    }
}
