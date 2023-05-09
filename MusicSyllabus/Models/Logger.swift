import Foundation

class Logger {
    static var logger = Logger()
    var ctr = 0
    
    func reportError(_ context:String, _ err:Error? = nil) {
        var msg = "ERROR ======== \(context)"
        if let err = err {
            print(msg, err.localizedDescription)
        }
        else {
            print(msg)
        }
    }
    
    func log(_ msg:String) {
        ctr += 1
        print(ctr, "=>", msg)
    }
}
