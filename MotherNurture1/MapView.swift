//
//  MapView.swift
//  MotherNurture1
//

import SwiftUI

struct MapView: View {
    @State private var currentTab: TabDestination = .map
    
    let pins = [
        MapPin(name: "PARK", x: 0.15, y: 0.2),
        MapPin(name: "POOL", x: 0.45, y: 0.25),
        MapPin(name: "BEACH", x: 0.75, y: 0.3),
        MapPin(name: "CAFE", x: 0.35, y: 0.55),
        MapPin(name: "PARK", x: 0.6, y: 0.55),
        MapPin(name: "CAFE", x: 0.2, y: 0.75),
        MapPin(name: "PARK", x: 0.75, y: 0.8)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🌿 Background image
                Image("mapBackground")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.8)
                    .ignoresSafeArea()
                
                // Pin overlay
                GeometryReader { geo in
                    ForEach(pins) { pin in
                        VStack(spacing: 4) {
                            Image(systemName: "mappin.circle")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            Text(pin.name)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                        .position(
                            x: geo.size.width * CGFloat(pin.x),
                            y: geo.size.height * CGFloat(pin.y)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .ignoresSafeArea(edges: .bottom)
                
                // Bottom Nav Bar
                ZStack {
                    // ... background and map pins above ...
                    
                    VStack {
                        Spacer()
                        BottomNavBar(currentTab: $currentTab)
                            .padding(.horizontal, 50)
                            .padding(.bottom, 12)
                            .background(
                                Color(hex: "F8F5EE")
                                    .ignoresSafeArea(edges: .bottom)
                            )
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }

        }
    }
}

// MARK: - MapPin
struct MapPin: Identifiable {
    let id = UUID()
    let name: String
    let x: CGFloat
    let y: CGFloat
}

#Preview {
    MapView()
}
