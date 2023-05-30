
import Foundation

class ExampleData {
    static var shared = ExampleData()
    var data = [String: String]()
    
    init() {
        //data["Intervals Visual.test"] = "(72,.5) (74,.5) (71,2) (66,.5) (64,.5) (69,2)"
        //data["Intervals Visual.test"] = "(69,2) (72,.5) (76,.5) (71,2) (76,.5) (74,.5)"
        //data["Intervals Visual.test"] = "(60,.5) (62,.5) (64,1)"
        //data["Musicianship.Grade 1"] = "A B C D"

        data["Musicianship.Grade 1.Intervals Visual.Example 1"] = "(TS,3,4) (72,1) (74,2)"
        data["Musicianship.Grade 1.Intervals Visual.Example 2"] = "(TS,4,4) (74,2) (71,2)"
        data["Musicianship.Grade 1.Intervals Visual.Example 3"] = "(TS,3,4) (69,1) (67,2)"
        data["Musicianship.Grade 1.Intervals Visual.Example 4"] = "(TS,2,4) (67,1) (64,1)"
        data["Musicianship.Grade 1.Intervals Visual.Example 5"] = "(TS,3,4) (69,1) (72,2)"
        data["Musicianship.Grade 1.Intervals Visual.Example 6"] = "(TS,C) (69,2) (72,2)"

        data["Musicianship.Grade 1.Playing.Example 1"] = "(64,1) (62,1) (60,.5) (62,.5) (64,1) (B) (67,2) (67,2) (B) (65,1) (67,1) (64,1) (62,1) (B) (60,4) "
        data["Musicianship.Grade 1.Playing.Example 2x"] = "(TS,2,4) (67,1) (65,1) (B) (65,1) (65,1) (B) (65,4)"
        data["Musicianship.Grade 1.Playing.Example 2"] = "(TS,3,4) (67,1) (65,1) (64,1) (B) (65,1) (64,1) (62,.5) (60,.5) (B) (64,2) (67,1) (B) (60,3) "
        data["Musicianship.Grade 1.Playing.Example 3"] = "(K) (TS,3,4) (67,1) (69,1) (71,1) (B) (72,1) (71,1) (69,1) (B) (71,2) (69,1) (B) (67,3) "
        data["Musicianship.Grade 1.Playing.Example 4"] = "(K) (TS,4,4) (71,1) (67,.5) (69,.5) (71,1) (72,1) (B) (74,1) (72,1) (71,1) (69,1) (B) (71,2) (72,1) (69,1) (B) (67,4)"
        data["Musicianship.Grade 1.Playing.Example 5"] = "(K) (TS,3,4) (67,1) (69,1) (71,1) (B) (74,2) (71,1) (B) (72,.5) (74,.5) (71,1) (69,1) (B) (67,3)"
        data["Musicianship.Grade 1.Playing.Example 6"] = "(TS,4,4) (67,1) (65,1) (64,1) (62,1) (B) (60,1) (64,1) (65,1) (67,1) (B) (65,2) (62,2) (B) (60,4)"
        data["Musicianship.Grade 1.Playing.Example 7"] = "(TS,4,4) (72,2) (72,2) (B) (76,1) (74,1) (72,2) (B) (74,.5) (76,.5) (79,2) (76,1) (B) (72,4)"
        data["Musicianship.Grade 1.Playing.Example 8"] = "(K) (TS,3,4) (67,1) (69,1) (71,1) (B) (72,1) (74,2) (B) (71,2) (69,1) (B) (67,3)"
        data["Musicianship.Grade 1.Playing.Example 9"] = "(K) (TS,4,4) (67,1) (71,1) (74,2) (B) (72,2) (71,2) (B) (72,1) (74,.5) (72,.5) (71,1) (69,1) (B) (67,4)"
        data["Musicianship.Grade 1.Playing.Example 10"] = "(TS,4,4) (79,1) (76,1) (72,2) (B) (74,2) (76,2) (B) (77,1) (79,2) (76,1) (B) (72,4)"
        
        //data["Musicianship.Grade 1.Playing.Example 7"] = "(K) (TS,3,4) () () () () () () () () () () () () () () () () () () () () () () () () ()"

        data["Musicianship.Grade 1.Clapping.Example 1"] = data["Musicianship.Grade 1.Playing.Example 1"]
        data["Musicianship.Grade 1.Clapping.Example 2"] = data["Musicianship.Grade 1.Playing.Example 2"]
        data["Musicianship.Grade 1.Clapping.Example 3"] = data["Musicianship.Grade 1.Playing.Example 3"]
        data["Musicianship.Grade 1.Clapping.Example 4"] = data["Musicianship.Grade 1.Playing.Example 4"]
        data["Musicianship.Grade 1.Clapping.Example 5"] = data["Musicianship.Grade 1.Playing.Example 5"]
        data["Musicianship.Grade 1.Clapping.Example 6"] = data["Musicianship.Grade 1.Playing.Example 6"]
        data["Musicianship.Grade 1.Clapping.Example 7"] = data["Musicianship.Grade 1.Playing.Example 7"]
        data["Musicianship.Grade 1.Clapping.Example 8"] = data["Musicianship.Grade 1.Playing.Example 8"]
        data["Musicianship.Grade 1.Clapping.Example 9"] = data["Musicianship.Grade 1.Playing.Example 9"]
        data["Musicianship.Grade 1.Clapping.Example 10"] = data["Musicianship.Grade 1.Playing.Example 10"]

        data["Musicianship.Grade 1.Intervals Aural.Example 1"] = "(72,1) (74,1)"
        data["Musicianship.Grade 1.Intervals Aural.Example 2"] = "(74,1) (76,1)"
        data["Musicianship.Grade 1.Intervals Aural.Example 3"] = "(72,1) (76,1)"
        data["Musicianship.Grade 1.Intervals Aural.Example 4"] = "(65,1) (69,1)"

        data["Musicianship.Grade 1.Echo Clap.Example 1"] = data["Musicianship.Grade 1.Playing.Example 1"]
        data["Musicianship.Grade 1.Echo Clap.Example 2"] = data["Musicianship.Grade 1.Playing.Example 2"]
        data["Musicianship.Grade 1.Echo Clap.Example 3"] = data["Musicianship.Grade 1.Playing.Example 3"]
        data["Musicianship.Grade 1.Echo Clap.Example 4"] = data["Musicianship.Grade 1.Playing.Example 4"]
        data["Musicianship.Grade 1.Echo Clap.Example 5"] = data["Musicianship.Grade 1.Playing.Example 5"]
        data["Musicianship.Grade 1.Echo Clap.Example 6"] = data["Musicianship.Grade 1.Playing.Example 6"]
        data["Musicianship.Grade 1.Echo Clap.Example 7"] = data["Musicianship.Grade 1.Playing.Example 7"]
        data["Musicianship.Grade 1.Echo Clap.Example 8"] = data["Musicianship.Grade 1.Playing.Example 8"]
        data["Musicianship.Grade 1.Echo Clap.Example 9"] = data["Musicianship.Grade 1.Playing.Example 9"]
        data["Musicianship.Grade 1.Echo Clap.Example 10"] = data["Musicianship.Grade 1.Playing.Example 10"]

        //data["Intervals Visual.test"] = data["Musicianship.Grade 1.Intervals Visual.Example 1"]
        //data["Playing.test"] = data["Musicianship.Grade 1.Playing.Example 1"]
        //data["Clapping.test"] = data["Musicianship.Grade 1.Playing.Example 1"]
        
        data["test_interval"] = data["Musicianship.Grade 1.Intervals Visual.Example 1"]
        data["test_clap"] = "(K) (TS,4,4) (71,1) (67,.5) (69,.5) (71,1) (72,1) (B) (74,1)"
        data["test_aural_interval"] = data["Musicianship.Grade 1.Intervals Visual.Example 1"]
        
        //data["test_clap"] = "(71,1) (67,.5) (69,.5) (71,1) (71,1) (B) (72,2)"

        //data["test"]      = data["Musicianship.Grade 1.Intervals Visual.Example 1"]
    }
    
    func get(contentSection:ContentSection) -> [Any]! {
        var current = contentSection
        var key = ""
        while true {
            key = current.name + key
            let par = current.parent
            if par == nil {
                break
            }
            current = par!
            key = "." + key
        }
        //print("--->Example key", key)
        return getData(key: key)
    }
    
    //func get_old(grade:String, testType:String, exampleKey: String) -> [Any]! {
    
    func getData(key:String) -> [Any]! {
        //let key = grade+"."+testType+"."+exampleKey
        let data = data[key]
        guard data != nil else {
            Logger.logger.reportError(self, "No data for \(key)")
            return nil
        }
        //data = data!.replacingOccurrences(of: " ", with: "")
        let tuples = data!.components(separatedBy: " ")

        var result:[Any] = []
        for entry in tuples {
            var tuple = entry.replacingOccurrences(of: "(", with: "")
            tuple = tuple.replacingOccurrences(of: ")", with: "")
            let parts = tuple.components(separatedBy: ",")
            if parts.count == 2  {
                let notePitch:Int? = Int(parts[0])
                if let notePitch = notePitch {
                    //let pitch = Int(parts[0])
                    let value = Double(parts[1]) ?? 1
                    //if let pitch = pitch {
                        result.append(Note(num: notePitch, value: value))
                    //}
                }
                else {
                    if parts[0] == "TS" {
                        var ts = TimeSignature(top: 4, bottom: 4)
                        ts.isCommonTime = true
                        result.append(result.append(ts))
                    }

                }
            }
            else {
                if parts.count == 1 {
                    if parts[0] == "K" {
                        result.append(KeySignature(type: .sharp, count: 1))
                    }
                    if parts[0] == "B" {
                        result.append(BarLine())
                    }
                }
                if parts.count == 3 {
                    result.append(TimeSignature(top: Int(parts[1]) ?? 0, bottom: Int(parts[2]) ?? 0))
                }
            }
        }
        return result
    }
}
