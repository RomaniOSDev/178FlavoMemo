//
//  TastingDetailView.swift
//  178FlavoMemo
//

import SwiftUI

/// Detailed view for a single tasting record.
struct TastingDetailView: View {
    @ObservedObject var viewModel: TastingViewModel
    let tasting: TastingModel

    @Environment(\.dismiss) private var dismiss
    @State private var showingEditForm = false
    @State private var showingTasteAgainForm = false
    @State private var showingDeleteConfirmation = false

    private var currentTasting: TastingModel {
        viewModel.tastings.first(where: { $0.id == tasting.id }) ?? tasting
    }

    private var history: [TastingModel] {
        viewModel.tastingHistory(for: currentTasting.drinkGroupId)
    }

    var body: some View {
        ZStack {
            AppScreenBackground()

            ScrollView {
                VStack(spacing: 16) {
                    heroHeader

                    if let photoFileName = currentTasting.photoFileName {
                        TastingPhotoPreview(photoFileName: photoFileName)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(AppGradients.cardBorder, lineWidth: 1)
                            )
                            .compositingGroup()
                            .shadow(
                                color: .black.opacity(AppCardElevation.hero.shadowOpacity),
                                radius: AppCardElevation.hero.shadowRadius,
                                x: 0,
                                y: AppCardElevation.hero.shadowY
                            )
                    }

                    AppElevatedCard {
                        VStack(spacing: 14) {
                            DetailInfoRow(icon: "tag.fill", title: "Type", value: currentTasting.type.rawValue)
                            if let variety = currentTasting.variety, !variety.isEmpty {
                                DetailInfoRow(icon: "leaf.fill", title: "Variety / Producer", value: variety)
                            }
                            HStack {
                                DetailInfoRow(icon: "star.fill", title: "Rating", value: "\(currentTasting.rating) of 5")
                                Spacer()
                                StarRatingView(rating: .constant(currentTasting.rating), starSize: 18, interactive: false)
                            }
                        }
                    }

                    if !currentTasting.flavorTags.isEmpty {
                        AppElevatedCard {
                            VStack(alignment: .leading, spacing: 10) {
                                AppSectionHeader(title: "Flavor Tags")
                                FlavorTagListView(tags: currentTasting.flavorTags)
                            }
                        }
                    }

                    if !currentTasting.flavorNotes.isEmpty {
                        AppElevatedCard {
                            DetailInfoRow(icon: "text.quote", title: "Aroma & Flavor Notes", value: currentTasting.flavorNotes)
                        }
                    }

                    AppElevatedCard {
                        VStack(spacing: 14) {
                            if let location = currentTasting.location, !location.isEmpty {
                                DetailInfoRow(icon: "mappin.and.ellipse", title: "Location", value: location)
                            }
                            DetailInfoRow(icon: "clock.fill", title: "Date & Time", value: DateFormatting.formatTastingDate(currentTasting.date))

                            if let brewMethod = currentTasting.brewMethod, !brewMethod.isEmpty {
                                DetailInfoRow(icon: "drop.fill", title: "Brew Method", value: brewMethod)
                            }
                            if let temperature = currentTasting.servingTemperature, !temperature.isEmpty {
                                DetailInfoRow(icon: "thermometer.medium", title: "Serving Temperature", value: temperature)
                            }
                            if let glassType = currentTasting.glassType, !glassType.isEmpty {
                                DetailInfoRow(icon: "wineglass.fill", title: "Glass Type", value: glassType)
                            }
                        }
                    }

                    if !currentTasting.collectionIds.isEmpty {
                        AppElevatedCard {
                            VStack(alignment: .leading, spacing: 10) {
                                AppSectionHeader(title: "Collections")
                                ForEach(currentTasting.collectionIds, id: \.self) { collectionId in
                                    Label(viewModel.collectionName(for: collectionId), systemImage: "folder.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.primaryText)
                                }
                            }
                        }
                    }

                    if history.count > 1 {
                        AppElevatedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                AppSectionHeader(title: "Tasting History")
                                ForEach(history) { entry in
                                    if entry.id != currentTasting.id {
                                        HStack(spacing: 12) {
                                            DrinkTypeIcon(type: entry.type, size: 40, photoFileName: entry.photoFileName)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(DateFormatting.formatTastingDate(entry.date))
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundStyle(AppColors.secondaryText)
                                                StarRatingView(rating: .constant(entry.rating), starSize: 14, interactive: false)
                                            }
                                            Spacer()
                                            RatingBadge(rating: entry.rating)
                                        }
                                        if entry.id != history.last?.id {
                                            Divider().overlay(AppColors.accent.opacity(0.15))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button("Taste Again") {
                        showingTasteAgainForm = true
                    }
                    .buttonStyle(AppSecondaryButtonStyle())
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingEditForm = true } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .foregroundStyle(AppColors.accent)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingDeleteConfirmation = true } label: {
                    Label("Delete", systemImage: "trash")
                }
                .foregroundStyle(.red)
            }
        }
        .sheet(isPresented: $showingEditForm) {
            TastingFormView(viewModel: viewModel, mode: .edit(currentTasting))
        }
        .sheet(isPresented: $showingTasteAgainForm) {
            TastingFormView(viewModel: viewModel, mode: .tasteAgain(currentTasting))
        }
        .alert("Delete Tasting?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.delete(currentTasting.id)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var heroHeader: some View {
        AppElevatedCard {
            HStack(spacing: 14) {
                DrinkTypeIcon(type: currentTasting.type, size: 72, photoFileName: currentTasting.photoFileName)

                VStack(alignment: .leading, spacing: 8) {
                    Text(currentTasting.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppColors.primaryText)

                    HStack(spacing: 8) {
                        DrinkTypeBadge(type: currentTasting.type, compact: true)
                        RatingBadge(rating: currentTasting.rating)
                    }

                    Button {
                        viewModel.toggleFavorite(currentTasting.id)
                    } label: {
                        Label(
                            currentTasting.isFavorite ? "Favorited" : "Add to Favorites",
                            systemImage: currentTasting.isFavorite ? "star.fill" : "star"
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TastingDetailView(
            viewModel: TastingViewModel(),
            tasting: TastingModel(
                name: "Ethiopian Yirgacheffe",
                type: .coffee,
                variety: "Single Origin 2024",
                rating: 5,
                flavorNotes: "Floral, citrus, bergamot",
                flavorTags: [.floral, .citrus],
                location: "Home Kitchen",
                date: Date(),
                isFavorite: true
            )
        )
    }
}
