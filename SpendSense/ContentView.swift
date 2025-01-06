//
//  ContentView.swift
//  SpendSense
//
//  Created by Srujan Sannidhi on 1/5/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = true
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    
    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
            } else if !hasCompletedSetup {
                SetupView()
            } else {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem {
                            Image(systemName: "chart.pie.fill")
                            Text("Dashboard")
                        }
                        .tag(0)
                    
                    TransactionsView()
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("Transactions")
                        }
                        .tag(1)
                    
                    GoalsView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Goals")
                        }
                        .tag(2)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(3)
                }
                .accentColor(colorScheme == .dark ? .mint : .blue)
            }
        }
        .onAppear {
            // Simulate loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

// Loading screen view
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text("SpendSense")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Loading your finances...")
                .foregroundColor(.secondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct AddTransactionButton: View {
    @State private var showingAddTransaction = false
    
    var body: some View {
        Button(action: { showingAddTransaction = true }) {
            Image(systemName: "plus.circle.fill")
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
}

struct AddGoalButton: View {
    @State private var showingAddGoal = false
    
    var body: some View {
        Button(action: { showingAddGoal = true }) {
            Image(systemName: "plus.circle.fill")
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView()
        }
    }
}

#Preview {
    ContentView()
}
