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
    
    init(parent:Topic?, level: Int, number:Int, name:String, contentType:Int? = nil) {
        self.parent = parent
        self.name = name
        self.level = level
        self.number = number
        self.contentType = contentType
        
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
            subTopics.append(Topic(parent: self, level: level+1, number: 0, name:"Example 1"))
            subTopics.append(Topic(parent: self, level: level+1, number: 1, name:"Example 2"))
        }
        if level == 0 {
            
        }
    }
}

class SyllabusPersistance {
    static public let shared = SyllabusPersistance()
    
    init() {
        //super.init()
//        if let dev = UserDefaults.standard.string(forKey: "GPSDeviceName") {
//            self.deviceName = dev
//        }
    }
    
    func test() {
        let db = Firestore.firestore()
        getSyllabus()
    }
    
    func getSyllabus() {
        print("trying set data...")
        let db = Firestore.firestore()
        
        db.collection("1syllabus").document("LA").setData([
            "name": "Los Angeles",
            "state": "CA",
            "country": "USA"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        print("trying read data...")

        db.collection("syllabus").getDocuments() { (querySnapshot, err) in
            if let q = querySnapshot {
                print(q.count)
                for document in q.documents {
                    print(document.description, document.data())
                }
            }
            else {
                print("No documents")
            }

//                for document in querySnapshot!.documents {
//                    if let locationName = document.get("locationName") {
//                        let visits = document.get("visits") as! NSDictionary
//                        var location:LocationRecord?
//                        for (key, _) in visits {
//                            let visitNum = visits[key] as! NSDictionary
//                            let datetime = visitNum["datetime"] as! Double
//                            let lat = visitNum["lat"] as! Double
//                            let lng = visitNum["lng"] as! Double
//                            let pictureSet = PictureSet(pictures: [])
//                            if let location = location {
//                                let visit = LocationVisitRecord(deviceName: visitNum["device"] as! String, datetime: datetime, lat: lat, lng: lng)
//                                location.visits.append(visit)
//                            }
//                            else {
//                                location = LocationRecord(id:document.documentID, locationName: locationName as! String, datetime: datetime, lat: lat, lng: lng, pictureSet: pictureSet)
//                            }
//                            visitCnt += 1
//                        }
//
//                        if let location = location {
//                            LocationRecords.shared.addLocation(location: location)
//                            let pictureURL = document.get("pictureURL")
//                            if let url = pictureURL {
//                                location.pictureURL = url as? String
//                                pictureLocations.append(location)
//                            }
//                        }
//                        locationCnt += 1
//                    }
//                    MessageHandler.shared.setStatus("Loaded \(locationCnt) locations, \(visitCnt) visits")
//                }
//            }
//
//            // load pictures
//            //https://firebase.google.com/docs/storage/ios/download-files
//
//            DispatchQueue.main.async {
//                for location in pictureLocations {
//                    if let url = location.pictureURL {
//                        let storage = Storage.storage()
//                        let httpsReference = storage.reference(forURL: url)
//                        httpsReference.getData(maxSize: 32 * 1024 * 1024) { data, error in
//                            if let error = error {
//                                MessageHandler.shared.reportError(context: "Load pictures", error.localizedDescription)
//                            } else {
//                                if let data = data {
//                                    location.pictureSet.pictures.append(data)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
        }
    }

}

class Syllabus {
    static public let shared = Syllabus()
}
