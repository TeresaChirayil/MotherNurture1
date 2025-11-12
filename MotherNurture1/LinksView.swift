//
//  LinksView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct LinksView: View {
    @Environment(\.dismiss) var dismiss
    @State private var profiles: [Profile] = [
        Profile(name: "Sarah", age: 28, bio: "Mom of two beautiful kids. Love hiking and coffee.", image: "person.circle.fill"),
        Profile(name: "Jessica", age: 32, bio: "Single mom, working professional. Enjoy reading and cooking.", image: "person.circle.fill"),
        Profile(name: "Emily", age: 30, bio: "Mom of one. Passionate about fitness and healthy living.", image: "person.circle.fill"),
        Profile(name: "Amanda", age: 35, bio: "Mother of three. Love traveling and photography.", image: "person.circle.fill")
    ]
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showChannels = false
    @State private var currentTab: TabDestination = .links
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    // Profile Card Area
                    ZStack {
                        if currentIndex < profiles.count {
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
                                                removeCurrentProfile()
                                            } else {
                                                withAnimation {
                                                    dragOffset = .zero
                                                }
                                            }
                                        }
                                )
                                .animation(.spring(), value: dragOffset)
                        } else {
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
                    .padding(.bottom, 10)
                    
                    // Action Buttons
                    HStack(spacing: 40) {
                        Button(action: swipeLeft) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "F8F5EE"))
                                    .frame(width: 60, height: 60)
                                    .overlay(Circle().stroke(Color(hex: "5C3D2E"), lineWidth: 2))
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .font(.system(size: 24, weight: .bold))
                            }
                        }
                        
                        Button(action: swipeRight) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "8B9A7E"))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .font(.system(size: 24))
                            }
                        }
                    }
                    .padding(.vertical, 25)
                    
                    // Space so nav bar doesn’t overlap
                    Spacer(minLength: 0)
                        .frame(height: 80)
                }
                // Bottom Nav Bar (lowered)
                .overlay(alignment: .bottom) {
                    BottomNavBar(currentTab: $currentTab)
                        .padding(.bottom, 5)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // MARK: - Bottom Navigation Bar
//    private var bottomNavBar: some View {
//        HStack {
//            Spacer()
//            
//            Button(action: {
//                showChannels = true
//            }) {
//                Image(systemName: "bubble.left.and.bubble.right")
//                    .font(.system(size: 24))
//                    .foregroundColor(Color(hex: "5C3D2E"))
//            }
//            .buttonStyle(PlainButtonStyle())
//            
//            Spacer()
//            
//            // Highlight current tab
//            Image(systemName: "link")
//                .font(.system(size: 24))
//                .foregroundColor(Color(hex: "8B9A7E"))
//            
//            Spacer()
//            
//            Image(systemName: "book")
//                .font(.system(size: 24))
//                .foregroundColor(Color(hex: "5C3D2E"))
//            
//            Spacer()
//            
//            Image(systemName: "mappin.circle")
//                .font(.system(size: 24))
//                .foregroundColor(Color(hex: "5C3D2E"))
//            
//            Spacer()
//            
//            Image(systemName: "person")
//                .font(.system(size: 24))
//                .foregroundColor(Color(hex: "5C3D2E"))
//            
//            Spacer()
//        }
//        .padding(.vertical, 16)
//        .background(Color(hex: "F8F5EE"))
//        //.cornerRadius(20)
//        .shadow(color: .black.opacity(0.15), radius: 5, y: -3)
//        //.padding(.horizontal, 20)
//        .navigationDestination(isPresented: $showChannels) {
//            ChannelsView()
//        }
//    }
    
    // MARK: - Swipe Logic
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

// MARK: - Profile Card
struct ProfileCard: View {
    let profile: Profile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "8B9A7E"))
                    .frame(height: 500)
                
                Image(systemName: profile.image)
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .font(.system(size: 120))
            }
            
            VStack(alignment: .leading, spacing: 1) {
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
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Profile Model
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
