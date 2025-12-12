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
    public let id: String // Use userID for stable identification
    let name: String
    let age: Int
    let location: String
    let profilePicFileName: String? // Optional: for asset names (legacy)
    let profilePicURL: String? // Optional: for photo URLs from Firebase
    let bio: String
    let tags: [String]
    let groups: [String]
    
    init(id: String = UUID().uuidString, name: String, age: Int, location: String, profilePicFileName: String? = nil, profilePicURL: String? = nil, bio: String, tags: [String], groups: [String]) {
        self.id = id
        self.name = name
        self.age = age
        self.location = location
        self.profilePicFileName = profilePicFileName
        self.profilePicURL = profilePicURL
        self.bio = bio
        self.tags = tags
        self.groups = groups
    }
}

// --- 2. Mock Data (fallback when no real profiles available) ---
let mockProfiles: [Profile] = [
    Profile(
        id: "mock_jessica",
        name: "Jessica R. ",
        age: 29,
        location: "1.2 mi away",
        profilePicFileName: "SmilingMomWithDaugther",
        profilePicURL: nil,
        bio: "Just moved to the area. Looking for a playdate partner and parenting book recommendations.",
        tags: ["New in Town", "Infant (6m)", "Book Lover", "Pumping"],
        groups: ["Get to Know Eachother!", "New Mom", "Mother of Children w/ Disabilities"]
    ),
    Profile(
        id: "mock_chloe",
        name: "Chloe D. ",
        age: 25,
        location: "0.5 mi away",
        profilePicFileName: "MomWithPointingBaby",
        profilePicURL: nil,
        bio: "SAHM running on fumes and cuddles. We love museums, baking, and quiet parks.",
        tags: ["Stay-at-Home", "Toddler (3)", "Baking Enthusiast"],
        groups: ["Get to Know Eachother!", "Expecting Moms"]
    ),
    Profile(
        id: "mock_sarah",
        name: "Sarah B. ",
        age: 23,
        location: "5 mi away",
        profilePicFileName: "GrassGirl",
        profilePicURL: nil,
        bio: "First-time mom navigating toddler tantrums. Coffee is my fuel! Looking for walking buddies and playground meetups.",
        tags: ["Working Mom", "Toddler (2)", "Loves Outdoors", "DIY & Crafts"],
        groups: ["Get to Know Eachother!", "New Moms"]
    ),
    Profile(
        id: "mock_emily",
        name: "Emily P. ",
        age: 35,
        location: "7 mi away",
        profilePicFileName: "HappyMom",
        profilePicURL: nil,
        bio: "Twin mom survivalist! Looking for someone to share cheap activity ideas. Send help (and coffee).",
        tags: ["Twin Mom", "Coffee Addict", "Budgeting"],
        groups: ["Get to Know Eachother!", "Single Moms"]
    ),
    Profile(
        id: "mock_maria",
        name: "Maria C. ",
        age: 38,
        location: "8 mi away",
        profilePicFileName: "ExtremelyHappyLady",
        profilePicURL: nil,
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
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var showBlockConfirmation = false
    @State private var showReportConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area: bold, full-width header at fixed height
            ZStack(alignment: .bottomLeading) {
                // Show photo from URL if available, otherwise asset name, otherwise green placeholder
                if let photoURL = profile.profilePicURL, !photoURL.isEmpty {
                    AsyncImage(url: URL(string: photoURL)) { phase in
                        switch phase {
                        case .empty:
                            // Loading state - show green placeholder
                            Color(hex: "9BA897")
                                .frame(height: 350)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 350)
                                .clipped()
                        case .failure:
                            // Failed to load - show green placeholder
                            Color(hex: "9BA897")
                                .frame(height: 350)
                        @unknown default:
                            Color(hex: "9BA897")
                                .frame(height: 350)
                        }
                    }
                } else if let assetName = profile.profilePicFileName, !assetName.isEmpty {
                    Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 350)
                    .clipped()
                } else {
                    // No photo - show green placeholder
                    Color(hex: "9BA897")
                        .frame(height: 350)
                }

                // Overlay content with name/age, location, and bio snippet
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
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
                        
                        Spacer()
                        
                        // Menu button for block/report
                        if isTop {
                            Menu {
                                Button(role: .destructive, action: {
                                    showBlockConfirmation = true
                                }) {
                                    Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                                }
                                
                                Button(role: .destructive, action: {
                                    showReportConfirmation = true
                                }) {
                                    Label("Report User", systemImage: "flag")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }
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
        .confirmationDialog("Block User", isPresented: $showBlockConfirmation, titleVisibility: .visible) {
            Button("Block", role: .destructive) {
                Task { await blockUser() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Block \(profile.name)? You won't see their profile anymore.")
        }
        .confirmationDialog("Report User", isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button("Report", role: .destructive) {
                reportUser()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Report \(profile.name) for inappropriate behavior?")
        }
    }
    
    private func blockUser() async {
        guard let currentUserID = userDataManager.profile.userID else { return }
        
        do {
            try await FirebaseService.shared.blockUser(userID: currentUserID, userIDToBlock: profile.id)
            
            // Reload user profile to get updated blockedUsers list
            if let userID = userDataManager.profile.userID {
                do {
                    let updatedProfile = try await FirebaseService.shared.getUserProfile(userID: userID)
                    await MainActor.run {
                        if let profile = updatedProfile {
                            userDataManager.profile = profile
                        }
                    }
                } catch {
                    print("Error reloading profile after block: \(error)")
                }
            }
        } catch {
            print("Error blocking user: \(error)")
        }
    }
    
    private func reportUser() {
        MailHelper.reportUser(userID: profile.id, userName: profile.name)
    }
}

// --- 5. Main Matchmaking View with Swiping Logic ---
struct MatchmakingView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var profiles: [Profile] = []
    @State private var isLoading: Bool = true
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var feedbackText: String? = nil
    @State private var showMatchPopup: Bool = false
    @State private var matchedProfile: Profile? = nil
    @State private var navigateToMessages: Bool = false
    @State private var groupToNavigateTo: Channel? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private let swipeThreshold: CGFloat = 100
    private let rotationAngle: Double = 5.0
    
    private var rotation: Double {
        Double(offset.width / 20) * rotationAngle
    }
    
    private var topCard: Profile? {
        profiles.first
    }
    
    private func performSwipeAnimation(isMatch: Bool) {
        guard topCard != nil else { return }
        
        let targetOffset = CGSize(width: isMatch ? 500 : -500, height: 0)
        let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.6)
        
        // Reset lastOffset before starting new animation
        lastOffset = .zero
        
        // Start the swipe animation - this will animate the card off-screen
        withAnimation(springAnimation) {
            offset = targetOffset
        }
        
        // Calculate when animation completes and remove card at that exact moment
        // For spring(response: 0.3, dampingFraction: 0.6), settling time ≈ 0.55-0.6s
        let animationCompletionTime = 0.6
        
        Task { @MainActor in
            // Wait for animation to fully complete before removing the card
            try? await Task.sleep(nanoseconds: UInt64(animationCompletionTime * 1_000_000_000))
            
            // Now that the card has fully animated off-screen, remove it and reset state
            // This ensures no visual stretching as the next card smoothly takes its place
            withAnimation(.easeOut(duration: 0.15)) {
                if !profiles.isEmpty {
                    profiles.removeFirst()
                }
                offset = .zero
                lastOffset = .zero
            }
        }
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
            
            // Perform the swipe animation which handles removal on completion
            performSwipeAnimation(isMatch: isMatch)
            
            // Reload from Firebase if nearly empty
            if profiles.count <= 1 {
                Task {
                    await loadProfiles()
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
                
                if isLoading {
                    ProgressView()
                        .padding()
                }
                
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
                            .environmentObject(userDataManager)
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
                                                handleSwipe(isMatch: true)
                                            } else if offset.width < -swipeThreshold {
                                                handleSwipe(isMatch: false)
                                            } else {
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                }
                                                lastOffset = .zero
                                            }
                                        }
                                )
                        } else if isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Loading profiles...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                            }
                            .frame(height: maxHeight)
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No more profiles available")
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                                Text("Check back later for new connections")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.top, 4)
                                
                                Button(action: {
                                    Task {
                                        await loadProfiles()
                                    }
                                }) {
                                    Text("Refresh")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.connectGreen)
                                        .cornerRadius(12)
                                        .padding(.top, 16)
                                }
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
                                    // Add the matched person to ChannelsView before navigating
                                    if let profile = matchedProfile {
                                        let newChannel = Channel(
                                            name: profile.name.trimmingCharacters(in: .whitespaces),
                                            timeAgo: "now",
                                            isDirectMessage: true
                                        )
                                        ChannelsManager.shared.addChannel(newChannel)
                                    }
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
                    // Use the same trimmed name that was added to ChannelsManager
                    let channelName = profile.name.trimmingCharacters(in: .whitespaces)
                    MessagesView(channel: Channel(name: channelName, timeAgo: "now", isDirectMessage: true))
                        .environmentObject(userDataManager)
                } else {
                    MessagesView(channel: Channel(name: "Direct Message", timeAgo: "now", isDirectMessage: true))
                        .environmentObject(userDataManager)
                }
            }
            // Navigate when a group tag is tapped
            .navigationDestination(item: $groupToNavigateTo) { channel in
                MessagesView(channel: channel)
                    .environmentObject(userDataManager)
            }
            .task {
                await loadProfiles()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Load Profiles from Firebase
    private func loadProfiles() async {
        isLoading = true
        do {
            // Get current user ID to exclude from results
            let currentUserID = userDataManager.profile.userID
            
            // Fetch all user profiles from Firebase
            let userProfiles = try await FirebaseService.shared.fetchAllUserProfiles(
                excludingUserID: currentUserID,
                limit: 50
            )
            
            // Convert UserProfile to Profile for matchmaking
            let matchmakingProfiles = userProfiles.compactMap { userProfile -> Profile? in
                convertToMatchmakingProfile(userProfile)
            }
            
            await MainActor.run {
                if matchmakingProfiles.isEmpty {
                    // If no real profiles, fall back to mock data
                    self.profiles = mockProfiles
                } else {
                    self.profiles = matchmakingProfiles
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load profiles: \(error.localizedDescription)"
                self.showError = true
                // Fall back to mock data on error
                self.profiles = mockProfiles
            }
            print("Error loading profiles: \(error)")
        }
    }
    
    // MARK: - Convert UserProfile to Profile
    private func convertToMatchmakingProfile(_ userProfile: UserProfile) -> Profile? {
        // Require at least a name to show in matchmaking
        guard let firstName = userProfile.firstName, !firstName.isEmpty else {
            return nil
        }
        
        // Build full name
        let lastName = userProfile.lastName ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        
        // Calculate age from dateOfBirth
        let age: Int
        if let dateOfBirth = userProfile.dateOfBirth {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
            age = ageComponents.year ?? 0
        } else if let ageRange = userProfile.ageRange {
            // Parse age range to get approximate age
            if ageRange == "18-21" {
                age = 20
            } else if ageRange == "22-25" {
                age = 24
            } else if ageRange == "26-29" {
                age = 28
            } else if ageRange == "30+" {
                age = 32
            } else {
                age = 28 // Default
            }
        } else {
            age = 28 // Default if no age info
        }
        
        // Location - use town or zipcode, or default
        let location: String
        if let town = userProfile.town, !town.isEmpty {
            location = "\(town)"
        } else if let zipcode = userProfile.zipcode, !zipcode.isEmpty {
            location = "\(zipcode)"
        } else {
            location = "Nearby"
        }
        
        // Profile picture - use photoURL if available and it's a real URL (not a placeholder)
        // Placeholder URLs like "selected_image_..." should be treated as no photo
        let profilePicURL: String?
        if let photoURL = userProfile.photoURL, !photoURL.isEmpty {
            // Only use it if it looks like a real URL (starts with http:// or https://)
            // Placeholder UUIDs like "selected_image_..." will be treated as no photo
            if photoURL.hasPrefix("http://") || photoURL.hasPrefix("https://") {
                profilePicURL = photoURL
            } else {
                // It's a placeholder, treat as no photo
                profilePicURL = nil
            }
        } else {
            profilePicURL = nil
        }
        let profilePicFileName: String? = nil // Don't use default images - show green placeholder if no photoURL
        
        // Bio - use shortDescription or create one from interests
        let bio: String
        if let description = userProfile.shortDescription, !description.isEmpty {
            bio = description
        } else {
            let interestsText = userProfile.interests?.joined(separator: ", ") ?? ""
            let tagsText = userProfile.parentTags?.joined(separator: ", ") ?? ""
            if !interestsText.isEmpty || !tagsText.isEmpty {
                bio = "\(tagsText)\(tagsText.isEmpty ? "" : ". ")\(interestsText.isEmpty ? "" : "Loves \(interestsText).")"
            } else {
                bio = "Looking to connect with other moms!"
            }
        }
        
        // Tags - combine parentTags and interests
        var tags: [String] = []
        if let parentTags = userProfile.parentTags {
            tags.append(contentsOf: parentTags)
        }
        if let interests = userProfile.interests {
            tags.append(contentsOf: interests)
        }
        // Add child age info if available
        if let childAges = userProfile.childAges, !childAges.isEmpty {
            let ageStrings = childAges.compactMap { age -> String? in
                guard age >= 0 else { return nil }
                if age == 0 {
                    return "Newborn"
                } else if age < 1 {
                    // For months, we'd need a separate field. For now, treat as infant
                    return "Infant"
                } else if age < 3 {
                    return "Toddler (\(age))"
                } else if age < 13 {
                    return "Child (\(age))"
                } else {
                    return "Teen (\(age))"
                }
            }
            tags.append(contentsOf: ageStrings)
        }
        
        // Groups - use channelMemberships
        let groups = userProfile.channelMemberships ?? []
        
        // Use userID as the Profile id for stable identification
        let profileID = userProfile.userID ?? UUID().uuidString
        
        return Profile(
            id: profileID,
            name: fullName,
            age: age,
            location: location,
            profilePicFileName: profilePicFileName,
            profilePicURL: profilePicURL,
            bio: bio,
            tags: tags,
            groups: groups
        )
    }
}

// --- Preview Structure ---
struct MatchmakingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchmakingView()
    }
}

