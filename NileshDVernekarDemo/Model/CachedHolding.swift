
import Foundation
import CoreData

@objc(CachedHolding)
public class CachedHolding: NSManagedObject {
    @NSManaged public var symbol: String
    @NSManaged public var quantity: Int64
    @NSManaged public var ltp: Double
    @NSManaged public var avgPrice: Double
    @NSManaged public var close: Double
    @NSManaged public var cachedAt: Date

    // Convert to UserHolding
    func toUserHolding() -> UserHolding {
        return UserHolding(
            symbol: symbol,
            quantity: Int(quantity),
            ltp: ltp,
            avgPrice: avgPrice,
            close: close
        )
    }

    // Create from UserHolding
    static func from(_ holding: UserHolding, context: NSManagedObjectContext) -> CachedHolding {
        let cachedHolding = CachedHolding(context: context)
        cachedHolding.symbol = holding.symbol
        cachedHolding.quantity = Int64(holding.quantity)
        cachedHolding.ltp = holding.ltp
        cachedHolding.avgPrice = holding.avgPrice
        cachedHolding.close = holding.close
        cachedHolding.cachedAt = Date()
        return cachedHolding
    }
}
