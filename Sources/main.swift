import ArgumentParser
import Foundation


struct IndexStoreDBCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for indexstore_db_cli.",
        subcommands: [GenerateDB.self, GetUsr.self, FindReference.self, FindDefinition.self])

    init() { }
}


func getIndexQuery(storePath: String, databasePath: String?) -> IndexQuery {
    print("Generating database...")
    guard let indexQuery = IndexQuery(storePath: storePath, databasePath: databasePath) else {
        fatalError("Failed to create IndexQuery")
    }
    print("Done.")
    return indexQuery
}

struct GenerateDB: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Generate index store database.")

    @Argument(help: "Path to index store")
    var storePath: String

    @Argument(help: "Path to generate the index database")
    var databasePath: String?

    lazy var indexQuery: IndexQuery = {
        print("Generating database...")
        guard let indexQuery = IndexQuery(storePath: storePath, databasePath: databasePath) else {
            fatalError("Failed to create IndexQuery")
        }
        print("Done.")
        return indexQuery
    } ()

    mutating func run() throws {

        let _ = getIndexQuery(storePath: storePath, databasePath: databasePath)

    }
}

struct GetUsr: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Get USRs for a symbol name.")

    @Argument(help: "Symbol name to get USRs for")
    var symbolName: String

    @Argument(help: "Path to index store")
    var storePath: String

    @Argument(help: "Path to generate the index database")
    var databasePath: String?

    mutating func run() throws {
        let indexQuery = getIndexQuery(storePath: storePath, databasePath: databasePath)
        let usrs = indexQuery.getUSRs(ofSymbolName: self.symbolName)
        if usrs.isEmpty {
            print("No USRs found for \(self.symbolName)")
        } else {
            for usr in usrs {
                print("\t\(usr)")
            }
        }
    }
}

struct FindReference: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Find references for a symbol name.")

    @Argument(help: "Symbol name to get USRs for")
    var symbolName: String

    @Argument(help: "Path to index store")
    var storePath: String

    @Argument(help: "Path to generate the index database")
    var databasePath: String?

    mutating func run() throws {
        let indexQuery = getIndexQuery(storePath: storePath, databasePath: databasePath)
        for (usr, occurences) in indexQuery.findReferences(symbolName) {
            print("Name: \(symbolName)")
            print("USR: \(usr)")
            for occurence in occurences {
                let path = URL.init(fileURLWithPath: occurence.location.path)
                print("\t\(path.lastPathComponent) \(occurence.location.line):\(occurence.location.utf8Column)")
            }
        }
    }
}


struct FindDefinition: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Find references for a symbol name.")

    @Argument(help: "Symbol name to get USRs for")
    var symbolName: String

    @Argument(help: "Path to index store")
    var storePath: String

    @Argument(help: "Path to generate the index database")
    var databasePath: String?

    mutating func run() throws {
        let indexQuery = getIndexQuery(storePath: storePath, databasePath: databasePath)
        for (usr, occurence) in indexQuery.findDefinition(symbolName) {
            print("Name: \(symbolName)")
            print("USR: \(usr)")
            print("\tType: \(occurence.symbol.kind)")
            let path = URL.init(fileURLWithPath: occurence.location.path)
            print("\t\(path.lastPathComponent) \(occurence.location.line):\(occurence.location.utf8Column)")
        }
    }
}


IndexStoreDBCLI.main()
