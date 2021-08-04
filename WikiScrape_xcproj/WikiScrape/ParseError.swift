//
//  ParseError.swift
//  WikiScrape
//
//  Created by Benjamin Saltzman on 8/1/21.
//

import Foundation

enum ParseError: Error, CustomStringConvertible{
    case empty
    case noRequest
    case missingKeywords
    case tooManyRowsRequested(Int)
    
    var description: String{
        switch self{
        case .empty:
            return "Nothing to parse"
        case .noRequest:
            return "Please input a number higher than 1"
        case .tooManyRowsRequested(let rows):
            return "Please input a number for rowsRequested between 1 and \(rows)"
        case .missingKeywords:
            return "Missing keywords to properly run"
        }
    }
}
