
import Foundation

class ExampleData {
    static var shared = ExampleData()
    var data = [String: String]()
    
    init() {
        data["Intervals Visual.test"] = "(72,.5) (74,.5) (71,2) (69,2)"
        //data["Intervals Visual"] = ["a"]
        data["Intervals Visual.Example 1"] = "(72,2) (74,2)"
        data["Intervals Visual.Example 2"] = "(74.2),(71.2)"
        data["Intervals Visual.Example 3"] = "(69.2),(67.2)"
        data["Intervals Visual.Example 4"] = "(67.2),(64.2)"

        data["Clapping.test"] = "(64,1) (62,2) (60,.5) (62,.5) (64,1)"
        //data["Clapping.Example 1"] = "(0.2),(0.2),(),(0.1),(0.1),(0.2),(),(0.1),(0.1),(0.2),(),(0.4)"
        data["Clapping.Example 1"] = "(64,1) (62,1) (60,1) (62,1) (64,1)"

        data["Playing.test"] = "(0.2),(0.2),(),(0.1),(0.1),(0.2),(),(0.1),(0.1),(0.2),(),(0.4)"
    }
    
    func get(_ testType:String, _ exampleKey: String) -> [Any]! {
        let key = testType+"."+exampleKey
        let data = data[key]
        guard data != nil else {
            return nil
        }
        //data = data!.replacingOccurrences(of: " ", with: "")
        let tuples = data!.components(separatedBy: " ")
        var result:[Any] = []
        for entry in tuples {
            var tuple = entry.replacingOccurrences(of: "(", with: "")
            tuple = tuple.replacingOccurrences(of: ")", with: "")
            let parts = tuple.components(separatedBy: ",")
            if parts.count > 1 {
                let pitch = Int(parts[0])
                let value = Double(parts[1])
                if let pitch = pitch {
                    result.append(Note(num: pitch, value: value))
                }
            }
            if parts.count == 1 {
                result.append(BarLine())
            }
        }
        return result
    }
}
