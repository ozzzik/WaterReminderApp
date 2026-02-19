import SwiftUI
import StoreKit

/// Debug tools for subscription testing
/// ONLY visible when running from Xcode (#if DEBUG)
/// NOT included in production builds
#if DEBUG
struct DebugSubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var diagnosticReport = ""
    @State private var showingReport = false
    
    var body: some View {
        Form {
            // Current State
            currentStateSection
            
            // Products
            productsSection
            
            // Actions
            actionsSection
            
            // Diagnostics
            diagnosticsSection
        }
        .navigationTitle("Debug Tools")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReport) {
            diagnosticReportView
        }
    }
    
    // MARK: - Current State Section
    
    private var currentStateSection: some View {
        Section("Current State") {
            HStack {
                Text("Status")
                Spacer()
                Text(subscriptionManager.subscriptionStatus.displayText)
                    .foregroundColor(statusColor)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Premium Active")
                Spacer()
                Image(systemName: subscriptionManager.isPremiumActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(subscriptionManager.isPremiumActive ? .green : .red)
            }
            
            if let subscription = subscriptionManager.currentSubscription {
                HStack {
                    Text("Current Plan")
                    Spacer()
                    Text(subscription.displayName)
                        .foregroundColor(.secondary)
                }
            }
            
            if let expiration = subscriptionManager.expirationDate {
                HStack {
                    Text("Expires")
                    Spacer()
                    Text(expiration, style: .relative)
                        .foregroundColor(.secondary)
                }
                
                Text(expiration.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Products Section
    
    private var productsSection: some View {
        Section("Products") {
            if subscriptionManager.products.isEmpty {
                HStack {
                    ProgressView()
                    Text("Loading products...")
                        .foregroundColor(.secondary)
                }
            } else {
                ForEach(subscriptionManager.products) { product in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(product.displayName)
                                .font(.headline)
                            Spacer()
                            Text(product.displayPrice)
                                .foregroundColor(.blue)
                        }
                        
                        Text("ID: \(product.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(product.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Button("Reload Products") {
                Task {
                    await subscriptionManager.loadProducts()
                }
            }
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        Section("Actions") {
            Button {
                Task {
                    await subscriptionManager.updateSubscriptionStatus()
                }
            } label: {
                Label("Refresh Status", systemImage: "arrow.clockwise")
            }
            
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                Label("Restore Purchases", systemImage: "purchased.circle")
            }
            .disabled(subscriptionManager.isLoading)
            
            Button(role: .destructive) {
                clearLocalData()
            } label: {
                Label("Clear Local Data", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Diagnostics Section
    
    private var diagnosticsSection: some View {
        Section("Diagnostics") {
            Button {
                Task {
                    await runDiagnostics()
                }
            } label: {
                Label("Run Full Diagnostics", systemImage: "stethoscope")
            }
            
            if !diagnosticReport.isEmpty {
                Button {
                    showingReport = true
                } label: {
                    Label("View Last Report", systemImage: "doc.text.magnifyingglass")
                }
            }
        }
    }
    
    // MARK: - Diagnostic Report View
    
    private var diagnosticReportView: some View {
        NavigationView {
            ScrollView {
                Text(diagnosticReport)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Diagnostic Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        showingReport = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Copy") {
                        UIPasteboard.general.string = diagnosticReport
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var statusColor: Color {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed:
            return .green
        case .notSubscribed:
            return .orange
        case .expired:
            return .red
        case .inGracePeriod:
            return .yellow
        }
    }
    
    // MARK: - Helper Functions
    
    private func clearLocalData() {
        // Clear subscription-related UserDefaults
        let keysToRemove = [
            "trialStartDate",
            "trialUsed",
            "subscriptionStatus",
            "recentPurchaseDate"
        ]
        
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        print("🧹 Cleared local subscription data")
        
        // Refresh status
        Task {
            await subscriptionManager.updateSubscriptionStatus()
        }
    }
    
    private func runDiagnostics() async {
        var report = "=== SUBSCRIPTION DIAGNOSTIC REPORT ===\n"
        report += "Generated: \(Date().formatted())\n\n"
        
        // App State
        report += "--- APP STATE ---\n"
        report += "Status: \(subscriptionManager.subscriptionStatus.displayText)\n"
        report += "Premium Active: \(subscriptionManager.isPremiumActive)\n"
        report += "Loading: \(subscriptionManager.isLoading)\n"
        if let error = subscriptionManager.errorMessage {
            report += "Error: \(error)\n"
        }
        report += "\n"
        
        // Current Subscription
        report += "--- CURRENT SUBSCRIPTION ---\n"
        if let subscription = subscriptionManager.currentSubscription {
            report += "Product: \(subscription.displayName)\n"
            report += "ID: \(subscription.id)\n"
            report += "Price: \(subscription.displayPrice)\n"
        } else {
            report += "No active subscription\n"
        }
        if let expiration = subscriptionManager.expirationDate {
            report += "Expires: \(expiration.formatted())\n"
        }
        report += "\n"
        
        // Products
        report += "--- LOADED PRODUCTS ---\n"
        report += "Count: \(subscriptionManager.products.count)\n"
        for product in subscriptionManager.products {
            report += "\nProduct: \(product.displayName)\n"
            report += "  ID: \(product.id)\n"
            report += "  Price: \(product.displayPrice)\n"
            report += "  Type: \(product.type)\n"
        }
        report += "\n"
        
        // StoreKit Entitlements
        report += "--- STOREKIT ENTITLEMENTS ---\n"
        var foundEntitlements = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                foundEntitlements = true
                
                report += "\nEntitlement Found:\n"
                report += "  Product ID: \(transaction.productID)\n"
                report += "  Transaction ID: \(transaction.id)\n"
                report += "  Purchase Date: \(transaction.purchaseDate.formatted())\n"
                if let expiration = transaction.expirationDate {
                    report += "  Expiration: \(expiration.formatted())\n"
                    report += "  Is Expired: \(expiration < Date())\n"
                }
                if let revocation = transaction.revocationDate {
                    report += "  Revoked: \(revocation.formatted())\n"
                }
                report += "  Environment: \(transaction.environment)\n"
            } catch {
                report += "\nEntitlement verification failed: \(error)\n"
            }
        }
        
        if !foundEntitlements {
            report += "No active entitlements found\n"
        }
        report += "\n"
        
        // UserDefaults
        report += "--- USER DEFAULTS ---\n"
        let keys = ["trialStartDate", "trialUsed", "subscriptionStatus", "recentPurchaseDate"]
        for key in keys {
            if let value = UserDefaults.standard.object(forKey: key) {
                report += "\(key): \(value)\n"
            }
        }
        report += "\n"
        
        report += "=== END REPORT ===\n"
        
        diagnosticReport = report
        showingReport = true
        
        print(report)
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        DebugSubscriptionView()
            .environmentObject(SubscriptionManager.shared)
    }
}
#endif
















