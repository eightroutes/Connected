import SwiftUI

struct ParksApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List(parks) { park in
                    NavigationLink(park.name, value: park)
                }
                .navigationDestination(for: Park.self) { park in
                    ParkDetails(park: park)
                }
            }
        }
    }
}

struct Park: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let imageURL: URL
}

let parks = [
    Park(name: "Yosemite National Park", description: "Famous for its granite cliffs, waterfalls, and giant sequoia groves.", imageURL: URL(string: "https://example.com/yosemite.jpg")!),
    Park(name: "Yellowstone National Park", description: "Known for its geysers, hot springs, and diverse wildlife.", imageURL: URL(string: "https://example.com/yellowstone.jpg")!),
    Park(name: "Grand Canyon National Park", description: "A vast canyon carved by the Colorado River over millions of years.", imageURL: URL(string: "https://example.com/grandcanyon.jpg")!),
    // Add more parks here
]

struct ParkDetails: View {
    let park: Park
    
    var body: some View {
        VStack {
            AsyncImage(url: park.imageURL)
            Text(park.name)
                .font(.title)
            Text(park.description)
                .padding()
        }
    }
}

struct ParksApp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List(parks) { park in
                NavigationLink(park.name, value: park)
            }
            .navigationDestination(for: Park.self) { park in
                ParkDetails(park: park)
            }
        }
    }
}
