import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import AVFoundation

class Topic: Identifiable {
    let id = UUID()
    var name: String = ""
    var subTopics:[Topic] = []
    var level:Int
    var number:Int
    var parent:Topic?
    var contentType:Int?
    var questionData:String?
    
    init(parent:Topic?, level: Int, number:Int, name:String, contentType:Int? = nil, questionData:String? = nil) {
        self.parent = parent
        self.name = name
        self.level = level
        self.number = number
        self.contentType = contentType
        self.questionData = questionData
        
        if level == 0 {
            subTopics.append(Topic(parent: self, level: level+1, number: 0, name: "Pre Preliminary"))
            subTopics.append(Topic(parent: self, level: level+1, number: 0, name: "Preliminary"))
            subTopics.append(Topic(parent: self, level: level+1, number: 0, name: "Grade 1"))
            subTopics.append(Topic(parent: self, level: level+1, number: 1, name: "Grade 2"))
            subTopics.append(Topic(parent: self, level: level+1, number: 1, name: "Grade 3"))
        }
        if level == 1 {
            subTopics.append(Topic(parent: self, level: level+1, number: 0, name:"Test 1 - Intervals Visual", contentType: 1))
            subTopics.append(Topic(parent: self, level: level+1, number: 1, name:"Test 2 - Clapping", contentType: 2))
            subTopics.append(Topic(parent: self, level: level+1, number: 2, name:"Test 3 - Playing"))
            subTopics.append(Topic(parent: self, level: level+1, number: 3, name:"Test 4 - Intervals Aural"))
            subTopics.append(Topic(parent: self, level: level+1, number: 4, name:"Test 5 - Echo Clap"))
        }
        if level == 2 {
            subTopics.append(Topic(parent: self, level: level+1, number: 0, name:"Example 1", questionData: "72,74")) //
            subTopics.append(Topic(parent: self, level: level+1, number: 1, name:"Example 2", questionData: "74,71"))
            subTopics.append(Topic(parent: self, level: level+1, number: 1, name:"Example 3", questionData: "69,67"))
            subTopics.append(Topic(parent: self, level: level+1, number: 1, name:"Example 4", questionData: "67,64"))
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
