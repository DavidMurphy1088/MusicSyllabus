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
            if contentSection.subSections.count > 0 {
                VStack {
                    List(contentSection.subSections) { subtopic in
                        NavigationLink(destination: ContentSectionView(contentSection: subtopic)) {
                            VStack {
                                Text(subtopic.title).padding()
                                //Text("___")
                                //.navigationBarTitle("Title").font(.largeTitle)
                                //.navigationBarTitleDisplayMode(.inline)
                            }
                        }
                    }
                }
            }
            else {
                if let parentSection = parentSection {
                    if parentSection.sectionType == ContentSection.SectionType.testType {
                        if parentSection.name.contains("Intervals Visual") {
                           IntervalView(
                                mode: QuestionMode.intervalVisual,
                                contentSection: contentSection
                            )
                        }
                        if parentSection.name.contains("Clapping") {
                            ClapOrPlayView (
                                mode: QuestionMode.rhythmClap,
                                 //presentType: IntervalPresentView.self,
                                 //answerType: IntervalAnswerView.self,
                                 contentSection: contentSection
                             )

                        }
                        if parentSection.name.contains("Playing") {
                            ClapOrPlayView (
                                mode: QuestionMode.rhythmPlay,
                                 //presentType: IntervalPresentView.self,
                                 //answerType: IntervalAnswerView.self,
                                 contentSection: contentSection
                             )
                        }
                        if parentSection.name.contains("Intervals Aural") {
                           IntervalView(
                                mode: QuestionMode.intervalAural,
                                contentSection: contentSection
                            )
                        }
                        if parentSection.name.contains("Echo Clap") {
                            ClapOrPlayView (
                                mode: QuestionMode.rhythmEchoClap,
                                 contentSection: contentSection
                             )
                        }
                    }
                }
             }
        }
        //.navigationTitle("XX").foregroundColor(.red)
        .navigationBarTitle(contentSection.title, displayMode: .inline)//.font(.title)
    }
}

