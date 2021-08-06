//
//  File.swift
//  WikiScrape
//
//  Created by Benjamin Saltzman on 8/3/21.
//

import Foundation

enum WriteError: Error, CustomStringConvertible{
    case badPath
    case emptyPath
    case noExt
    case emptyInput
    
    var description: String{
        switch self{
        case .badPath, .emptyPath:
            return "Please declare a valid path"
        case .noExt:
            return "Make sure you are outputting to a file with an extention"
        case .emptyInput:
            return "the inputFile is empty"
        }
    }
}
