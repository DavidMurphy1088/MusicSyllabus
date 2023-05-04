import Foundation

class Logger {
    static var logger = Logger()
    var ctr = 0
    
    func reportError(_ context:String, _ err:NSError) {
        print("ERROR ========", context, err.localizedDescription)
    }
    
    func log(_ msg:String) {
        ctr += 1
        print(ctr, "=>", msg)
    }
}
