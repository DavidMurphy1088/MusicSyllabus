import Foundation
import FirebaseFirestore
import FirebaseCore
//import FirebaseAuth
import FirebaseStorage
import AVFoundation

class Topic: Identifiable {
    let id = UUID()
    let name: String
    var subtopics:[Topic] = []
    init(_ nm:String) {
        name = nm
    }
}

class TopicList {
    var topics:[Topic] = []
    init() {
        for i in 0...7 {
            let t = Topic("Grade \(i+1)")
            topics.append(t)
            t.subtopics = [Topic("Test 1 - Intervals Visual"),
                           Topic("Test 2 - Clapping"),
                           Topic("Test 3 - Playing"),
                           Topic("Test 4 - Intervals Aural"),
                           Topic("Test 5 - Echo Clap")
            ]
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
