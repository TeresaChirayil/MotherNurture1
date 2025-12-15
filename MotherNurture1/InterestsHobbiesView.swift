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
                    ScrollView {
                        // Main Content
                        VStack(alignment: .leading, spacing: 20) {
                            // Question
                            Text("What would you enjoy doing in your free time?")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                            
                            // Instruction
                            Text("More than one option is possible.")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                            
                            // Interest Options
                            VStack(spacing: 16) {
                                ForEach(interests, id: \.self) { interest in
                                    Button(action: {
                                        if interest == "Anything!" {
                                            withAnimation { showingCustomInterestField.toggle() }
                                            return
                                        }
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else {
                                            selectedInterests.insert(interest)
                                        }
                                    }) {
                                        Text(interest)
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                            .foregroundColor(selectedInterests.contains(interest) ? .white : Color(hex: "5C3D2E"))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(selectedInterests.contains(interest) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                if showingCustomInterestField {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            TextField("Type your interest...", text: $customInterestText)
                                                .padding(12)
                                                .background(Color(hex: "D4C4B0"))
                                                .cornerRadius(8)
                                                .foregroundColor(Color(hex: "5C3D2E"))
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
                                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 10)
                                                    .background(Color(hex: "8B9A7E"))
                                                    .cornerRadius(8)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        // Show chips for custom interests with an X to remove
                                        InterestsFlowLayout(spacing: 8) {
                                            ForEach(Array(selectedInterests).filter { !interests.contains($0) }, id: \.self) { custom in
                                                HStack(spacing: 6) {
                                                    Text(custom)
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundColor(Color(hex: "5C3D2E"))
                                                        .padding(.leading, 12)
                                                    Button(action: {
                                                        selectedInterests.remove(custom)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                                                            .font(.system(size: 14, weight: .bold))
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                                .padding(.vertical, 8)
                                                .background(Color(hex: "D4C4B0"))
                                                .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    
                    // Bottom Navigation
                    HStack {
                        // Previous Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("Previous")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Next Button
                        Button(action: {
                            // Save interests
                            userDataManager.profile.interests = Array(selectedInterests)
                            
                            navigateToConnectionPreference = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Next")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
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
