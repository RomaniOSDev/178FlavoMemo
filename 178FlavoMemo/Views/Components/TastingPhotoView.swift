//
//  TastingPhotoView.swift
//  178FlavoMemo
//

import PhotosUI
import SwiftUI

/// Photo picker and preview for tasting label or cup images.
struct TastingPhotoView: View {
    @Binding var photoFileName: String?
    @State private var selectedItem: PhotosPickerItem?
    @State private var previewImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppGradients.cardBorder, lineWidth: 1)
                    )
                    .compositingGroup()
                    .shadow(
                        color: .black.opacity(AppCardElevation.standard.shadowOpacity),
                        radius: AppCardElevation.standard.shadowRadius,
                        x: 0,
                        y: AppCardElevation.standard.shadowY
                    )
                    .overlay(alignment: .topTrailing) {
                        Button {
                            removePhoto()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .red)
                                .padding(8)
                        }
                    }
            }

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(photoFileName == nil ? "Add Photo" : "Change Photo", systemImage: "photo.on.rectangle.angled")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(AppGradients.secondaryButton)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.22), lineWidth: 0.5)
                    )
            }
            .onChange(of: selectedItem) { newItem in
                Task { await loadPhoto(from: newItem) }
            }
        }
        .onAppear(perform: loadExistingPhoto)
    }

    private func loadExistingPhoto() {
        guard let photoFileName else { return }
        previewImage = PhotoStorageService.shared.loadPhoto(fileName: photoFileName)
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }

        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            if let oldFileName = photoFileName {
                PhotoStorageService.shared.deletePhoto(fileName: oldFileName)
            }

            if let fileName = PhotoStorageService.shared.savePhoto(image) {
                photoFileName = fileName
                previewImage = image
            }
        }
    }

    private func removePhoto() {
        if let photoFileName {
            PhotoStorageService.shared.deletePhoto(fileName: photoFileName)
        }
        photoFileName = nil
        previewImage = nil
        selectedItem = nil
    }
}

/// Read-only photo preview for detail screens.
struct TastingPhotoPreview: View {
    let photoFileName: String?

    var body: some View {
        if let photoFileName,
           let image = PhotoStorageService.shared.loadPhoto(fileName: photoFileName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
