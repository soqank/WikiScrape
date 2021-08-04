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

func write(inputFile: String, outputFile: String) throws{
    guard outputFile.isEmpty == false else {throw WriteError.emptyPath}
    guard inputFile.isEmpty == false else {throw WriteError.emptyInput}

    let path = URL(fileURLWithPath: outputFile)
    guard path.pathExtension.count > 0 else {throw WriteError.noExt}
    
    //checks if the path -file is valid
    do{
        var pathBase = path
        pathBase.deleteLastPathComponent()
        _ = try pathBase.checkResourceIsReachable()
    } catch{
        print("Please declare a valid path")
    }
    
    //checks for existence of file and writes files
    do{
        if ((try? path.checkResourceIsReachable() == true) != nil) {
            print("Writing over \(path.lastPathComponent)")
        }
        try inputFile.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        print("Success")
    } catch {
        print("\(error)")
    }
    
    
}




