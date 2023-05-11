
import Foundation

class ExampleData {
    static var shared = ExampleData()
    var data = [String: String]()
    
    init() {
        data["Example 1"] = "72,76"
        data["test"] = "71,72,76,79"
        data["TestClap"] = "2,2,0,1,1,2,0,1,1,2,0,4"
    }
    
    func get(_ key: String) -> String! {
        return data[key]
    }
}
