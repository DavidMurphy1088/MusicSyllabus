import SwiftUI


struct TopicsView: View {
    let title:String
    let topics:[Topic]
    
    var body: some View {
        NavigationView {
            
            List(topics) { topic in
                NavigationLink(destination: TopicsView(title: "Topics", topics: topic.subtopics)) {
                    Text(topic.name)
                }
            }
            .navigationTitle(title)
        }
    }
            
//    var body1: some View {
//        NavigationView {
//            List(topics) { topic in
//                if topic.subtopics.count == 0 {
//                    NavigationLink(destination: TopicDetail(name: topic.name)) {
//                        Text(topic.name)
//                    }
//                }
//                else {
//                    VStack {
//                        Text(topic.name)
//                        List(topic.subtopics, id: \.self) { item in
//                            Text(item)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Musicianship")
//        }
//    }

}

struct TopicDetail: View {
    let name: String

    var body: some View {
        Text("You selected \(name)")
            .navigationTitle(name)
    }
}

//===========================================

struct ListItem: Identifiable {
    let id = UUID()
    let name: String
    var subItems: [String]
}

struct TopicsView1: View {
    let items = [
        ListItem(name: "Fruits", subItems: ["Apple", "Banana", "Orange"]),
        ListItem(name: "Vegetables", subItems: ["Carrot", "Tomato", "Broccoli"]),
        ListItem(name: "Meat", subItems: ["Chicken", "Beef", "Pork"])
    ]
    @State private var toggleStates = ToggleStates()
    @State private var topExpanded: Bool = false

    var body: some View {
        List(items) { item in
            DisclosureGroup(item.name) {
                VStack {
                    Text("Sub-item 1")
                    NavigationLink(destination: TopicDetail(name: "XXX")) {
                        Text("XXXXX")
                    }
                    List(item.subItems, id: \.self) { subItem in
                        Text(subItem)
                    }
                    Text("x")
                }
            }
        }
    }
    struct ToggleStates {
        var oneIsOn: Bool = false
        var twoIsOn: Bool = true
    }

    var body1: some View {
        DisclosureGroup("Items", isExpanded: $topExpanded) {
            Toggle("Toggle 1", isOn: $toggleStates.oneIsOn)
            Toggle("Toggle 2", isOn: $toggleStates.twoIsOn)
            DisclosureGroup("Sub-items") {
                Text("Sub-item 1")
            }
        }
    }
}
