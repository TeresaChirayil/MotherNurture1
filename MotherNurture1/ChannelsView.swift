import SwiftUI

struct ChannelsView: View {
    @State private var searchText: String = ""
    @State private var showCreateChannel = false
    @State private var currentTab: TabDestination = .channels
    @State private var selectedChannel: Channel? = nil  // ← for navigation
    @State private var channels: [Channel] = [
        Channel(name: "Candence Smith", timeAgo: "1h", isDirectMessage: true),
        Channel(name: "Get to Know Each Other!", timeAgo: "2h"),
        Channel(name: "Mothers of Children with Disabilities", timeAgo: "4h"),
        Channel(name: "Expecting Moms", timeAgo: "6h"),
        Channel(name: "Single Moms", timeAgo: "8h")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
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
                    .background(Color(hex: "8B9A7E"))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Main content (channels list)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("All channels")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                            
                            VStack(spacing: 16) {
                                ForEach(channels) { channel in
                                    Button(action: {
                                        selectedChannel = channel
                                    }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(channel.isDirectMessage ? Color(hex: "9BA897") : Color(hex: "8B9A7E"))
                                                    .frame(width: 44, height: 44)
                                                
                                                Image(systemName: channel.isDirectMessage ? "bubble.left" : "bubble.left.and.bubble.right")
                                                    .foregroundColor(Color(hex: "5C3D2E"))
                                                    .font(.system(size: 20))
                                            }
                                            
                                            Text(channel.name)
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                            
                                            Spacer()
                                            
                                            Text(channel.timeAgo)
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.bottom, 90) // space for nav bar
                        }
                    }
                    
                    // Add Button
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreateChannel = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "8B9A7E"))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "plus")
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .font(.system(size: 32, weight: .medium))
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 110)
                }
                // ✅ Keep bottom nav visible always
                .overlay(alignment: .bottom) {
                    BottomNavBar(currentTab: $currentTab)
                        .padding(.bottom, 5)
                }
            }
            // ✅ Navigation to CreateChannelView
            .navigationDestination(isPresented: $showCreateChannel) {
                CreateChannelView(
                    isPresented: $showCreateChannel,
                    onSave: { channelName, description, category, type in
                        let newChannel = Channel(name: channelName, timeAgo: "0h", isDirectMessage: false)
                        channels.append(newChannel)
                    }
                )
            }
            // ✅ Navigation to Messages screen
            .navigationDestination(item: $selectedChannel) { channel in
                MessagesView(channel: channel)
            }
        }
    }
}

struct Channel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let timeAgo: String
    let isDirectMessage: Bool
    
    init(name: String, timeAgo: String, isDirectMessage: Bool = false) {
        self.name = name
        self.timeAgo = timeAgo
        self.isDirectMessage = isDirectMessage
    }
}

#Preview {
    ChannelsView()
}
