import SwiftUI

struct OnboardingCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(Color(hex: "FDFBF6"))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(hex: "5C3D2E").opacity(0.10), lineWidth: 1)
            )
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
}

struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: "E8E1D7"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
            )
            .cornerRadius(12)
            .foregroundColor(Color(hex: "3C2A1E"))
            .font(.system(size: 16, design: .rounded))
    }
}

struct OnboardingPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: "8B9A7E").opacity(configuration.isPressed ? 0.85 : 1.0))
            .cornerRadius(12)
    }
}

struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(Color(hex: "5C3D2E"))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: "FDFBF6").opacity(configuration.isPressed ? 0.85 : 1.0))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
            )
            .cornerRadius(12)
    }
}

struct OnboardingCenteredScrollView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 24)
                    content
                    Spacer(minLength: 24)
                }
                .frame(minHeight: proxy.size.height)
            }
        }
    }
}

struct OnboardingOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(hex: "5C3D2E"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color(hex: "8B9A7E") : Color(hex: "E8E1D7"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "5C3D2E").opacity(isSelected ? 0.0 : 0.10), lineWidth: 1)
                )
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingCheckRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .white : Color(hex: "5C3D2E").opacity(0.55))
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color(hex: "5C3D2E"))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(hex: "8B9A7E") : Color(hex: "E8E1D7"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "5C3D2E").opacity(isSelected ? 0.0 : 0.10), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
