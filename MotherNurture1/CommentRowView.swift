import SwiftUI
import FirebaseFirestore

struct CommentRowView: View {
    let comment: Comment
    let canDelete: Bool
    let canBlock: Bool
    let onDelete: () -> Void
    let onBlock: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(comment.authorName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))

                Spacer()

                Text(formatDate(comment.createdAt.dateValue()))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(hex: "8B9A7E"))

                if canDelete {
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.leading, 6)
                    }
                    .buttonStyle(.plain)
                } else if canBlock, let onBlock = onBlock {
                    Menu {
                        Button(role: .destructive, action: onBlock) {
                            Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.leading, 6)
                    }
                }
            }

            Text(comment.content)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
