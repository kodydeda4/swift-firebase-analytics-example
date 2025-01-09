// Copyright © 2020 Pocket Radar. All rights reserved.

import Foundation
import Logging

public enum Loggers {
  private static var buffer: [String] = []
  private static var bufferLimit = 0
  
  public static func initalize(retainLimit: Int) {
    assert(retainLimit > 0)
    
    bufferLimit = retainLimit
    
    LoggingSystem.bootstrap { label in
      let bufferedHandler = BufferLogHandler(level: .debug, appender: Loggers.appendToRecentLogs)
      let standardHandler = StreamLogHandler.standardOutput(label: label)
      
      return MultiplexLogHandler([
        standardHandler,
        bufferedHandler,
      ])
    }
  }
  
  static func recentLogs() -> [String] {
    guard Thread.isMainThread else {
      assertionFailure("recentLogs accessed from background thread")
      return []
    }
    
    return buffer
  }
  
  static func appendToRecentLogs(_ message: String) {
    DispatchQueue.main.async {
      buffer.append(message)
      if buffer.count > bufferLimit {
        buffer.remove(at: 0)
      }
    }
  }
}

// With Logger, we get timstamps and consistent naming
// Having separate loggers allows us to control verbosity as desired
// While working on a particular feature, you may want to see more messages,
// but most of the time, we don't want to polute the console output
// e.g.
//   let coreData = Logger(label: "PRCoreData").updating { $0.logLevel = .debug }
// or
//   Loggers.coreData.logLevel = trace
//
// The default Logger.logLevel is .info.
//
// We'll evolve how we use the different log levels over time. My initial thinking is that
//  .critical is a singificant logic error that we need to fix
//  .error is an error, but isn't nessarily a logic error. E.g. network failures
//  .info is a generally interesting state of the system that's (barely) worth seeing in the console
//  .debug is genrally hidden, but useful to tracking things down
//  .trace is noisy
//
public extension Loggers {
  static var `default` = Logger(label: "Sports")
  static var computerVisionClient = Logger(label: "ComputerVisionClient")
  static var firebaseClient = Logger(label: "FirebaseClient")
}

extension Logger: Updatable {}

extension Logger {
  public func withLogLevel(_ level: Logger.Level) -> Logger {
    var updated = self
    updated.logLevel = level
    return updated
  }
}

public struct BufferLogHandler: LogHandler {
  public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
    get {
      metadata[key]
    }
    set(newValue) {
      metadata[key] = newValue
    }
  }
  
  public var metadata: Logger.Metadata = .init()
  public var logLevel: Logger.Level = .info
  private var bufferedLogLevel: Logger.Level = .info
  public let appendToBuffer: (String) -> Void
  
  public init(level: Logger.Level, appender: @escaping (String) -> Void) {
    logLevel = level
    bufferedLogLevel = level
    appendToBuffer = appender
  }
  
  public func log(
    level: Logger.Level,
    message: Logger.Message,
    metadata: Logger.Metadata?,
    source: String,
    file: String,
    function: String,
    line: UInt
  ) {
    guard level >= bufferedLogLevel else {
      return
    }
    
    let date = DateFormatter.measurementFormatter.string(from: Date())
    let message = "\(date) \(level) \(message.description)"
    
    appendToBuffer(message)
    
    // This BS is just to pass the swiftformat linter.
    // We can't replace the function argument labels above with underscores. It confuses the compiler and causes
    // the logging system to call itself recursively until the app explodes.
    let meta = metadata?.description ?? ""
    var output = NullOutputStream()
    print("\(file):\(line) \(function) \(source) \(meta)", to: &output)
  }
  
  struct NullOutputStream: TextOutputStream {
    mutating func write(_: String) {}
  }
}

protocol Updatable {}

extension Updatable {
  func updating(_ body: (inout Self) -> Void) -> Self {
    var updatable = self
    body(&updatable)
    return updatable
  }
}

extension NSObjectProtocol {
  func updating(_ body: (Self) -> Void) -> Self {
    body(self)
    return self
  }
}

public extension DateFormatter {
  static let measurementFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .init(abbreviation: "UTC")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return dateFormatter
  }()
}

public extension Result {
  var logDescription: String {
    switch self {
    case .success:
      return "success"
    case .failure:
      return "failure"
    }
  }
}
