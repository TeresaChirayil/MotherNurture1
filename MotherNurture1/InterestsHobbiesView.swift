//
//  InterestsHobbiesView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct InterestsHobbiesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedInterests: Set<String> = []
    @State private var navigateToConnectionPreference = false
    
    @State private var showingCustomInterestField: Bool = false
    @State private var customInterestText: String = ""
    
    let interests = [
        "Reading",
        "Cooking",
        "Arts & Crafts",
        "Traveling",
        "Exercising",
        "Gardening",
        "Anything!"
    ]
    
    var body: some View {
        ZStack {
            // Background color (beige to match other screens)
            Color(hex: "F8F5EE")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingCenteredScrollView {
                    VStack(spacing: 16) {
                        OnboardingCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Step 5")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("What would you enjoy doing in your free time?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                Text("More than one option is possible.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.75))

                                VStack(spacing: 12) {
                                    ForEach(interests, id: \.self) { interest in
                                        if interest == "Anything!" {
                                            VStack(spacing: 10) {
                                                OnboardingOptionButton(
                                                    title: interest,
                                                    isSelected: showingCustomInterestField,
                                                    action: {
                                                        withAnimation(.easeInOut(duration: 0.2)) {
                                                            showingCustomInterestField.toggle()
                                                        }
                                                    }
                                                )

                                                if showingCustomInterestField {
                                                    VStack(alignment: .leading, spacing: 12) {
                                                        HStack(spacing: 10) {
                                                            TextField("Type your interest...", text: $customInterestText)
                                                                .padding(.horizontal, 14)
                                                                .padding(.vertical, 12)
                                                                .background(Color(hex: "8B9A7E"))
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 12)
                                                                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                                                                )
                                                                .cornerRadius(12)
                                                                .foregroundColor(.white)
                                                                .tint(.white)
                                                                .font(.system(size: 16, design: .rounded))
                                                                .textInputAutocapitalization(.words)
                                                                .disableAutocorrection(true)

                                                            Button(action: {
                                                                let trimmed = customInterestText.trimmingCharacters(in: .whitespacesAndNewlines)
                                                                guard !trimmed.isEmpty else { return }
                                                                selectedInterests.insert(trimmed)
                                                                customInterestText = ""
                                                            }) {
                                                                Text("Add")
                                                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                                    .foregroundColor(.white)
                                                                    .padding(.horizontal, 14)
                                                                    .padding(.vertical, 12)
                                                                    .background(Color(hex: "5C3D2E"))
                                                                    .cornerRadius(12)
                                                            }
                                                            .buttonStyle(.plain)
                                                        }

                                                        VStack(spacing: 10) {
                                                            ForEach(Array(selectedInterests).filter { !interests.contains($0) }, id: \.self) { custom in
                                                                HStack(spacing: 10) {
                                                                    Text(custom)
                                                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                                        .foregroundColor(.white)
                                                                    Spacer()
                                                                    Button {
                                                                        selectedInterests.remove(custom)
                                                                    } label: {
                                                                        Image(systemName: "xmark.circle.fill")
                                                                            .foregroundColor(.white.opacity(0.85))
                                                                            .font(.system(size: 20, weight: .bold))
                                                                    }
                                                                    .buttonStyle(.plain)
                                                                }
                                                                .padding(.horizontal, 16)
                                                                .padding(.vertical, 14)
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color(hex: "8B9A7E"))
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 12)
                                                                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                                                                )
                                                                .cornerRadius(12)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            OnboardingCheckRow(
                                                title: interest,
                                                isSelected: selectedInterests.contains(interest),
                                                action: {
                                                    if selectedInterests.contains(interest) {
                                                        selectedInterests.remove(interest)
                                                    } else {
                                                        selectedInterests.insert(interest)
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }

                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                    }
                    .buttonStyle(OnboardingSecondaryButtonStyle())

                    Button(action: {
                        // Save interests
                        userDataManager.profile.interests = Array(selectedInterests)

                        navigateToConnectionPreference = true
                    }) {
                        HStack(spacing: 6) {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(OnboardingPrimaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .navigationDestination(isPresented: $navigateToConnectionPreference) {
                ConnectionPreferenceView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    InterestsHobbiesView()
}

struct InterestsFlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: bounds.minX + x, y: bounds.minY + y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
