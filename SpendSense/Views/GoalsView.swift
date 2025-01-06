import SwiftUI

struct GoalsView: View {
    @StateObject private var goalsStore = GoalsStore.shared
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky Header
            VStack(alignment: .leading, spacing: 12) {
                Text("Savings Goals")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                
                Text("Track your progress and save more")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            if goalsStore.goals.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 48))
                        .foregroundColor(primaryColor)
                    
                    Text("No Savings Goals Yet")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    
                    Text("Start by adding your first savings goal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(goalsStore.goals) { goal in
                        GoalRowView(goal: goal)
                            .listRowBackground(Color(.systemBackground))
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 8)
                    }
                    .onDelete(perform: deleteGoal)
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemBackground).opacity(0.95))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddGoalButton()
            }
        }
    }
    
    private func deleteGoal(at offsets: IndexSet) {
        goalsStore.deleteGoals(at: offsets)
    }
}

struct GoalRowView: View {
    let goal: Goal
    @State private var showingContributeSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var progress: Double {
        goal.currentAmount / goal.targetAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(primaryColor)
                    .frame(width: 40, height: 40)
                    .background(primaryColor.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading) {
                    Text(goal.name)
                        .font(.system(size: 16, weight: .semibold))
                    if let deadline = goal.deadline {
                        Text(deadline, style: .date)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(goal.currentAmount, specifier: "%.2f")")
                        .font(.system(size: 16, weight: .medium))
                    Text("/ $\(goal.targetAmount, specifier: "%.2f")")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: progress)
                .tint(primaryColor)
            
            Button(action: { showingContributeSheet = true }) {
                Text("Contribute")
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(primaryColor)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingContributeSheet) {
            ContributeToGoalView(goal: goal)
        }
    }
}

#Preview {
    GoalsView()
}

#Preview("Goal Row") {
    GoalRowView(goal: Goal(name: "Sample Goal", targetAmount: 1000, currentAmount: 250, deadline: nil, icon: "star.fill"))
} 