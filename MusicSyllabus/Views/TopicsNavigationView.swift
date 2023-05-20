import SwiftUI
import CoreData

struct TopicsNavigationView: View {
    let topic:ContentSection
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List(topic.subSections) { subtopic in
                        NavigationLink(destination: ContentSectionView(contentSection: subtopic)) {
                        //NavigationLink(destination: QuestionAndAnswerView()) {
                            Text(subtopic.name)
                        }
                    }
                    Spacer()
                }
                //the font that shows on the scrolling list of links
                .navigationTitle(topic.name)//.font(.caption)
                //.navigationBarBackButtonHidden(false)
                //.navigationBarTitle(topic.name)
                //.navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
