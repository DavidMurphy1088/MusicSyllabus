import Foundation

class Logger {
    static var logger = Logger()
    
    func reportError(_ context:String, _ err:NSError) {
        print("ERROR ========", context, err.localizedDescription)
    }
    
    func log(_ msg:String) {
    }
}
