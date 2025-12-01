////
////  ForumView.swift
////  MotherNurture1
////
////  Created by 40 GO Participant on 11/5/25.


import SwiftUI

struct ForumView: View {
    @State private var showChannels = false
    @State private var showLinks = false
    @State private var currentTab: TabDestination = .forum
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE").ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Welcome Section
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "8B9A7E"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello, [User’s Name]!")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            Text("Let's build a supportive community together.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    
                    // Messages Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Messages")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .padding(.horizontal, 20)
                        
                        Text("What our parents are sharing")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForumCardView(
                                    title: "A happy moment with kids",
                                    content: "Just had a wonderful day at the park with my little ones! 🌳",
                                    tags: ["FamilyTime", "Parenting"],
                                    author: "Jane Doe"
                                )
                                
                                ForumCardView(
                                    title: "Playing games",
                                    content: "Looking for cool games to play with my toddler! Any suggestions?",
                                    tags: ["AskTheCommunity"],
                                    author: "Mark Smith"
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Topics of Interest
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Topics of Interest")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            TopicButton(title: "Parenting Tips", icon: "lightbulb")
                            TopicButton(title: "Fun Activities", icon: "gamecontroller")
                            TopicButton(title: "Advice", icon: "questionmark.circle")
                            TopicButton(title: "Meetups", icon: "person.3")
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Encouraging Thoughts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Encouraging Thoughts")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .padding(.horizontal, 20)
                        
                        EncouragingCardView(
                            title: "You're not alone!",
                            description: "Connecting with other parents can be a source of strength and joy. Share your experiences and find comfort in community.",
                            author: "Community Support"
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 80) // room for bottom nav bar
                }
                // Bottom Nav Bar
                .overlay(alignment: .bottom) {
                    BottomNavBar(currentTab: $currentTab)
                        .padding(.bottom, 5)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Forum Card View (light green background)
struct ForumCardView: View {
    let title: String
    let content: String
    let tags: [String]
    let author: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
                .lineLimit(1)
            
            Text(content)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
                .lineLimit(2)
            
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color(hex: "8B9A7E").opacity(0.2))
                        .cornerRadius(6)
                }
            }
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color(hex: "8B9A7E"))
                Text(author)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
            }
            
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                Image(systemName: "hand.thumbsup.fill")
            }
            .foregroundColor(Color(hex: "5C3D2E"))
            .padding(.top, 6)
        }
        .padding()
        .frame(width: 240, height: 180)
        .background(Color(hex: "DDE3D0")) // 💚 light green box
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Topic Button (light green)
struct TopicButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "5C3D2E"))
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(hex: "DDE3D0")) // 💚 light green background
        .cornerRadius(10)
    }
}

// MARK: - Encouraging Thoughts Card (light green)
struct EncouragingCardView: View {
    let title: String
    let description: String
    let author: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "8B9A7E").opacity(0.3))
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Color(hex: "8B9A7E"))
                    Text(author)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(hex: "DDE3D0")) // 💚 light green background
        .cornerRadius(10)
    }
}

#Preview {
    ForumView()
}
