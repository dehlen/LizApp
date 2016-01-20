import Foundation
import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger.defaultInstance()
	
    log.xcodeColorsEnabled = true
    log.xcodeColors = [
        .Verbose: .lightGrey,
        .Debug: .darkGrey,
        .Info: .darkGreen,
        .Warning: .orange,
        .Error: XCGLogger.XcodeColor(fg: UIColor.redColor(), bg: UIColor.whiteColor()),
        .Severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0))
    ]
		
	#if USE_NSLOG
        log.removeLogDestination(XCGLogger.Constants.baseConsoleLogDestinationIdentifier)
	    log.addLogDestination(XCGNSLogDestination(owner: log, identifier: XCGLogger.Constants.nslogDestinationIdentifier))
	    log.logAppDetails()
	#else
	    let logPath: NSURL = appDelegate.cacheDirectory.URLByAppendingPathComponent("Liz-Log.txt")
	    log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: logPath)
	#endif
	
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
    dateFormatter.locale = NSLocale.currentLocale()
    log.dateFormatter = dateFormatter
	
    return log
}()

let cacheDirectory: NSURL = {
	let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
	return urls[urls.endIndex - 1] 
}()