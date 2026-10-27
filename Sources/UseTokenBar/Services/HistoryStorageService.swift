import Foundation

public struct PersistentStoreData: Codable {
    public var lastTrackingDay: Date
    public var dailyRecords: [DailyUsageRecord]
    public var timelinePoints: [TokenDataPoint]
    public var todayTotalTokens: Int

    public init(
        lastTrackingDay: Date = Calendar.current.startOfDay(for: Date()),
        dailyRecords: [DailyUsageRecord] = [],
        timelinePoints: [TokenDataPoint] = [],
        todayTotalTokens: Int = 0
    ) {
        self.lastTrackingDay = lastTrackingDay
        self.dailyRecords = dailyRecords
        self.timelinePoints = timelinePoints
        self.todayTotalTokens = todayTotalTokens
    }
}

public final class HistoryStorageService {
    public static let shared = HistoryStorageService()

    private let fileManager = FileManager.default
    private let storageURL: URL

    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        let dir = appSupport.appendingPathComponent("UseTokenBar", isDirectory: true)

        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }

        self.storageURL = dir.appendingPathComponent("token_bar_history.json")
    }

    public func loadStore() -> PersistentStoreData {
        guard fileManager.fileExists(atPath: storageURL.path),
              let data = try? Data(contentsOf: storageURL),
              let store = try? JSONDecoder().decode(PersistentStoreData.self, from: data) else {
            return PersistentStoreData()
        }
        return store
    }

    public func saveStore(_ store: PersistentStoreData) {
        do {
            let data = try JSONEncoder().encode(store)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            // Ignore write errors gracefully
        }
    }

    public func recordDailyUsage(
        ide: String,
        agentName: String,
        modelName: String,
        tokens: Int,
        costUSD: Double,
        timestamp: Date = Date()
    ) {
        var store = loadStore()

        // Rollover if day has changed
        let todayStart = Calendar.current.startOfDay(for: Date())
        if !Calendar.current.isDate(store.lastTrackingDay, inSameDayAs: todayStart) {
            store.lastTrackingDay = todayStart
            store.timelinePoints = []
            store.todayTotalTokens = 0
        }

        let record = DailyUsageRecord(
            timestamp: timestamp,
            ide: ide,
            agentName: agentName,
            modelName: modelName,
            tokens: tokens,
            costUSD: costUSD
        )

        // Avoid exact duplicate timestamp + token records
        if !store.dailyRecords.contains(where: {
            abs($0.timestamp.timeIntervalSince(timestamp)) < 2 && $0.tokens == tokens && $0.agentName == agentName
        }) {
            store.dailyRecords.insert(record, at: 0)
            if store.dailyRecords.count > 100 {
                store.dailyRecords = Array(store.dailyRecords.prefix(100))
            }
            saveStore(store)
        }
    }

    public func recordTimelinePoint(_ point: TokenDataPoint) {
        var store = loadStore()
        let todayStart = Calendar.current.startOfDay(for: Date())
        if !Calendar.current.isDate(store.lastTrackingDay, inSameDayAs: todayStart) {
            store.lastTrackingDay = todayStart
            store.timelinePoints = []
            store.todayTotalTokens = 0
        }

        // Monotonic guarantee for today's points
        if let last = store.timelinePoints.last {
            if point.timestamp.timeIntervalSince(last.timestamp) >= 15 {
                store.timelinePoints.append(point)
            } else if let lastIdx = store.timelinePoints.indices.last {
                store.timelinePoints[lastIdx] = point
            }
        } else {
            store.timelinePoints.append(point)
        }

        store.todayTotalTokens = max(store.todayTotalTokens, point.tokens)
        saveStore(store)
    }

    public func checkAndPerformDayRollover() -> (didRollover: Bool, store: PersistentStoreData) {
        var store = loadStore()
        let todayStart = Calendar.current.startOfDay(for: Date())

        if !Calendar.current.isDate(store.lastTrackingDay, inSameDayAs: todayStart) {
            store.lastTrackingDay = todayStart
            store.timelinePoints = []
            store.todayTotalTokens = 0
            saveStore(store)
            return (true, store)
        }

        return (false, store)
    }
}
