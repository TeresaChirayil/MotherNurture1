import SwiftUI

struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    @ViewBuilder let content: () -> Content

    init(spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        FlexibleView(spacing: spacing, alignment: alignment, content: content)
    }
}

private struct FlexibleView<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    @ViewBuilder let content: () -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
            content()
                .fixedSize() // ensure each child takes its intrinsic size
                .alignmentGuide(.leading, computeValue: { d in
                    if abs(width - d.width) > geometry.size.width {
                        width = 0
                        height -= (d.height + spacing)
                    }
                    let result = width
                    if d.width <= geometry.size.width {
                        width -= (d.width + spacing)
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: { d in
                    let result = height
                    if let last = d[.bottom] as CGFloat? {
                        DispatchQueue.main.async {
                            self.totalHeight = max(self.totalHeight, abs(height) + last)
                        }
                    }
                    return result
                })
        }
    }
}
