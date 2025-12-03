////
////  LinksView.swift
////  MotherNurture1
////
////  Created by 40 GO Participant on 11/4/25.
////
//
//import SwiftUI
//
//struct LinksView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var profiles: [Profile] = [
//        Profile(name: "Sarah", age: 28, bio: "Mom of two beautiful kids. Love hiking and coffee.", image: "person.circle.fill"),
//        Profile(name: "Jessica", age: 32, bio: "Single mom, working professional. Enjoy reading and cooking.", image: "person.circle.fill"),
//        Profile(name: "Emily", age: 30, bio: "Mom of one. Passionate about fitness and healthy living.", image: "person.circle.fill"),
//        Profile(name: "Amanda", age: 35, bio: "Mother of three. Love traveling and photography.", image: "person.circle.fill")
//    ]
//    @State private var currentIndex = 0
//    @State private var dragOffset: CGSize = .zero
//    @State private var showChannels = false
//    @State private var currentTab: TabDestination = .links
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(hex: "F8F5EE")
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    Spacer(minLength: 0)
//                    
//                    // Profile Card Area
//                    ZStack {
//                        if currentIndex < profiles.count {
//                            ProfileCard(profile: profiles[currentIndex])
//                                .offset(x: dragOffset.width, y: dragOffset.height)
//                                .rotationEffect(.degrees(Double(dragOffset.width / 20)))
//                                .gesture(
//                                    DragGesture()
//                                        .onChanged { value in
//                                            dragOffset = value.translation
//                                        }
//                                        .onEnded { value in
//                                            if abs(value.translation.width) > 150 {
//                                                removeCurrentProfile()
//                                            } else {
//                                                withAnimation {
//                                                    dragOffset = .zero
//                                                }
//                                            }
//                                        }
//                                )
//                                .animation(.spring(), value: dragOffset)
//                        } else {
//                            VStack(spacing: 16) {
//                                Text("No more profiles")
//                                    .font(.system(size: 20, weight: .bold, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                Text("Check back later for new matches")
//                                    .font(.system(size: 16, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                    .multilineTextAlignment(.center)
//                            }
//                            .padding(40)
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                    .padding(.bottom, 20)
//                    
//                    Spacer()
//                    
//                    // Action Buttons - Positioned lower
//                    HStack(spacing: 40) {
//                        Button(action: swipeLeft) {
//                            ZStack {
//                                Circle()
//                                    .fill(Color(hex: "F8F5EE"))
//                                    .frame(width: 60, height: 60)
//                                    .overlay(Circle().stroke(Color(hex: "5C3D2E"), lineWidth: 2))
//                                
//                                Image(systemName: "xmark")
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                    .font(.system(size: 24, weight: .bold))
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        Button(action: swipeRight) {
//                            ZStack {
//                                Circle()
//                                    .fill(Color(hex: "8B9A7E"))
//                                    .frame(width: 60, height: 60)
//                                
//                                Image(systemName: "heart.fill")
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                    .font(.system(size: 24))
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                    .padding(.bottom, 100)
//                }
//                // Bottom Nav Bar (lowered)
//                .overlay(alignment: .bottom) {
//                    BottomNavBar(currentTab: $currentTab)
//                        .padding(.bottom, 5)
//                }
//            }
//            .toolbar(.hidden, for: .navigationBar)
//        }
//    }
//    
//    // MARK: - Bottom Navigation Bar
////    private var bottomNavBar: some View {
////        HStack {
////            Spacer()
////            
////            Button(action: {
////                showChannels = true
////            }) {
////                Image(systemName: "bubble.left.and.bubble.right")
////                    .font(.system(size: 24))
////                    .foregroundColor(Color(hex: "5C3D2E"))
////            }
////            .buttonStyle(PlainButtonStyle())
////            
////            Spacer()
////            
////            // Highlight current tab
////            Image(systemName: "link")
////                .font(.system(size: 24))
////                .foregroundColor(Color(hex: "8B9A7E"))
////            
////            Spacer()
////            
////            Image(systemName: "book")
////                .font(.system(size: 24))
////                .foregroundColor(Color(hex: "5C3D2E"))
////            
////            Spacer()
////            
////            Image(systemName: "mappin.circle")
////                .font(.system(size: 24))
////                .foregroundColor(Color(hex: "5C3D2E"))
////            
////            Spacer()
////            
////            Image(systemName: "person")
////                .font(.system(size: 24))
////                .foregroundColor(Color(hex: "5C3D2E"))
////            
////            Spacer()
////        }
////        .padding(.vertical, 16)
////        .background(Color(hex: "F8F5EE"))
////        //.cornerRadius(20)
////        .shadow(color: .black.opacity(0.15), radius: 5, y: -3)
////        //.padding(.horizontal, 20)
////        .navigationDestination(isPresented: $showChannels) {
////            ChannelsView()
////        }
////    }
//    
//    // MARK: - Swipe Logic
//    private func swipeLeft() {
//        withAnimation {
//            dragOffset = CGSize(width: -500, height: 0)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            removeCurrentProfile()
//        }
//    }
//    
//    private func swipeRight() {
//        withAnimation {
//            dragOffset = CGSize(width: 500, height: 0)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            removeCurrentProfile()
//        }
//    }
//    
//    private func removeCurrentProfile() {
//        if currentIndex < profiles.count {
//            profiles.remove(at: currentIndex)
//            dragOffset = .zero
//        }
//    }
//}
//
//// MARK: - Profile Card
//struct ProfileCard: View {
//    let profile: Profile
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color(hex: "8B9A7E"))
//                    .frame(height: 500)
//                
//                Image(systemName: profile.image)
//                    .foregroundColor(Color(hex: "5C3D2E"))
//                    .font(.system(size: 120))
//            }
//            
//            VStack(alignment: .leading, spacing: 1) {
//                HStack {
//                    Text(profile.name)
//                        .font(.system(size: 28, weight: .bold, design: .rounded))
//                        .foregroundColor(Color(hex: "5C3D2E"))
//                    
//                    Text("\(profile.age)")
//                        .font(.system(size: 24, weight: .medium, design: .rounded))
//                        .foregroundColor(Color(hex: "5C3D2E"))
//                }
//                
//                Text(profile.bio)
//                    .font(.system(size: 16, design: .rounded))
//                    .foregroundColor(Color(hex: "5C3D2E"))
//                    .lineLimit(3)
//            }
//            .padding(20)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color(hex: "F8F5EE"))
//        }
//        .cornerRadius(20)
//        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
//    }
//}
//
//// MARK: - Profile Model
//struct Profile: Identifiable {
//    let id = UUID()
//    let name: String
//    let age: Int
//    let bio: String
//    let image: String
//}
//
//#Preview {
//    LinksView()
//}



//
//  MatchmakingView.swift
//  MotherNurture1
//
//  Created by 46 GO Participant on 11/29/25.
//

import SwiftUI

// Custom Brand Colors based on tutorial view
extension Color {
    static let appBackground = Color(hex: "F8F5EE") // Cream
    static let primaryText = Color(hex: "5C3D2E") // Deep Brown
    static let connectGreen = Color(hex: "8B9A7E") // Darker Sage Green (Connect/Like)
    static let cardAccent = Color(hex: "9BA897") // Lighter Sage Green
    static let skipRed = Color.red.opacity(0.8) // Using a standard red for skip (contrast)
}

// - b-- 1. Data Model (Profile) ---
public struct Profile: Identifiable, Equatable {
    public let id = UUID()
    let name: String
    let age: Int
    let location: String
    let profilePicFileName: String
    let bio: String
    let tags: [String]
    let groups: [String]
}

// --- 2. Mock Data ---
let mockProfiles: [Profile] = [
    Profile(
        name: "Jessica R. ",
        age: 29,
        location: "1.2 mi away",
        profilePicFileName: "SmilingMomWithDaugther",
        bio: "Just moved to the area. Looking for a playdate partner and parenting book recommendations.",
        tags: ["New in Town", "Infant (6m)", "Book Lover", "Pumping"],
        groups: ["Get to Know Eachother!", "New Mom", "Mother of Children w/ Disabilities"]
    ),
    Profile(
        name: "Chloe D. ",
        age: 25,
        location: "0.5 mi away",
        profilePicFileName: "MomWithPointingBaby",
        bio: "SAHM running on fumes and cuddles. We love museums, baking, and quiet parks.",
        tags: ["Stay-at-Home", "Toddler (3)", "Baking Enthusiast"],
        groups: ["Get to Know Eachother!", "Expecting Moms"]
    ),
    Profile(
        name: "Sarah B. ",
        age: 23,
        location: "5 mi away",
        profilePicFileName: "GrassGirl",
        bio: "First-time mom navigating toddler tantrums. Coffee is my fuel! Looking for walking buddies and playground meetups.",
        tags: ["Working Mom", "Toddler (2)", "Loves Outdoors", "DIY & Crafts"],
        groups: ["Get to Know Eachother!", "New Moms"]
    ),
    Profile(
        name: "Emily P. ",
        age: 35,
        location: "7 mi away",
        profilePicFileName: "HappyMom",
        bio: "Twin mom survivalist! Looking for someone to share cheap activity ideas. Send help (and coffee).",
        tags: ["Twin Mom", "Coffee Addict", "Budgeting"],
        groups: ["Get to Know Eachother!", "Single Moms"]
    ),
    Profile(
        name: "Maria C. ",
        age: 38,
        location: "8 mi away",
        profilePicFileName: "ExtremelyHappyLady",
        bio: "Veteran mom of three, finally getting back into yoga. Seeking advice on navigating middle school.",
        tags: ["School-age Kids", "Yoga & Wellness", "Car Pool Queen", "Single Mom"],
        groups: ["Get to Know Eachother!", "Single Moms", "Mother of Children w/ Disabilities"]
    ),
]

// --- 4. Individual Card View ---
struct CardView: View {
    let profile: Profile
    let isTop: Bool
    let onGroupTapped: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area: bold, full-width header at fixed height
            ZStack(alignment: .bottomLeading) {
                Image(profile.profilePicFileName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 350)
                    .clipped()

                // Overlay content with name/age, location, and bio snippet
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(profile.name), \(profile.age)")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .shadow(radius: 2)

                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(profile.location)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                }
                // Reduced overlay padding slightly
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.55)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            VStack(alignment: .leading, spacing: 15) {
                // FlowLayout to display all groups
                FlowLayout(spacing: 8) {
                    ForEach(profile.groups, id: \.self) { group in
                        Button {
                            onGroupTapped(group)
                        } label: {
                            Text(group)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.connectGreen)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Full bio visible only on the top card
                if isTop {
                    Text(profile.bio)
                        .font(.body)
                        .foregroundColor(.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    // Use the FlowLayout to wrap tags
                    FlowLayout(spacing: 8) {
                        ForEach(profile.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.primaryText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.cardAccent.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

// --- 5. Main Matchmaking View with Swiping Logic ---
struct MatchmakingView: View {
    @State private var profiles: [Profile] = mockProfiles
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var feedbackText: String? = nil
    @State private var showMatchPopup: Bool = false
    @State private var matchedProfile: Profile? = nil
    @State private var navigateToMessages: Bool = false
    @State private var groupToNavigateTo: Channel? = nil
    
    private let swipeThreshold: CGFloat = 100
    private let rotationAngle: Double = 5.0
    
    private var rotation: Double {
        Double(offset.width / 20) * rotationAngle
    }
    
    private var topCard: Profile? {
        profiles.first
    }
    
    private func handleSwipe(isMatch: Bool) {
        if let card = topCard {
            if isMatch {
                print("Matched with \(card.name)")
                // Store who they matched with
                matchedProfile = card
                showMatchPopup = true
            } else {
                print("Skipped \(card.name)")
            }
            
            // Remove card after slight delay so animation can play
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut) {
                    if !profiles.isEmpty {
                        profiles.removeFirst()
                    }
                    offset = .zero
                    lastOffset = .zero
                }
            }
            
            // Loop mock data back if nearly empty
            if profiles.count <= 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    profiles = mockProfiles
                }
            }
        }
    }
    
    private func handleGroupTap(_ groupName: String) {
        // Create a Channel from the group and trigger navigation
        let channel = Channel(name: groupName, timeAgo: "now", isDirectMessage: false)
        groupToNavigateTo = channel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Find Your Village")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .padding(.top, 20)
                
                if let feedback = feedbackText {
                    Text(feedback)
                        .font(.headline)
                        .foregroundColor(feedback.contains("Match") ? .connectGreen : .skipRed)
                        .animation(.easeInOut, value: feedback)
                }
                
                GeometryReader { geo in
                    // Narrower width, taller height defaults
                    let maxCardWidth = min(geo.size.width * 0.9, 380)
                    let maxHeight = min(geo.size.height * 0.9, 780)
                    
                    ZStack {
                        // Top card (non-scrollable; bio and picture visible)
                        if let card = topCard {
                            CardView(profile: card, isTop: true, onGroupTapped: { group in
                                handleGroupTap(group)
                            })
                                .frame(maxWidth: maxCardWidth, alignment: .center)
                                .padding(.bottom, 1)
                                .frame(maxWidth: .infinity)
                                .frame(height: maxHeight)
                                .background(Color.clear)
                                .offset(offset)
                                .rotationEffect(.degrees(rotation))
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            offset = CGSize(
                                                width: gesture.translation.width + lastOffset.width,
                                                height: gesture.translation.height + lastOffset.height
                                            )
                                        }
                                        .onEnded { _ in
                                            if offset.width > swipeThreshold {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    offset = CGSize(width: 500, height: 0)
                                                }
                                                handleSwipe(isMatch: true)
                                            } else if offset.width < -swipeThreshold {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    offset = CGSize(width: -500, height: 0)
                                                }
                                                handleSwipe(isMatch: false)
                                            } else {
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                }
                                                lastOffset = .zero
                                            }
                                        }
                                )
                        } else {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Searching for more connections...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                            }
                            .frame(height: maxHeight)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, maxHeight: 780)
                
                HStack(spacing: 40) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            offset = CGSize(width: -500, height: 0)
                        }
                        handleSwipe(isMatch: false)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 70, height: 70)
                            .background(Color.skipRed)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .disabled(topCard == nil)
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            offset = CGSize(width: 500, height: 0)
                        }
                        handleSwipe(isMatch: true)
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 70, height: 70)
                            .background(Color.connectGreen)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .disabled(topCard == nil)
                }
                .padding(.bottom, 10)
                
                Spacer(minLength: 0)
            }
            .fullScreenCover(isPresented: $showMatchPopup) {
                if let profile = matchedProfile {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("🎉 It’s a Match!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                            
                            Text("You and \(profile.name) matched!")
                                .font(.headline)
                                .foregroundColor(.primaryText)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    navigateToMessages = true
                                    showMatchPopup = false
                                }) {
                                    Text("Message")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: 130)
                                        .background(Color.connectGreen)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showMatchPopup = false
                                }) {
                                    Text("Keep Swiping")
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
                                        .padding()
                                        .frame(maxWidth: 130)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(40)
                    }
                } else {
                    Color.clear.ignoresSafeArea()
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            // Navigate to the app-wide MessagesView by constructing a DM Channel for the matched profile
            .navigationDestination(isPresented: $navigateToMessages) {
                if let profile = matchedProfile {
                    MessagesView(channel: Channel(name: profile.name, timeAgo: "now", isDirectMessage: true))
                } else {
                    MessagesView(channel: Channel(name: "Direct Message", timeAgo: "now", isDirectMessage: true))
                }
            }
            // Navigate when a group tag is tapped
            .navigationDestination(item: $groupToNavigateTo) { channel in
                MessagesView(channel: channel)
            }
        }
    }
}

// --- Preview Structure ---
struct MatchmakingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchmakingView()
    }
}

