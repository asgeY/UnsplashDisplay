//
//  ContentView.swift
//  UnsplashDisplay
//
//  Created by AsgeY on 4/26/23.
//

import SwiftUI


struct ContentView: View {
    @State private var searchText = ""
    @State private var photos: [UnsplashImage] = []
    @State private var currentIndex = 0
    @State private var backgroundColor: Color = .white // Add this line
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Gallery")
                    .font(.largeTitle)
                    .padding(.top, 5)
                
                HStack(spacing: 0) {
                    SearchBar(text: $searchText, placeholder: "Search images", onSearch: { query in
                        photos = []
                        loadImages(searchQuery: query)
                    })
                    .padding(.leading, 5)
                }
                .frame(height: 50)
                
                TabView(selection: $currentIndex) {
                    ForEach(photos.indices, id: \.self) { index in
                        GeometryReader { imageGeometry in
                            VStack(alignment: .leading) {
                                if let image = photos[index].image {
                                    let uiImage = UIImage(cgImage: image.cgImage!)
                                    let dominantColor = uiImage.dominantColor()
                                    Color.clear
                                        .overlay(
                                            Color(dominantColor).opacity(0.2)
                                        )
                                        .frame(width: imageGeometry.size.width - 50, height: imageGeometry.size.height - 40)
                                        .clipped()
                                        .cornerRadius(25)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                        .offset(x: 3) // Move image to the left by 25 points
                                        .padding(.leading, 20)
                                        .background(
                                            Color(dominantColor).opacity(0.2)
                                                .onAppear {
                                                    backgroundColor = Color(dominantColor)
                                                }
                                        )
                                    
                                }
                                
                                Spacer()
                                
                                Text(photos[index].title ?? "Untitled")
                                    .foregroundColor(.black)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.leading, 10)
                            }
                        }
                        
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .padding(.top, 10)
                
            }
           
        }
        .onAppear {
            loadImages()
        }
        
}

    
    private func loadImages(searchQuery: String? = nil) {
        let numberOfPages = 10
        let imagesPerPage = 50
        let dispatchGroup = DispatchGroup()
        
        for page in 1...numberOfPages {
            dispatchGroup.enter()
            UnsplashAPI.fetchImages(searchQuery: searchQuery, page: page, perPage: imagesPerPage) { fetchedPhotos in
                downloadImages(from: fetchedPhotos) { downloadedImages in
                    self.photos.append(contentsOf: downloadedImages)
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished loading all images")
        }
        //        dispatchGroup.notify(queue: .main) {
        //            print("Finished loading all images")
        //            print("Loaded images count: \(photos.count)")
        //        }
    }
    
    
    private func downloadImages(from photos: [UnsplashImage], completion: @escaping ([UnsplashImage]) -> Void) {
        var downloadedImages: [UnsplashImage] = []
        let dispatchGroup = DispatchGroup()
        
        for photo in photos {
            dispatchGroup.enter()
            guard let imageURL = URL(string: photo.urls.small) else { continue }
            URLSession.shared.dataTask(with: imageURL) { data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    var newPhoto = photo
                    newPhoto.image = image
                    downloadedImages.append(newPhoto)
                } else {
                    print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                }
                dispatchGroup.leave()
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(downloadedImages)
        }
    }
    
    private func searchImages() {
        let searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchQuery.isEmpty {
            photos.removeAll()
            loadImages(searchQuery: searchQuery)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct TitlePreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: Value = 0
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

