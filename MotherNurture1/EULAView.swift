//
//  EULAView.swift
//  MotherNurture1
//
//  End User License Agreement (EULA) View
//

import SwiftUI

struct EULAView: View {
    @Binding var isPresented: Bool
    @Binding var hasAccepted: Bool
    @State private var hasScrolledToBottom = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Terms of Service")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("Last Updated: \(formatDate(Date()))")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color(hex: "8B9A7E"))
                            }
                            .padding(.bottom, 10)
                            
                            // Introduction
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Welcome to MotherNurture")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("By using MotherNurture, you agree to be bound by these Terms of Service. Please read them carefully.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.bottom, 8)
                            
                            // Zero Tolerance Policy
                            VStack(alignment: .leading, spacing: 12) {
                                Text("1. Zero Tolerance for Objectionable Content and Abusive Users")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("MotherNurture maintains a strict zero-tolerance policy for objectionable content and abusive behavior. This includes, but is not limited to:")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    BulletPoint(text: "Harassment, bullying, or intimidation of any kind")
                                    BulletPoint(text: "Hate speech, discrimination, or offensive language")
                                    BulletPoint(text: "Spam, scams, or fraudulent content")
                                    BulletPoint(text: "Sexually explicit or inappropriate material")
                                    BulletPoint(text: "Violence, threats, or encouragement of harm")
                                    BulletPoint(text: "Personal attacks or defamatory statements")
                                    BulletPoint(text: "Sharing private information without consent")
                                }
                                .padding(.leading, 8)
                                
                                Text("Users who violate these terms will be subject to immediate account suspension or termination. We reserve the right to remove any content that violates these standards without prior notice.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .padding(.top, 4)
                            }
                            .padding(.bottom, 8)
                  
                            // User Responsibilities
                            VStack(alignment: .leading, spacing: 12) {
                                Text("2. User Responsibilities")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    BulletPoint(text: "You are responsible for all content you post")
                                    BulletPoint(text: "You must respect the privacy and dignity of other users")
                                    BulletPoint(text: "You agree to use the service only for lawful purposes")
                                    BulletPoint(text: "You will not impersonate others or provide false information")
                                    BulletPoint(text: "You will report abusive behavior or objectionable content")
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.bottom, 8)
                            
                            // Reporting and Moderation
                            VStack(alignment: .leading, spacing: 12) {
                                Text("3. Reporting and Moderation")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("If you encounter objectionable content or abusive users, please use the reporting features available in the app. We take all reports seriously and will investigate promptly. You can also block users to prevent them from interacting with you.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.bottom, 8)
                            
                            // Privacy and Data
                            VStack(alignment: .leading, spacing: 12) {
                                Text("4. Privacy and Data")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("Your privacy is important to us. We use anonymous authentication to protect your identity while allowing you to participate in the community. Your personal information is handled in accordance with our Privacy Policy.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.bottom, 8)
                            
                            // Account Termination
                            VStack(alignment: .leading, spacing: 12) {
                                Text("5. Account Termination")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("We reserve the right to suspend or terminate accounts that violate these terms. We may also remove content at our discretion to maintain a safe and welcoming community environment.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.bottom, 8)
                            
                            // Limitation of Liability
                            VStack(alignment: .leading, spacing: 12) {
                                Text("6. Limitation of Liability")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("MotherNurture is provided \"as is\" without warranties of any kind. We are not liable for any damages arising from your use of the service, including but not limited to interactions with other users.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.bottom, 8)
                            
                            // Changes to Terms
                            VStack(alignment: .leading, spacing: 12) {
                                Text("7. Changes to Terms")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("We may update these Terms of Service from time to time. Continued use of the service after changes constitutes acceptance of the updated terms.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.bottom, 8)
                            
                            // Contact
                            VStack(alignment: .leading, spacing: 12) {
                                Text("8. Contact")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("If you have questions about these terms, please contact us through the app's support features.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.bottom, 20)
                            
                            // Acceptance Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("By tapping \"I Agree\" below, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service, including our zero-tolerance policy for objectionable content and abusive users.")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .padding(.top, 20)
                            }
                            .padding(.bottom, 100) // Extra padding for scroll detection
                        }
                        .padding(20)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                            }
                        )
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            // Detect if scrolled to bottom (with some tolerance)
                            if value < -500 {
                                hasScrolledToBottom = true
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    
                    // Accept Button (Fixed at bottom)
                    VStack {
                        Button(action: {
                            hasAccepted = true
                            isPresented = false
                        }) {
                            Text("I Agree")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(hasScrolledToBottom ? Color(hex: "8B9A7E") : Color(hex: "9BA897").opacity(0.5))
                                .cornerRadius(12)
                        }
                        .disabled(!hasScrolledToBottom)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .padding(.top, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "F8F5EE").opacity(0), Color(hex: "F8F5EE")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 100)
                            .offset(y: -100)
                        )
                    }
                }
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Bullet Point View
private struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "8B9A7E"))
            Text(text)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
        }
    }
}

// MARK: - Scroll Offset Preference Key
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    EULAView(isPresented: .constant(true), hasAccepted: .constant(false))
}




