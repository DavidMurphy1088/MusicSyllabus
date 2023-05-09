import SwiftUI

struct TopicsViewNavigation: View {
    let topic:Topic
    
    var body: some View {
        NavigationView {
            VStack {
                List(topic.subTopics) { subtopic in
                    NavigationLink(destination: TopicsView(topic: subtopic)) {
                        Text(subtopic.name)
                    }
                }
                Spacer()
            }
            .navigationTitle(topic.name).font(.title3)
            //.navigationBarBackButtonHidden(false)
            //.navigationBarTitle(topic.name)
            //.navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TopicsView: View {
    let topic:Topic
    var contentType:Int?
    
    init(topic:Topic) {
        self.topic = topic
        var topic = topic
        while contentType == nil {
            if let t = topic.contentType {
                contentType = t
                break
            }
            if topic.parent == nil {
                break
            }
            topic = topic.parent!
        }
    }
    
    var body: some View {
        //NavigationView {
            VStack {
                if topic.subTopics.count > 0 {
                    List(topic.subTopics) { subtopic in
                        NavigationLink(destination: TopicsView(topic: subtopic)) {
                            Text(subtopic.name)
                        }
                    }
                    Spacer()
                }
                else {
                    if contentType == 1 {
                        IntervalsView(exampleNum: topic.number, questionData: topic.questionData)
                    }
                    if contentType == 2 {
                        RhythmsView(exampleNum: topic.number, questionData: topic.questionData)
                    }
                    //Text("No content")
                }
            }
            .navigationTitle(topic.name)
            //.navigationBarBackButtonHidden(false)
            //.navigationBarTitle(topic.name)
            //.navigationBarTitleDisplayMode(.inline)
        //}
    }
}

