import Foundation

class GoalsStore: ObservableObject {
    static let shared = GoalsStore()
    
    @Published private(set) var goals: [Goal] = []
    private let defaults = UserDefaults.standard
    private let goalsKey = "savedGoals"
    
    init() {
        loadGoals()
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoals(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
        saveGoals()
    }
    
    private func loadGoals() {
        guard let data = defaults.data(forKey: goalsKey),
              let savedGoals = try? JSONDecoder().decode([Goal].self, from: data) else {
            return
        }
        goals = savedGoals
    }
    
    private func saveGoals() {
        guard let data = try? JSONEncoder().encode(goals) else { return }
        defaults.set(data, forKey: goalsKey)
    }
    
    func clearAll() {
        goals = []
        saveGoals()
    }
    
    func contributeToGoal(_ goal: Goal, amount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            var updatedGoal = goal
            updatedGoal.currentAmount += amount
            goals[index] = updatedGoal
            saveGoals()
        }
    }
} 