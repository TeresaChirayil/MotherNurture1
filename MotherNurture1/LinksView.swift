//
//  LinksView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct LinksView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var profiles: [Profile] = [
        Profile(name: "Sarah", age: 28, bio: "Mom of two beautiful kids. Love hiking and coffee.", image: "person.circle.fill"),
        Profile(name: "Jessica", age: 32, bio: "Single mom, working professional. Enjoy reading and cooking.", image: "person.circle.fill"),
        Profile(name: "Emily", age: 30, bio: "Mom of one. Passionate about fitness and healthy living.", image: "person.circle.fill"),
        Profile(name: "Amanda", age: 35, bio: "Mother of three. Love traveling and photography.", image: "person.circle.fill")
    ]
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
                        // Close button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Title
                        Text("Links")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Spacer()
                        
                        // Confirm button
                        Button(action: {
                            // Handle confirm action
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(hex: "8B9A7E")) // Olive green background
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .padding(.leading, 12)
                        
                        TextField("Search", text: $searchText)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(Color(hex: "8B9A7E")) // Olive green background
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Main Content - Card Stack with Action Buttons
                    ZStack(alignment: .bottom) {
                        // Card Stack
                        ZStack {
                            if currentIndex < profiles.count {
                                // Profile Card
                                ProfileCard(profile: profiles[currentIndex])
                                    .offset(x: dragOffset.width, y: dragOffset.height)
                                    .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                dragOffset = value.translation
                                            }
                                            .onEnded { value in
                                                if abs(value.translation.width) > 150 {
                                                    // Swipe away
                                                    removeCurrentProfile()
                                                } else {
                                                    // Snap back
                                                    withAnimation {
                                                        dragOffset = .zero
                                                    }
                                                }
                                            }
                                    )
                            } else {
                                // No more profiles
                                VStack(spacing: 16) {
                                    Text("No more profiles")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                    
                                    Text("Check back later for new matches")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(40)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                        
                        // Action Buttons - Positioned higher up
                        HStack(spacing: 40) {
                            // Pass Button
                            Button(action: {
                                swipeLeft()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "F8F5EE"))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: "5C3D2E"), lineWidth: 2)
                                        )
                                    
                                    Image(systemName: "xmark")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 24, weight: .bold))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Like Button
                            Button(action: {
                                swipeRight()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "8B9A7E"))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 24))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.bottom, 80)
                    }
                    
                    // Bottom Navigation Bar
                    HStack {
                        Spacer()
                        
                        // Speech Bubble icon
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Spacer()
                        
                        // Chain Link icon
                        Image(systemName: "link")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Spacer()
                        
                        // Open Book icon
                        Image(systemName: "book")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Spacer()
                        
                        // Map Pin icon
                        Image(systemName: "mappin.circle")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Spacer()
                        
                        // Person Outline icon
                        Image(systemName: "person")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .background(Color(hex: "F8F5EE"))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func swipeLeft() {
        withAnimation {
            dragOffset = CGSize(width: -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeCurrentProfile()
        }
    }
    
    private func swipeRight() {
        withAnimation {
            dragOffset = CGSize(width: 500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeCurrentProfile()
        }
    }
    
    private func removeCurrentProfile() {
        if currentIndex < profiles.count {
            profiles.remove(at: currentIndex)
            dragOffset = .zero
        }
    }
}

struct ProfileCard: View {
    let profile: Profile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile Image
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "8B9A7E"))
                    .frame(height: 500)
                
                Image(systemName: profile.image)
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .font(.system(size: 120))
            }
            
            // Profile Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(profile.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    
                    Text("\(profile.age)")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                }
                
                Text(profile.bio)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .lineLimit(3)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F8F5EE"))
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct Profile: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let bio: String
    let image: String
}

#Preview {
    LinksView()
}
