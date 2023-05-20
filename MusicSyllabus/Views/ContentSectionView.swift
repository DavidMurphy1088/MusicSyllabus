import SwiftUI


struct ContentSectionView: View {
    var contentSection:ContentSection
    var parentSection:ContentSection? // the parent of this section that describes the test type
    
    init(contentSection:ContentSection) {
        self.contentSection = contentSection
        var parentType:ContentSection? = contentSection

        while parentType != nil {
            if parentType!.sectionType == ContentSection.SectionType.testType {
                self.parentSection = parentType!
                break
            }
            parentType = parentType!.parent
        }
        //print("ContentSectionView", contentSection.name, contentSection.subSections.count, "parentType", parentType?.name)
    }
    
    var body: some View {
        VStack {
            //Text("contentSection.subSections.count \(String(contentSection.subSections.count))")
            if contentSection.subSections.count > 0 {
                VStack {
                    //Text("contentSection.subSections")
                    List(contentSection.subSections) { subtopic in
                        NavigationLink(destination: ContentSectionView(contentSection: subtopic)) {
                            Text(subtopic.name)
                            //.navigationBarTitle("Title").font(.largeTitle)
                            //.navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
            }
            else {
                if let parentSection = parentSection {
                    if parentSection.sectionType == ContentSection.SectionType.testType {
                        if parentSection.name.contains("Intervals Visual") {
                            IntervalsView(contentSection: contentSection)
                        }
                        if parentSection.name.contains("Clapping") {
                            ClapOrPlay(mode: .clap, contentSection: contentSection)
                            //QuestionAndAnswerView(contentSection: contentSection)
                        }
                        if parentSection.name.contains("Playing") {
                            ClapOrPlay(mode: .play, contentSection: contentSection)
                        }
                    }
                }
             }
        }
        //.navigationTitle("XX").foregroundColor(.red)
        .navigationBarTitle(contentSection.name, displayMode: .inline)//.font(.title)
    }
}

