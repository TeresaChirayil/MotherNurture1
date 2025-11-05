//
//  ChannelsView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct ChannelsView: View {
    @State private var searchText: String = ""
    @State private var showCreateChannel = false
    @State private var showLinks = false
    @State private var channels: [Channel] = [
        Channel(name: "Single moms", timeAgo: "2h"),
        Channel(name: "Moms with infants", timeAgo: "4h"),
        Channel(name: "Moms of children with autism", timeAgo: "6h"),
        Channel(name: "Kids with disabilities", timeAgo: "8h")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color (reversed - beige instead of olive green)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                
                // Main Content
                VStack(alignment: .leading, spacing: 0) {
                    // All channels heading
                    Text("All channels")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    
                    // Channel List
                    VStack(spacing: 16) {
                        ForEach(channels) { channel in
                            HStack(spacing: 12) {
                                // Channel Icon
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "8B9A7E")) // Olive green background
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 20))
                                }
                                
                                // Channel Name
                                Text(channel.name)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Spacer()
                                
                                // Time Indicator
                                Text(channel.timeAgo)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                    
                    // Add Button - Centered
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreateChannel = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "8B9A7E")) // Olive green background
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "plus")
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .font(.system(size: 32, weight: .medium))
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
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
                    Button(action: {
                        showLinks = true
                    }) {
                        Image(systemName: "link")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "5C3D2E"))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
            .navigationDestination(isPresented: $showCreateChannel) {
                CreateChannelView(
                    isPresented: $showCreateChannel,
                    onSave: { channelName, description, category, type in
                        // Add new channel to the list
                        let newChannel = Channel(name: channelName, timeAgo: "0h")
                        channels.append(newChannel)
                    }
                )
            }
            .navigationDestination(isPresented: $showLinks) {
                LinksView()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct Channel: Identifiable {
    let id = UUID()
    let name: String
    let timeAgo: String
}

#Preview {
    ChannelsView()
}
