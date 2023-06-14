import SwiftUI

struct ContentSectionHeaderView: View {
    var contentSection:ContentSection
    @State private var isHelpPresented = false
    var help:String = "In the exam you will be shown three notes and be asked to identify the intervals as either a second or a third."
    
    var body: some View {
        VStack {
            Text("ContentSectionView Level:\(contentSection.level) name:\(contentSection.name) name:\(contentSection.title)").font(.title)
                .fontWeight(.bold)
                .padding()
            if contentSection.level == 1 {
                HStack {
                    Text(contentSection.instructions)
                        //.font(.body)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .padding()
                }
                Button(action: {
                    isHelpPresented.toggle()
                }) {
                    HStack {
                        Text("Hints")
                        Image(systemName: "questionmark.circle")
                            .font(.largeTitle)
                    }
                }
                .popover(isPresented: $isHelpPresented, arrowEdge: .bottom) {
                    VStack {
                        Text("Hints")
                            .font(.title2)
                        Text(contentSection.hints).padding()
                        Button(action: {
                            isHelpPresented = false
                        }) {
                            Text("Close")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    //.shadow(radius: 5)
                }
                .padding()
            }
        }
    }
}
    
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
            ContentSectionHeaderView(contentSection: contentSection)
            if contentSection.subSections.count > 0 {
                VStack {
                    List(contentSection.subSections) { subtopic in
                        NavigationLink(destination: ContentSectionView(contentSection: subtopic)) {
                            VStack {
                                Text(subtopic.title).padding()
                                //Text("___")
                                //.navigationBarTitle("Title").font(.largeTitle)
                                //.navigationBarTitleDisplayMode(.inline)
                                    .font(.title2)
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

