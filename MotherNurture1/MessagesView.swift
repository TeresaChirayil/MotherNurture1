//
//  MessagesView.swift
//  MotherNurture1
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    let channel: Channel
    
    @State private var newMessage: String = ""
    @State private var showBlockConfirmation = false
    @State private var showReportConfirmation = false
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Welcome to the chat!", isUser: false),
        ChatMessage(text: "Feel free to share your experiences here.", isUser: false)
    ]
    
    private var canBlockOrReport: Bool {
        channel.isDirectMessage // Only allow block/report for direct messages
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8F5EE").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 20, weight: .medium))
                    }
                    Text(channel.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    Spacer()
                    
                    if canBlockOrReport {
                        Menu {
                            Button(role: .destructive, action: {
                                showBlockConfirmation = true
                            }) {
                                Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                            }
                            
                            Button(role: .destructive, action: {
                                showReportConfirmation = true
                            }) {
                                Label("Report User/Content", systemImage: "flag")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(hex: "8B9A7E").opacity(0.8))
                
                // Messages list
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(messages) { msg in
                                HStack {
                                    if msg.isUser {
                                        Spacer()
                                        Text(msg.text)
                                            .padding(10)
                                            .background(Color(hex: "D7C4B7")) // user’s light brown bubble
                                            .foregroundColor(Color(hex: "000000"))
                                            .cornerRadius(12)
                                            .frame(maxWidth: 240, alignment: .trailing)
                                    } else {
                                        Text(msg.text)
                                            .padding(10)
                                            .background(Color(hex: "DDE3D0")) // other user’s light green bubble
                                            .foregroundColor(Color(hex: "000000"))
                                            .cornerRadius(12)
                                            .frame(maxWidth: 240, alignment: .leading)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 10)
                        // ✅ Updated iOS 17+ syntax
                        .onChange(of: messages.count) {
                            withAnimation {
                                scrollProxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
            
        
                
                // Message input field
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $newMessage)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "000000"))
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "F8F5EE").shadow(radius: 2))
            }
        }
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("Block User", isPresented: $showBlockConfirmation, titleVisibility: .visible) {
            Button("Block", role: .destructive) {
                Task { await blockUser() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Block \(channel.name)? You won't see their messages anymore.")
        }
        .confirmationDialog("Report User/Content", isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button("Report", role: .destructive) {
                reportUser()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Report this user or content for inappropriate behavior?")
        }
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation {
            messages.append(ChatMessage(text: newMessage, isUser: true))
            newMessage = ""
        }
    }
    
    private func blockUser() async {
        guard let currentUserID = userDataManager.profile.userID else { return }
        
        // For direct messages, we need to find the user ID from the channel name
        // The channel name should match the user's name (firstName + lastName)
        // We'll search for a user profile matching this name
        var userIDToBlock: String? = nil
        
        do {
            // Fetch all user profiles and find one matching the channel name
            let allProfiles = try await FirebaseService.shared.fetchAllUserProfiles(excludingUserID: currentUserID, limit: 100)
            
            // Try to find a user whose full name matches the channel name
            for profile in allProfiles {
                let fullName = "\(profile.firstName ?? "") \(profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
                if fullName == channel.name || profile.firstName == channel.name {
                    userIDToBlock = profile.userID
                    break
                }
            }
            
            // If we found the user, block them
            if let userID = userIDToBlock {
                try await FirebaseService.shared.blockUser(userID: currentUserID, userIDToBlock: userID)
                
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
                
                print("✅ Successfully blocked user: \(channel.name)")
            } else {
                print("⚠️ Could not find user with name: \(channel.name)")
                // Note: In a production app, you might want to show an alert to the user
            }
        } catch {
            print("Error blocking user: \(error)")
        }
    }
    
    private func reportUser() {
        let channelID = channel.id.uuidString
        MailHelper.reportMessage(channelID: channelID, channelName: channel.name, userName: channel.name)
    }
}

#Preview {
    MessagesView(channel: Channel(name: "Single moms", timeAgo: "2h"))
}

