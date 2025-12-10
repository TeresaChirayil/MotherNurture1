//
//  ChannelsManager.swift
//  MotherNurture1
//
//  Shared manager for channels to sync between views
//

import Foundation
import Combine

class ChannelsManager: ObservableObject {
    static let shared = ChannelsManager()
    
    @Published var channels: [Channel] = [
        Channel(name: "Candence Smith", timeAgo: "1h", isDirectMessage: true),
        Channel(name: "Get to Know Each Other!", timeAgo: "2h"),
        Channel(name: "Mothers of Children with Disabilities", timeAgo: "4h"),
        Channel(name: "Expecting Moms", timeAgo: "6h"),
        Channel(name: "Single Moms", timeAgo: "8h")
    ]
    
    private init() {}
    
    /// Add a new channel if it doesn't already exist
    func addChannel(_ channel: Channel) {
        // Check if channel already exists (by name and isDirectMessage)
        let exists = channels.contains { existingChannel in
            existingChannel.name == channel.name && existingChannel.isDirectMessage == channel.isDirectMessage
        }
        
        if !exists {
            // Add to the beginning of the list (most recent first)
            channels.insert(channel, at: 0)
            print("✅ Added new channel: \(channel.name)")
        } else {
            print("ℹ️ Channel already exists: \(channel.name)")
        }
    }
    
    /// Update the timeAgo for an existing channel
    func updateChannelTime(_ channelName: String, isDirectMessage: Bool, timeAgo: String) {
        if let index = channels.firstIndex(where: { $0.name == channelName && $0.isDirectMessage == isDirectMessage }) {
            // Create updated channel with new time
            let updatedChannel = Channel(name: channelName, timeAgo: timeAgo, isDirectMessage: isDirectMessage)
            channels[index] = updatedChannel
        }
    }
}




