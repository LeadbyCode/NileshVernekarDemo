import Foundation
import CoreData

class HoldingsPersistenceManager {

    // MARK: - Singleton

    static let shared = HoldingsPersistenceManager()

    private init() {
        print(" Core Data store location: \(storeURL.path)")
        print(" Core Data container initialized successfully")
    }

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HoldingsDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print(" Failed to initialize Core Data container: \(error.localizedDescription)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private var storeURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("holdings.sqlite")
    }

    // MARK: - Public Methods

    func saveHoldings(_ holdings: [UserHolding]) {
        let context = self.context

        deleteAllHoldings()

        for holding in holdings {
            _ = CachedHolding.from(holding, context: context)
        }

        do {
            try context.save()
            print("Saved \(holdings.count) holdings to Core Data")
        } catch {
            print("Failed to save holdings: \(error.localizedDescription)")
        }
    }

    func fetchHoldings() -> [UserHolding] {
        let context = self.context
        let fetchRequest: NSFetchRequest<CachedHolding> = CachedHolding.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]

        do {
            let cachedHoldings = try context.fetch(fetchRequest)
            let holdings = cachedHoldings.map { $0.toUserHolding() }
            print("Fetched \(holdings.count) holdings from Core Data")
            return holdings
        } catch {
            print("Failed to fetch holdings: \(error.localizedDescription)")
            return []
        }
    }

    func isCacheFresh(maxAgeInMinutes: Int = 60) -> Bool {
        let context = self.context
        let fetchRequest: NSFetchRequest<CachedHolding> = CachedHolding.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: false)]

        do {
            let holdings = try context.fetch(fetchRequest)
            guard let latestHolding = holdings.first else { return false }

            let ageInSeconds = Date().timeIntervalSince(latestHolding.cachedAt)
            let ageInMinutes = ageInSeconds / 60

            return ageInMinutes < Double(maxAgeInMinutes)
        } catch {
            return false
        }
    }

    // MARK: - Private Methods

    private func deleteAllHoldings() {
        let context = self.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedHolding.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("❌ Failed to delete holdings: \(error.localizedDescription)")
        }
    }
}

// MARK: - NSFetchRequest Extension

extension CachedHolding {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedHolding> {
        return NSFetchRequest<CachedHolding>(entityName: "CachedHolding")
    }
}
