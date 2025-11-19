//
//  MapView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/5/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct MapView: View {
    @State private var currentTab: TabDestination = .map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.7000), // Chicago 60659 area (West Ridge)
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @State private var selectedLocation: LocationPin?
    @State private var showLocationDetail = false
    @State private var searchText = ""
    @State private var selectedCategory: LocationPin.LocationCategory? = nil
    @State private var showFilters = false
    @State private var showListSheet = false
    @StateObject private var locationManager = LocationManager()
    
    // Real family-friendly locations in the 60659 area (West Ridge, Chicago)
    let allLocations: [LocationPin] = [
        // Parks & Playgrounds
        LocationPin(
            name: "Warren Park",
            category: .park,
            coordinate: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.7000),
            description: "Large community park with modern playground equipment, sports fields, walking paths, and picnic areas. Perfect for playdates and outdoor activities.",
            address: "6601 N Western Ave, Chicago, IL 60659",
            phone: "(312) 742-7529",
            hours: "6am-11pm Daily"
        ),
        LocationPin(
            name: "Indian Boundary Park",
            category: .park,
            coordinate: CLLocationCoordinate2D(latitude: 41.9800, longitude: -87.6900),
            description: "Historic park featuring a cultural center, playground, small zoo, and beautiful gardens. Great for families with young children.",
            address: "2500 W Lunt Ave, Chicago, IL 60645",
            phone: "(312) 742-7891",
            hours: "6am-11pm Daily"
        ),
        LocationPin(
            name: "West Ridge Nature Park",
            category: .park,
            coordinate: CLLocationCoordinate2D(latitude: 41.9950, longitude: -87.7100),
            description: "Nature preserve with walking trails, wildlife viewing, and educational programs. Peaceful escape for moms and kids.",
            address: "5801 N Western Ave, Chicago, IL 60659",
            phone: "(312) 744-5472",
            hours: "6am-9pm Daily"
        ),
        LocationPin(
            name: "Pottawattomie Park",
            category: .park,
            coordinate: CLLocationCoordinate2D(latitude: 41.9850, longitude: -87.7000),
            description: "Community park with playground, basketball courts, and open space. Popular spot for local families.",
            address: "7340 N Rogers Ave, Chicago, IL 60626",
            phone: "(312) 742-7529",
            hours: "6am-11pm Daily"
        ),
        
        // Libraries
        LocationPin(
            name: "West Ridge Branch Library",
            category: .library,
            coordinate: CLLocationCoordinate2D(latitude: 41.9880, longitude: -87.6950),
            description: "Public library with extensive children's section, storytime programs, and family-friendly events. Free Wi-Fi and quiet reading areas.",
            address: "1746 W Touhy Ave, Chicago, IL 60626",
            phone: "(312) 744-6022",
            hours: "Mon-Thu: 10am-8pm, Fri-Sat: 10am-6pm, Sun: 1pm-5pm"
        ),
        LocationPin(
            name: "Rogers Park Branch Library",
            category: .library,
            coordinate: CLLocationCoordinate2D(latitude: 41.9950, longitude: -87.6800),
            description: "Neighborhood library with children's programs, homework help, and community events. Welcoming space for families.",
            address: "6907 N Clark St, Chicago, IL 60626",
            phone: "(312) 744-0156",
            hours: "Mon-Thu: 10am-8pm, Fri-Sat: 10am-6pm, Sun: 1pm-5pm"
        ),
        
        // Cafes & Restaurants
        LocationPin(
            name: "Cafe Hopper",
            category: .cafe,
            coordinate: CLLocationCoordinate2D(latitude: 41.9920, longitude: -87.6950),
            description: "Family-friendly coffee shop with kid-friendly menu, high chairs, and a welcoming atmosphere. Great for playdates and mom meetups.",
            address: "2300 W Devon Ave, Chicago, IL 60659",
            phone: "(773) 465-0000",
            hours: "Mon-Fri: 7am-7pm, Sat-Sun: 8am-6pm"
        ),
        LocationPin(
            name: "Noon O Kabab",
            category: .restaurant,
            coordinate: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.6900),
            description: "Family-friendly Persian restaurant with healthy options and accommodating staff. Great for family dinners.",
            address: "4701 N Kedzie Ave, Chicago, IL 60625",
            phone: "(773) 279-8899",
            hours: "Daily: 11am-11pm"
        ),
        LocationPin(
            name: "Taste of Peru",
            category: .restaurant,
            coordinate: CLLocationCoordinate2D(latitude: 41.9880, longitude: -87.7000),
            description: "Cozy neighborhood restaurant with family-friendly atmosphere and delicious Peruvian cuisine. Kids welcome!",
            address: "6545 N Clark St, Chicago, IL 60626",
            phone: "(773) 465-9000",
            hours: "Tue-Sun: 11am-10pm, Closed Mon"
        ),
        
        // Community Centers
        LocationPin(
            name: "West Ridge Community Center",
            category: .community,
            coordinate: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.7050),
            description: "Community center offering programs for children and families, including classes, workshops, and social events.",
            address: "6366 N Western Ave, Chicago, IL 60659",
            phone: "(312) 742-7529",
            hours: "Mon-Fri: 9am-9pm, Sat: 9am-5pm"
        ),
        LocationPin(
            name: "Indian Boundary Cultural Center",
            category: .community,
            coordinate: CLLocationCoordinate2D(latitude: 41.9800, longitude: -87.6900),
            description: "Cultural center with art classes, music programs, and family events. Great for enriching activities with kids.",
            address: "2500 W Lunt Ave, Chicago, IL 60645",
            phone: "(312) 742-7891",
            hours: "Mon-Fri: 9am-9pm, Sat: 9am-5pm"
        ),
        
        // Family Activities
        LocationPin(
            name: "Devon Market",
            category: .market,
            coordinate: CLLocationCoordinate2D(latitude: 41.9920, longitude: -87.6900),
            description: "Large international market with fresh produce, prepared foods, and family-friendly shopping. Great for exploring with kids.",
            address: "1440 W Devon Ave, Chicago, IL 60660",
            phone: "(773) 465-3838",
            hours: "Daily: 8am-9pm"
        ),
        LocationPin(
            name: "West Ridge Farmers Market",
            category: .market,
            coordinate: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.7000),
            description: "Weekly farmers market with fresh produce, local vendors, and family-friendly activities. Saturdays 8am-1pm, May-October.",
            address: "6601 N Western Ave, Chicago, IL 60659",
            phone: "(312) 742-7529",
            hours: "Sat: 8am-1pm (Seasonal)"
        ),
        LocationPin(
            name: "Warren Park Ice Rink",
            category: .activity,
            coordinate: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.7000),
            description: "Public ice skating rink with lessons and open skate times. Fun winter activity for the whole family.",
            address: "6601 N Western Ave, Chicago, IL 60659",
            phone: "(312) 742-7529",
            hours: "Seasonal: Nov-Mar, Check schedule"
        ),
        LocationPin(
            name: "West Ridge Playground",
            category: .park,
            coordinate: CLLocationCoordinate2D(latitude: 41.9880, longitude: -87.7050),
            description: "Modern playground with age-appropriate equipment, swings, slides, and climbing structures. Safe and fun for all ages.",
            address: "6366 N Western Ave, Chicago, IL 60659",
            phone: "(312) 742-7529",
            hours: "6am-11pm Daily"
        ),
        
        // Healthcare & Services
        LocationPin(
            name: "West Ridge Health Center",
            category: .healthcare,
            coordinate: CLLocationCoordinate2D(latitude: 41.9920, longitude: -87.7000),
            description: "Community health center offering pediatric services, women's health, and family care. Convenient for local families.",
            address: "6323 N California Ave, Chicago, IL 60659",
            phone: "(773) 465-3100",
            hours: "Mon-Fri: 8am-5pm"
        ),
        
        // Additional Cafes (Rogers Park / West Ridge vicinity)
        LocationPin(
            name: "The Common Cup",
            category: .cafe,
            coordinate: CLLocationCoordinate2D(latitude: 42.0017, longitude: -87.6619),
            description: "Cozy neighborhood cafe with a relaxed vibe, good coffee, and light bites. Kid-friendly and welcoming to families.",
            address: "1501 W Morse Ave, Chicago, IL 60626",
            phone: "(773) 338-0256",
            hours: "Daily: 7am-6pm"
        ),
        LocationPin(
            name: "Ellipsis Coffeehouse",
            category: .cafe,
            coordinate: CLLocationCoordinate2D(latitude: 41.9986, longitude: -87.6612),
            description: "Local coffeehouse featuring espresso drinks, pastries, and study-friendly seating. Great spot to relax with kids.",
            address: "1259 W Devon Ave, Chicago, IL 60660",
            phone: "(773) 942-6341",
            hours: "Daily: 7am-7pm"
        ),
        LocationPin(
            name: "Oromo Cafe",
            category: .cafe,
            coordinate: CLLocationCoordinate2D(latitude: 41.9975, longitude: -87.6644),
            description: "Artisanal coffee and creative lattes with vegan-friendly treats. Warm atmosphere and friendly staff.",
            address: "4703 N Lincoln Ave (Edgewater/nearby area has pop-ups)",
            phone: nil,
            hours: "Check local hours"
        ),
        LocationPin(
            name: "Kopi Cafe",
            category: .cafe,
            coordinate: CLLocationCoordinate2D(latitude: 41.9989, longitude: -87.6645),
            description: "Eclectic cafe with a global vibe, vegetarian-friendly menu, and comfy seating. Lovely for a quiet break.",
            address: "5317 N Clark St, Chicago, IL 60640",
            phone: "(773) 989-5674",
            hours: "Daily: 8am-9pm"
        ),
        LocationPin(
            name: "XO Espresso Bar",
            category: .cafe,
            coordinate: CLLocationCoordinate2D(latitude: 41.9980, longitude: -87.6735),
            description: "Modern espresso bar with specialty drinks and light snacks. Kid-friendly staff and quick service.",
            address: "6940 N Glenwood Ave, Chicago, IL 60626",
            phone: nil,
            hours: "Daily: 7am-5pm"
        ),
        
        // Trails / Nature Access Points
        LocationPin(
            name: "North Shore Channel Trail - Devon Access",
            category: .activity,
            coordinate: CLLocationCoordinate2D(latitude: 41.9972, longitude: -87.7038),
            description: "Paved multi-use trail along the North Shore Channel. Great for strollers, biking, and nature walks.",
            address: "W Devon Ave & N Kedzie Ave, Chicago, IL 60645",
            phone: nil,
            hours: "6am-11pm Daily"
        ),
        LocationPin(
            name: "North Shore Channel Trail - Lincoln Village",
            category: .activity,
            coordinate: CLLocationCoordinate2D(latitude: 41.9909, longitude: -87.7074),
            description: "Scenic trail segment with easy access and river views. Family-friendly with gentle grades.",
            address: "Lincoln Village area near N McCormick Blvd, Chicago, IL 60659",
            phone: nil,
            hours: "6am-11pm Daily"
        ),
        LocationPin(
            name: "River Park Trailhead",
            category: .park,
            coordinate: CLLocationCoordinate2D(latitude: 41.9762, longitude: -87.7022),
            description: "Park at the confluence of the North Branch and North Shore Channel with trails, playgrounds, and open space.",
            address: "5100 N Francisco Ave, Chicago, IL 60625",
            phone: "(312) 742-7529",
            hours: "6am-11pm Daily"
        ),
        LocationPin(
            name: "Loyola Park Lakefront Trail Access",
            category: .activity,
            coordinate: CLLocationCoordinate2D(latitude: 42.0078, longitude: -87.6560),
            description: "Access point to the lakefront trail with beach views and wide paths. Great for strollers and kids.",
            address: "1230 W Greenleaf Ave, Chicago, IL 60626",
            phone: "(312) 742-PLAY",
            hours: "6am-11pm Daily"
        )
    ]
    
    // Computed property for filtered locations
    var filteredLocations: [LocationPin] {
        var locations = allLocations
        
        // Filter by search text
        if !searchText.isEmpty {
            locations = locations.filter { location in
                location.name.localizedCaseInsensitiveContains(searchText) ||
                location.description.localizedCaseInsensitiveContains(searchText) ||
                location.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            locations = locations.filter { $0.category == category }
        }
        
        return locations
    }
    
    // Slight deterministic offset to reduce exact overlap for very close points
    private func jitteredCoordinate(for pin: LocationPin) -> CLLocationCoordinate2D {
        // Use UUID hash to generate a tiny offset
        let hash = pin.id.uuidString.hashValue
        // Convert to small deltas (~5-10 meters depending on latitude)
        let latDelta = (Double((hash & 0xFF)) - 128.0) / 1_000_000.0
        let lonDelta = (Double(((hash >> 8) & 0xFF)) - 128.0) / 1_000_000.0
        return CLLocationCoordinate2D(latitude: pin.coordinate.latitude + latDelta,
                                      longitude: pin.coordinate.longitude + lonDelta)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and Filter Bar
                    VStack(spacing: 12) {
                        // Search Bar
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "8B9A7E"))
                            
                            TextField("Search locations...", text: $searchText)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(hex: "8B9A7E"))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        // Category Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                // All Categories Button
                                FilterChip(
                                    title: "All",
                                    isSelected: selectedCategory == nil,
                                    icon: "list.bullet"
                                ) {
                                    selectedCategory = nil
                                }
                                
                                // Category Buttons
                                ForEach(LocationPin.LocationCategory.allCases, id: \.self) { category in
                                    FilterChip(
                                        title: category.displayName,
                                        isSelected: selectedCategory == category,
                                        icon: category.icon
                                    ) {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    .background(Color(hex: "F8F5EE"))
                    
                    // Map View
                    ZStack(alignment: .bottomTrailing) {
                        Map(
                            coordinateRegion: $region,
                            showsUserLocation: true,
                            annotationItems: filteredLocations
                        ) { location in
                            MapAnnotation(coordinate: jitteredCoordinate(for: location)) {
                                Button {
                                    if selectedLocation?.id == location.id {
                                        // second tap opens detail
                                        showLocationDetail = true
                                    } else {
                                        selectedLocation = location
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        // Larger hit target
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 44, height: 44)
                                                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                                            Image(systemName: location.category.icon)
                                                .font(.system(size: selectedLocation?.id == location.id ? 22 : 18))
                                                .foregroundColor(location.category.color)
                                        }
                                        .offset(y: -6)
                                        
                                        // Show label only for the selected pin to reduce overlap
                                        if selectedLocation?.id == location.id {
                                            Text(location.name)
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 4)
                                                .background(Color.white.opacity(0.98))
                                                .cornerRadius(6)
                                                .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .frame(maxWidth: 90)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .ignoresSafeArea(edges: .top)
                        
                        // Map Controls
                        VStack(spacing: 10) {
                            // Show List Button
                            Button {
                                showListSheet = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("List")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .frame(height: 36)
                                .padding(.horizontal, 12)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            // Center on User Location Button
                            Button(action: {
                                if let userLocation = locationManager.location {
                                    withAnimation {
                                        region.center = userLocation.coordinate
                                        region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    }
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            // Reset View Button
                            Button(action: {
                                withAnimation {
                                    region = MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.7000),
                                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                                    )
                                }
                            }) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 100)
                    }
                    
                    // Results Count
                    if !searchText.isEmpty || selectedCategory != nil {
                        HStack {
                            Text("\(filteredLocations.count) location\(filteredLocations.count == 1 ? "" : "s") found")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(hex: "F8F5EE"))
                    }
                }
                
                // Bottom Nav overlaid so it doesn’t steal vertical space from the map
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
                .ignoresSafeArea(edges: .bottom)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                // Request location permission
                locationManager.requestLocation()
                
                // Ensure the map is centered on Chicago 60659
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 41.9900, longitude: -87.7000),
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
            }
            .sheet(isPresented: $showLocationDetail) {
                if let location = selectedLocation {
                    LocationDetailSheet(location: location)
                }
            }
            .sheet(isPresented: $showListSheet) {
                LocationListSheet(
                    locations: filteredLocations,
                    onSelect: { loc in
                        selectedLocation = loc
                        region.center = loc.coordinate
                        showListSheet = false
                    }
                )
            }
        }
    }
    
}

// MARK: - LocationPin
struct LocationPin: Identifiable {
    let id = UUID()
    let name: String
    let category: LocationCategory
    let coordinate: CLLocationCoordinate2D
    let description: String
    let address: String
    let phone: String?
    let hours: String?
    
    enum LocationCategory: String, CaseIterable {
        case park
        case library
        case cafe
        case restaurant
        case community
        case beach
        case market
        case activity
        case healthcare
        
        var icon: String {
            switch self {
            case .park: return "figure.play"
            case .library: return "book.fill"
            case .cafe: return "cup.and.saucer.fill"
            case .restaurant: return "fork.knife"
            case .community: return "building.2.fill"
            case .beach: return "beach.umbrella.fill"
            case .market: return "cart.fill"
            case .activity: return "figure.skating"
            case .healthcare: return "cross.case.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .park: return Color(hex: "8B9A7E")
            case .library: return Color(hex: "5C3D2E")
            case .cafe: return Color(hex: "9BA897")
            case .restaurant: return Color(hex: "9BA897")
            case .community: return Color(hex: "8B9A7E")
            case .beach: return Color(hex: "8B9A7E")
            case .market: return Color(hex: "9BA897")
            case .activity: return Color(hex: "8B9A7E")
            case .healthcare: return Color(hex: "5C3D2E")
            }
        }
        
        var displayName: String {
            switch self {
            case .park: return "Park"
            case .library: return "Library"
            case .cafe: return "Cafe"
            case .restaurant: return "Restaurant"
            case .community: return "Community"
            case .beach: return "Beach"
            case .market: return "Market"
            case .activity: return "Activity"
            case .healthcare: return "Healthcare"
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : Color(hex: "5C3D2E"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: "8B9A7E") : Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

// MARK: - Location Detail Sheet
struct LocationDetailSheet: View {
    let location: LocationPin
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with icon
                    HStack(spacing: 16) {
                        Image(systemName: location.category.icon)
                            .font(.system(size: 40))
                            .foregroundColor(location.category.color)
                            .frame(width: 70, height: 70)
                            .background(location.category.color.opacity(0.2))
                            .cornerRadius(14)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(location.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            Text(location.category.displayName)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "8B9A7E"))
                        }
                    }
                    .padding(.top, 10)
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        Text(location.description)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                            .lineSpacing(4)
                    }
                    
                    // Address
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(Color(hex: "8B9A7E"))
                                .font(.system(size: 18))
                            Text(location.address)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                        }
                    }
                    
                    // Phone Number
                    if let phone = location.phone {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contact")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            Button(action: {
                                if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(Color(hex: "8B9A7E"))
                                        .font(.system(size: 18))
                                    Text(phone)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "8B9A7E"))
                                }
                            }
                        }
                    }
                    
                    // Hours
                    if let hours = location.hours {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hours")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(Color(hex: "8B9A7E"))
                                    .font(.system(size: 18))
                                Text(hours)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            openInMaps()
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                Text("Get Directions")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "8B9A7E"))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            shareLocation()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up.fill")
                                Text("Share Location")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "8B9A7E"), lineWidth: 2)
                            )
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
            .background(Color(hex: "F8F5EE"))
            .navigationTitle("Location Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [shareText])
            }
        }
    }
    
    private var shareText: String {
        var text = "\(location.name)\n"
        text += "\(location.category.displayName)\n\n"
        text += "\(location.description)\n\n"
        text += "📍 \(location.address)"
        if let phone = location.phone {
            text += "\n📞 \(phone)"
        }
        return text
    }
    
    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func shareLocation() {
        showShareSheet = true
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - List Sheet for crowded areas
private struct LocationListSheet: View {
    let locations: [LocationPin]
    var onSelect: (LocationPin) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(locations, id: \.id) { loc in
                Button {
                    onSelect(loc)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: loc.category.icon)
                            .foregroundColor(loc.category.color)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            Text(loc.address)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Locations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    MapView()
}
