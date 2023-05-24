import SwiftUI
import CoreData

struct TopicsNavigationView: View {
    let topic:ContentSection
    @State private var isShowingConfiguration = false

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            NavigationView {
                
                //This is the list placed in the split navigation screen.
                //The 2nd NavigationView below (for iPhone without split nav) will present the topics on the first screen the user sees
                List(topic.subSections) { contentSection in
                    NavigationLink(destination: ContentSectionView(contentSection: contentSection)) {
                        Text(contentSection.name)
                    }
                    .disabled(!contentSection.isActive)
                }
                
                List(topic.subSections) { contentSection in
                    NavigationLink(destination: ContentSectionView(contentSection: contentSection)) {
                        Text(contentSection.name)
                    }
                    .disabled(!contentSection.isActive)
                    //.navigationViewStyle(DoubleColumnNavigationViewStyle())
                    //the font that shows on the scrolling list of links
                    .navigationTitle(topic.name)//.font(.caption)
                    //.navigationBarTitleDisplayMode(.inline)

                }
                .sheet(isPresented: $isShowingConfiguration) {
                    ConfigurationView(isPresented: $isShowingConfiguration)
                }
                .navigationTitle(topic.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingConfiguration = true
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }

            }
        }
        else {
            NavigationView {
                List(topic.subSections) { contentSection in
                    NavigationLink(destination: ContentSectionView(contentSection: contentSection)) {
                        Text(contentSection.name)
                    }
                    .disabled(!contentSection.isActive)
                }
                .sheet(isPresented: $isShowingConfiguration) {
                    ConfigurationView(isPresented: $isShowingConfiguration)
                }
                .navigationTitle(topic.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingConfiguration = true
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
        }
    }
}
