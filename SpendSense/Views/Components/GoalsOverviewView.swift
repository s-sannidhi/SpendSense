import SwiftUI

struct GoalsOverviewView: View {
    @StateObject private var goalsStore = GoalsStore.shared
    @State private var selectedGoal: Goal?
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Savings Goals")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    GoalsView()
                }
                .font(.subheadline)
            }
            
            if goalsStore.goals.isEmpty {
                Text("No active savings goals")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(goalsStore.goals) { goal in
                            GoalCardView(goal: goal)
                                .onTapGesture {
                                    selectedGoal = goal
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
        .sheet(item: $selectedGoal) { goal in
            ContributeToGoalView(goal: goal)
        }
    }
}

struct GoalCardView: View {
    let goal: Goal
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    private var progress: Double {
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
                
                Spacer()
                
                if let deadline = goal.deadline {
                    Text(deadline, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(goal.name)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(1)
            
            ProgressView(value: progress)
                .tint(primaryColor)
            
            HStack {
                Text("$\(goal.currentAmount, specifier: "%.0f")")
                    .font(.system(size: 14, weight: .medium))
                Text("/ $\(goal.targetAmount, specifier: "%.0f")")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(primaryColor)
            }
        }
        .padding()
        .frame(width: 200)
        .background(.background)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
} 