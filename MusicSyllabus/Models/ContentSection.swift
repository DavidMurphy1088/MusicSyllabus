import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import AVFoundation

class ContentSection: Identifiable {
    let id = UUID()
    var name: String = ""
    var subSections:[ContentSection] = []
    var sectionType:SectionType
    var parent:ContentSection?

    enum SectionType {
        case none
        case grade
        case testType
        case example
    }
    
    init(parent:ContentSection?, type:SectionType, name:String) {
        self.parent = parent
        self.sectionType = type
        self.name = name
        var level = 0
        var par = parent
        while par != nil {
            level += 1
            par = par!.parent
        }
        
        if level == 0 {
            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Pre Preliminary"))
            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Preliminary"))
            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Grade 1"))
            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Grade 2"))
            subSections.append(ContentSection(parent: self, type: SectionType.grade, name: "Grade 3"))
        }
        if level == 1 {
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Intervals Visual"))
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Clapping"))
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Playing"))
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Intervals Aural"))
            subSections.append(ContentSection(parent: self, type: SectionType.testType, name:"Echo Clap"))
        }
        if level == 2 {
            subSections.append(ContentSection(parent: self, type: SectionType.example, name:"Example 1"))
            subSections.append(ContentSection(parent: self, type: SectionType.example, name:"Example 2"))
            subSections.append(ContentSection(parent: self, type: SectionType.example, name:"Example 3"))
            subSections.append(ContentSection(parent: self, type: SectionType.example, name:"Example 4"))
        }
        if level == 0 {
            
        }
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
                Logger.logger.reportError("Error writing document", err as NSError)
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
