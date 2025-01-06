import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var targetAmount = ""
    @State private var deadline: Date = Date().addingTimeInterval(86400 * 30) // 30 days from now
    @State private var hasDeadline = false
    @State private var selectedIcon = "target"
    var onAdd: ((Goal) -> Void)?
    
    private let icons = [
        "star.fill", "car.fill", "house.fill", "graduationcap.fill",
        "airplane", "laptop", "gamecontroller.fill", "camera.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    TextField("Goal Name", text: $name)
                    
                    HStack {
                        Text("Target Amount")
                        Spacer()
                        #if os(iOS)
                        TextField("Amount", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("Amount", text: $targetAmount)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }
                
                Section {
                    Toggle("Set Deadline", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveGoal() }
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Double(targetAmount.replacingOccurrences(of: ",", with: ".")),
              !name.isEmpty else { return }
        
        let goal = Goal(
            name: name,
            targetAmount: amount,
            currentAmount: 0,
            deadline: hasDeadline ? deadline : nil,
            icon: selectedIcon
        )
        
        if let onAdd = onAdd {
            onAdd(goal)
        } else {
            GoalsStore.shared.addGoal(goal)
        }
        
        dismiss()
    }
} 