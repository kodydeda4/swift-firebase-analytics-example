import Foundation

extension Result: Codable where Success: Codable, Failure: Codable & Error {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .success(let value):
      try container.encode(value, forKey: .success)
    case .failure(let error):
      try container.encode(error, forKey: .failure)
    }
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let successValue = try container.decodeIfPresent(Success.self, forKey: .success) {
      self = .success(successValue)
    } else if let failureValue = try container.decodeIfPresent(Failure.self, forKey: .failure) {
      self = .failure(failureValue)
    } else {
      throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unable to decode Result"))
    }
  }
  
  private enum CodingKeys: String, CodingKey {
    case success
    case failure
  }
}

func prettyPrintDescription<T: Codable>(_ value: T) -> String {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  
  let data = try! encoder.encode(value)
  let value = String(data: data, encoding: .utf8)!
  return value
}
