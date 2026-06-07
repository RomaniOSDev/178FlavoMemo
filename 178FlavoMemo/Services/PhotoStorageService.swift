//
//  PhotoStorageService.swift
//  178FlavoMemo
//

import UIKit

/// Stores tasting photos in the app's Documents directory.
final class PhotoStorageService {
    static let shared = PhotoStorageService()

    private let folderName = "TastingPhotos"

    private var photosDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(folderName, isDirectory: true)
    }

    private init() {
        createDirectoryIfNeeded()
    }

    /// Saves image data and returns the generated file name.
    func savePhoto(_ image: UIImage) -> String? {
        createDirectoryIfNeeded()

        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            return nil
        }

        do {
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }

    /// Loads a stored photo by file name.
    func loadPhoto(fileName: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    /// Removes a stored photo from disk.
    func deletePhoto(fileName: String) {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func createDirectoryIfNeeded() {
        guard !FileManager.default.fileExists(atPath: photosDirectory.path) else { return }
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
    }
}
