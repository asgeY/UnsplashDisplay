//
//  SearchBar.swift
//  UnsplashDisplay
//
//  Created by AsgeY on 4/26/23.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onSearch: ((String?) -> Void)?

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        
        // Set the background color to clear
        searchBar.searchBarStyle = .minimal
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        return searchBar
    }


    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(searchBar: self)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        let searchBar: SearchBar
        init(searchBar: SearchBar) {
            self.searchBar = searchBar
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            DispatchQueue.main.async {
                self.searchBar.onSearch?(searchBar.text)
            }
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            DispatchQueue.main.async {
                self.searchBar.onSearch?(nil)
            }
        }
    }
}


