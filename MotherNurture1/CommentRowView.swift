import SwiftUI
import FirebaseFirestore

struct CommentRowView: View {
    let comment: Comment
    let canDelete: Bool
    let canBlock: Bool
    let onDelete: () -> Void
    let onBlock: (() -> Void)?
    let onReport: (() -> Void)?
    
    @State private var showDeleteConfirmation = false
    @State private var showReportConfirmation = false
    
    init(comment: Comment, canDelete: Bool, canBlock: Bool, onDelete: @escaping () -> Void, onBlock: (() -> Void)?, onReport: (() -> Void)? = nil) {
        self.comment = comment
        self.canDelete = canDelete
        self.canBlock = canBlock
        self.onDelete = onDelete
        self.onBlock = onBlock
        self.onReport = onReport
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Author avatar
            Circle()
                .fill(Color(hex: "8B9A7E").opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(comment.authorName.prefix(1).uppercased())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "5C3D2E"))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.authorName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    
                    Text("•")
                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.3))
                    
                    Text(timeAgo(comment.createdAt.dateValue()))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.5))

                    Spacer()

                    if canDelete {
                        Button(action: { showDeleteConfirmation = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(Color(hex: "E57373"))
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    } else if canBlock {
                        Menu {
                            if let onBlock = onBlock {
                                Button(role: .destructive, action: onBlock) {
                                    Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                                }
                            }
                            Button(role: .destructive, action: { showReportConfirmation = true }) {
                                Label("Report Comment", systemImage: "flag")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.5))
                                .font(.system(size: 14))
                        }
                    }
                }

                Text(comment.content)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
        .confirmationDialog("Delete Comment", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this comment?")
        }
        .confirmationDialog("Report Comment", isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button("Report", role: .destructive) {
                onReport?()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Report this comment as inappropriate or harmful?")
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: now)
        
        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1w" : "\(weeks)w"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1d" : "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1h" : "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1m" : "\(minutes)m"
        } else {
            return "now"
        }
    }
}
