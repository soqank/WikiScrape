//
//  main.swift
//  wikiScrape
//
//  Created by Benjamin Saltzman on 6/14/21.
//
import Foundation
import SwiftSoup

enum ParseError: Error{
    case empty
    case noRequest
    case missingKeywords
    case tooManyRowsRequested
}

let semaphore = DispatchSemaphore(value: 0)
var html: String = ""

let url = URL(string: "https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s")!

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

struct Track {
    var date: String = ""
    var artist: String = ""
    var title: String = ""
}

class ParseResponse {
    var stringToParse: String
    var rowsRequested: Int
    
    init (_ stringToParse: String, _ rowsRequested: Int){
        self.stringToParse = stringToParse
        self.rowsRequested = rowsRequested
    }
    var numberOfUseableRows: Int = 0
    var trackArray = [Track]()
    var rows = [Int]()
    let keywordsArray = ["table", "class", "sortable wikitable", "tbody", "tr", "td"]
    
    var outputString: String = ""
}

func parseResponse(_ container: ParseResponse) throws{
    
    guard container.stringToParse != "" else { throw ParseError.empty }
    for words in container.keywordsArray{
        guard container.stringToParse.contains(words) == true else { throw ParseError.missingKeywords}
    }
    
    let doc: Document = try SwiftSoup.parse(container.stringToParse)
    let wikiTable = try doc.select("table").attr("class", "sortable wikitable")
    let tbody: Element = try wikiTable.select("tbody").array()[2]
    
    guard container.rowsRequested > 0 else { throw ParseError.noRequest}
    
    // counts the number of useable rows for year 1970
    func useableRows() -> Int{
        var counter:Int = 2
        var useableRows:Int = 0
        while true{
            do{
                let row = try tbody.select("tr").array()[counter]
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
    
    container.numberOfUseableRows = useableRows()
    guard container.numberOfUseableRows >= container.rowsRequested else { throw ParseError.tooManyRowsRequested}
    
    // creates rows array of numbers to request elements of date, artist and title
    // starts at 2 due to the two unuseable rows above it
    for i in 1...container.rowsRequested{
        container.rows.append(i+2)
    }

    for row in container.rows{
        let currentRow: Element = try tbody.select("tr").array()[row]
        var currentTrack = Track()
        currentTrack.date = try currentRow.select("td").array()[1].text()
        currentTrack.artist = try currentRow.select("td").array()[2].text()
        currentTrack.title = try currentRow.select("td").array()[3].text()
        container.trackArray.append(currentTrack)
    }
}

func writeToFile(container: ParseResponse, fileName: String){
    do {
        try parseResponse(container)
        container.outputString.append("Date\tArtist\tTitle\n")
        for track in container.trackArray{
            container.outputString.append("\(track.date)\t\(track.artist)\t\(track.title)\n")
        }
        let outputFile = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName)
        try container.outputString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    catch {
        switch error{
        case ParseError.empty:
            print("Nothing to parse")
        case ParseError.noRequest, ParseError.tooManyRowsRequested:
            print("Please input a number for rowsRequested between 1 and \(container.numberOfUseableRows)")
        case ParseError.missingKeywords:
            print("Missing keywords to properly run")
        default:
            print("Unexpected error: \(error)")
        }
    }
}

let sortedTracks1970 = ParseResponse(html, 10)
writeToFile(container: sortedTracks1970, fileName: "Music.txt")
