//
//  LocationSearchViewModel.swift
//  TranslateHelper
//
//  Wraps MKLocalSearchCompleter to provide city/region autocomplete
//  for the Settings location picker.
//

import Foundation
import MapKit
import Combine

class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {

    @Published var searchQuery: String = "" {
        didSet {
            if searchQuery.isEmpty {
                completions = []
                completer.cancel()
            } else {
                completer.queryFragment = searchQuery
            }
        }
    }

    @Published var completions: [MKLocalSearchCompletion] = []

    private let completer: MKLocalSearchCompleter

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    // MARK: - MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.completions = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.completions = []
        }
    }
}
