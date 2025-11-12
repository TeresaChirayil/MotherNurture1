//
//  MessagesView.swift
//  MotherNurture1
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.dismiss) var dismiss
    let channel: Channel
    
    @State private var newMessage: String = ""
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Welcome to the chat!", isUser: false),
        ChatMessage(text: "Feel free to share your experiences here.", isUser: false)
    ]
    
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
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation {
            messages.append(ChatMessage(text: newMessage, isUser: true))
            newMessage = ""
        }
    }
}

#Preview {
    MessagesView(channel: Channel(name: "Single moms", timeAgo: "2h"))
}

