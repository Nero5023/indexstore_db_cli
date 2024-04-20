import IndexStoreDB
import Foundation

let DEFAULT_LIB_INDEX_STORE = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

class IndexQuery {
    // static let libIndexStore = "/Applications/Xcode_15.1.0_15C65_fb.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

    static var libIndexStore: String = {
        let configPath = FileManager.default.currentDirectoryPath + "/config.json"
        return loadLibIndexStorePath(from: configPath) ?? DEFAULT_LIB_INDEX_STORE
    }()

    let indexStoreDB: IndexStoreDB

    init?(storePath: String, databasePath: String?) {
        do {
            let lib = try IndexStoreLibrary(dylibPath: Self.libIndexStore)
            let databasePath = databasePath ?? storePath + "/index-db"
            self.indexStoreDB = try IndexStoreDB(storePath: storePath, databasePath: databasePath, library: lib, waitUntilDoneInitializing: true)
        } catch {
            print("Failed to initialize IndexStoreDB: \(error)")
            return nil
        }
    }

    func getUSRs(ofSymbolName symbolName: String) -> [String] {
        let symbolOccurences = indexStoreDB.canonicalOccurrences(ofName: symbolName)
        return Array(Set(symbolOccurences.map { (occur) in
                occur.symbol.usr
        }))
    }

    func findReferences(_ symbolName: String) -> [String: [SymbolOccurrence]] {
        let usrs = getUSRs(ofSymbolName: symbolName)
        let tupleList: [(String, [SymbolOccurrence])] = usrs.map { (usr) in
            return (usr, indexStoreDB.occurrences(ofUSR: usr, roles: .reference))
        }
        return Dictionary(uniqueKeysWithValues: tupleList)
    }

    func findDefinition(_ symbolName: String) -> [String: SymbolOccurrence] {
        let usrs = getUSRs(ofSymbolName: symbolName)
        let tupleList: [(String, SymbolOccurrence)] = usrs.compactMap { (usr) in
            guard let defOccur = indexStoreDB.occurrences(ofUSR: usr, roles: .definition).first else {
                return nil
            }
            return (usr, defOccur)
        }
        return Dictionary(uniqueKeysWithValues: tupleList)
    }


    private static func loadLibIndexStorePath(from configPath: String) -> String? {
        guard let data = FileManager.default.contents(atPath: configPath) else {
            print("Configuration file not found.")
            return nil
        }
        do {
            let config = try JSONDecoder().decode(Configuration.self, from: data)
            return config.libIndexStore
        } catch {
            print("Failed to decode configuration: \(error)")
            return nil
        }
    }

    struct Configuration: Codable {
        var libIndexStore: String
    }
}
