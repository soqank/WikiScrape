//
//  main.swift
//  wikiScrape
//
//  Created by Benjamin Saltzman on 6/14/21.
//
import Foundation
import SwiftSoup

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

struct Track {
    var date: String = ""
    var artist: String = ""
    var title: String = ""
}

class Parser {
    var stringToParse: String = ""
    var rowsRequested: Int = 0
    var numberOfUseableRows: Int = 0
    var trackArray = [Track]()
    var rows = [Int]()
    let keywordsArray = ["table", "class", "sortable wikitable", "tbody", "tr", "td"]
    var outputString: String = ""

    init (){}
    
    /// This will be the semaphore section that downloads the html, return the html string.
    func fetchData(_ url: URL) -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var html: String = ""
        let url = url
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let safeData = data {
                if let dataString = String(data: safeData, encoding: .utf8){
                    html = dataString
                } else{
                    print(error ?? "Failed")
                }
                semaphore.signal()
            }
        }
        
        print("Downloading page")
        task.resume()
        semaphore.wait()
        return html
    }
    
    ///Parse the html and convert it to tracks
    func parseData(_ html: String, _ rowsRequestedInput: Int) throws -> [Track] {
        stringToParse = html
        rowsRequested = rowsRequestedInput
        
        ///verifies that a string is present to parse
        guard stringToParse != "" else { throw ParseError.empty }
        for words in keywordsArray{
            guard stringToParse.contains(words) == true else { throw ParseError.missingKeywords}
        }
        
        ///select is modified from swift soup and requires a Document or Element/s to scan
        let doc:Document = try SwiftSoup.parse(stringToParse)
        let wikiTable: Elements = try doc.select("table").attr("class", "sortable wikitable")
        let tbody: Element = try wikiTable.select("tbody").array()[2]
        
        numberOfUseableRows = try useableRows(tbody)
        guard numberOfUseableRows >= rowsRequested else { throw ParseError.tooManyRowsRequested(numberOfUseableRows)}
        
        /// creates rows array of numbers to request elements of date, artist and title
        /// starts at 2 due to the two unuseable rows above it
        for i in 0..<rowsRequested{
            rows.append(i+2)
        }
        
        for row in rows{
            let currentRow: Element = try tbody.select("tr").array()[row]
            var currentTrack = Track()
            currentTrack.date = try currentRow.select("td").array()[1].text()
            currentTrack.artist = try currentRow.select("td").array()[2].text()
            currentTrack.title = try currentRow.select("td").array()[3].text()
            trackArray.append(currentTrack)
        }
        
        return trackArray
        
    }
    
    ///make sure that the rows requested fall within the useable range
    ///counts the number of useable rows for year 1970, requires tbody element in scanableElement
    func useableRows(_ scanableElement: Element) throws -> Int  {
        guard rowsRequested > 0 else { throw ParseError.noRequest}
        
        var counter:Int = 2
        var useableRows:Int = 0
        
        while true{
            do{
                let row = try scanableElement.select("tr").array()[counter]
                let isNextSection:Bool = try row.html().contains("1971")
                if isNextSection == true{
                    break
                } else {
                    useableRows += 1
                }
                counter += 1
            } catch{
                print("Error: Something happened while counting useableRows")
                break
            }
        }
        return useableRows
    }
    
    ///arranges the tracks in tabbed layout
    func arrangeTracks(_ trackArray: [Track]) -> String{
        outputString.append("Date\tArtist\tTitle\n")
        for track in trackArray{
            outputString.append("\(track.date)\t\(track.artist)\t\(track.title)\n")
        }
        return outputString
    }
    
    ///writes inputFile to filename, stored on desktop
    func write(inputFile: String, fileName: String) throws{
        do {
            let outputFile = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName)
            try inputFile.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("\(error)")
        }
    }
    
    func parse(_ url: String, _ rows: Int, _ filename: String) throws {
        let urlHolder = URL(string:url)!
        let html = fetchData(urlHolder)
        let tracks = try parseData(html, rows)
        let arrangedTracks = arrangeTracks(tracks)
        try write(inputFile: arrangedTracks, fileName: filename)
    }
}
let parser = Parser()
try parser.parse("https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s", 10, "music.txt" )











