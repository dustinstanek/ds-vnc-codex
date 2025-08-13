import XCTest
@testable import HostAgent

final class HostAgentTests: XCTestCase {
    func testParseArgumentsParsesAllRequiredOptions() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let keyFile = tmpDir.appendingPathComponent("host_key.pub")
        try "TEST_KEY".write(to: keyFile, atomically: true, encoding: .utf8)

        let args = [
            "HostAgent",
            "--host-id", "123",
            "--broker-url", "ws://localhost:3000",
            "--key-path", keyFile.path
        ]

        guard let config = parseArguments(args) else {
            XCTFail("parseArguments returned nil")
            return
        }
        XCTAssertEqual(config.hostID, "123")
        XCTAssertEqual(config.brokerURL, URL(string: "ws://localhost:3000"))
        XCTAssertEqual(config.keyPath, keyFile.path)
    }

    func testParseArgumentsUsesDefaultKeyPath() {
        let args = [
            "HostAgent",
            "--host-id", "abc",
            "--broker-url", "ws://example.com"
        ]
        let config = parseArguments(args)
        XCTAssertNotNil(config)
        let expected = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".ds-vnc/keys/host_key.pub")
            .path
        XCTAssertEqual(config?.keyPath, expected)
    }

    func testParseArgumentsMissingRequired() {
        let args = ["HostAgent", "--broker-url", "ws://example.com"]
        XCTAssertNil(parseArguments(args))
    }
  
    func testBuildAuthPayloadCreatesJSON() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let keyFile = tmpDir.appendingPathComponent("host_key.pub")
        try "my-key\n".write(to: keyFile, atomically: true, encoding: .utf8)

        guard let data = buildAuthPayload(hostID: "abc", keyPath: keyFile.path) else {
            XCTFail("Expected payload data")
            return
        }
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(obj?["host_id"], "abc")
        XCTAssertEqual(obj?["key"], "my-key")
    }

    func testBuildAuthPayloadMissingKeyFile() {
        let data = buildAuthPayload(hostID: "abc", keyPath: "/nonexistent")
        XCTAssertNil(data)
    }
}
