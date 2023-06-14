import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import AVFoundation

class ContentSection: Identifiable {
    let id = UUID()
    var name: String = ""
    var title: String
    var subSections:[ContentSection] = []
    var sectionType:SectionType
    var parent:ContentSection?
    var isActive:Bool
    var level:Int
    var instructions:String = ""
    var hints = ""
    
    enum SectionType {
        case none
        case grade
        case testType
        case example
    }
    
    init(parent:ContentSection?, type:SectionType, name:String, title:String? = nil, isActive:Bool = true) {
        self.parent = parent
        self.sectionType = type
        self.name = name
        level = 0
        self.isActive = isActive
        var par = parent
        while par != nil {
            level += 1
            par = par!.parent
        }
        if let title = title {
            self.title = title
        }
        else {
            self.title = name
        }
        
//          App will be licensed by grade now so dont show all grades
//        if level == 0 {
//            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Pre Preliminary"))
//            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Preliminary"))
//            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Grade 1", isActive: true))
//            for i in 2..<9 {
//                subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Grade \(i)"))
//            }
//        }
        if level == 0 {
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Intervals Visual", title:"Recognising Visual Intervals"))
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Clapping", title:"Tapping At Sight"))
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Playing", title: "Playing At Sight"))
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Intervals Aural", title:"Recognising Aural Intervals")) 
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Echo Clap"))
        }
        let exampleData = ExampleData.shared
        if let parent = parent {
            var key = "\(parent.name).\(name).Instructions"
            if exampleData.data.keys.contains(key) {
                self.instructions = exampleData.data[key]!
            }
            key = "\(parent.name).\(name).Hints"
            if exampleData.data.keys.contains(key) {
                self.hints = exampleData.data[key]!
            }
        }
        
        if level == 1 {
            for i in 1...32 {
                addExample(exampleNum:i)
            }
        }
    }
    
    //Add an example number if the data for it exists
    func addExample(exampleNum:Int) {
        let exampleName = "Example \(exampleNum)"
        var key = self.name+"."+exampleName
        if parent != nil {
            //key = "Musicianship."+parent!.name+"."+key//TODO fix this...
            key = parent!.name+"."+key
        }
        let exampleData = ExampleData.shared.getData(key: key, warnNotFound: false)
        if exampleData == nil {
            return
        }
        subSections.append(ContentSection(parent: self, type: SectionType.example, name:exampleName, isActive: true))
    }
}

class FirestorePersistance {
    static public let shared = FirestorePersistance()
    
    init() {
    }
    
    func test() {
        getSyllabus()
    }
    
//    func saveClaps(data: [ClapRecorder.DecibelBufferRow]) {
//        let db = Firestore.firestore()
//        
//        db.collection("claps").document("claps").setData([
//            "data": data
//        ]) { err in
//            if let err = err {
//                Logger.logger.reportError("Error writing document", err as NSError)
//            } else {
//                print("Document successfully written!")
//            }
//        }
//    }
    
    func getSyllabus() {
        print("trying set data...")
        let collection = "Clapping"
        let db = Firestore.firestore()
        
        db.collection(collection).document("LA").setData([
            "sample": "USA"
        ]) { err in
            if let err = err {
                Logger.logger.reportError(self, "Error writing document", err as NSError)
            } else {
                print("Document successfully written!")
            }
        }
        
        print("trying read data...")

        db.collection(collection).getDocuments() { (querySnapshot, err) in
            if let q = querySnapshot {
                print(q.count)
                for document in q.documents {
                    print(document.description, document.data())
                }
            }
            else {
                print("No documents")
            }

        }
    }

}

class Syllabus {
    static public let shared = Syllabus()
}
