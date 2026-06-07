//
//  ExportImportView.swift
//  178FlavoMemo
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Backup and restore screen for JSON and CSV data.
struct ExportImportView: View {
    @ObservedObject var viewModel: TastingViewModel

    @State private var showingImporter = false
    @State private var importMerge = true
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var exportDocument: ExportDocument?

    var body: some View {
        ZStack {
            AppScreenBackground()

            ScrollView {
                VStack(spacing: 16) {
                    AppElevatedCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Export Data", systemImage: "square.and.arrow.up.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.accent)
                            Text("Back up all tastings, templates, and collections.")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)

                            backupStatRow(label: "Tastings", value: "\(viewModel.tastings.count)")
                            backupStatRow(label: "Templates", value: "\(viewModel.templates.count)")
                            backupStatRow(label: "Collections", value: "\(viewModel.collections.count)")

                            Button("Export JSON") { exportJSON() }
                                .buttonStyle(AppSecondaryButtonStyle())
                            Button("Export CSV") { exportCSV() }
                                .buttonStyle(AppSecondaryButtonStyle())
                        }
                    }

                    AppElevatedCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Import Data", systemImage: "square.and.arrow.down.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.success)
                            Text("Restore from a previously exported JSON backup file.")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)

                            Toggle("Merge with existing data", isOn: $importMerge)
                                .tint(AppColors.success)

                            Button("Import JSON") { showingImporter = true }
                                .buttonStyle(AppPrimaryButtonStyle())
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Backup")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .sheet(item: $exportDocument) { document in
            ShareSheet(items: [document.url])
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func backupStatRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(AppColors.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.primaryText)
        }
    }

    private func exportJSON() {
        do {
            let data = try viewModel.exportJSONData()
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("flavor_memo_backup_\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: url, options: .atomic)
            exportDocument = ExportDocument(url: url)
        } catch {
            showAlert(title: "Export Failed", message: error.localizedDescription)
        }
    }

    private func exportCSV() {
        let csv = viewModel.exportCSVString()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("flavor_memo_tastings_\(Int(Date().timeIntervalSince1970)).csv")

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportDocument = ExportDocument(url: url)
        } catch {
            showAlert(title: "Export Failed", message: error.localizedDescription)
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            showAlert(title: "Import Failed", message: error.localizedDescription)
        case .success(let urls):
            guard let url = urls.first else { return }

            do {
                let didStartAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didStartAccess { url.stopAccessingSecurityScopedResource() }
                }

                let data = try Data(contentsOf: url)
                let bundle = try ExportImportService().importJSON(data: data)
                viewModel.importBundle(bundle, merge: importMerge)
                showAlert(title: "Import Complete", message: "Imported \(bundle.tastings.count) tastings.")
            } catch {
                showAlert(title: "Import Failed", message: error.localizedDescription)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

private struct ExportDocument: Identifiable {
    let id = UUID()
    let url: URL
}

/// UIKit share sheet wrapper for export files.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ExportImportView(viewModel: TastingViewModel())
    }
}
