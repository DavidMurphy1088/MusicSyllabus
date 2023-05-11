import SwiftUI

struct TopicsViewNavigation: View {
    let topic:ContentSection
    
    var body: some View {
        NavigationView {
            VStack {
                List(topic.subSections) { subtopic in
                    NavigationLink(destination: ContentSectionView(contentSection: subtopic)) {
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

struct ContentSectionView: View {
    var contentSection:ContentSection
    var parentSection:ContentSection // the parent of this section that describes the test type
    
    init(contentSection:ContentSection) {
        self.contentSection = contentSection
        parentSection = ContentSection(parent: nil, type: ContentSection.SectionType.none, name: "")
        var parentType:ContentSection? = contentSection

        while parentType != nil {
            if parentType!.sectionType == ContentSection.SectionType.testType {
                self.parentSection = parentType!
                break
            }
            parentType = parentType!.parent
        }
//        print("Init ", contentSection.name, contentSection.sectionType, "subs", contentSection.subSections.count,
//              "parentType", parentSection.sectionType, parentSection.name)
    }
    
    var body: some View {
        VStack {
            if contentSection.subSections.count > 0 {
                List(contentSection.subSections) { subtopic in
                    NavigationLink(destination: ContentSectionView(contentSection: subtopic)) {
                        Text(subtopic.name)
                    }
                }
                Spacer()
            }
            else {
                if parentSection.sectionType == ContentSection.SectionType.testType {
                    if parentSection.name.contains("Intervals Visual") {
                        IntervalsView(contentSection: contentSection)
                    }
                    if parentSection.name.contains("Clapping") {
                        RhythmsView(contentSection: contentSection)
                    }
                }
             }
        }
        .navigationTitle(contentSection.name)
    }
}

