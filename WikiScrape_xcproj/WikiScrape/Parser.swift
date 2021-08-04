//
//  Parser.swift
//  WikiScrape
//
//  Created by Benjamin Saltzman on 8/1/21.
//

import Foundation
import SwiftSoup

class Parser {
    var rowsRequested: Int = 0
    var numberOfUseableRows: Int = 0
    var trackArray = [Track]()
    var rows = [Int]()
    let keywordsArray = ["table", "class", "sortable wikitable", "tbody", "tr", "td"]
    var outputString: String = ""

    init (){}
    
    // This will be the semaphore section that downloads the html, return the html string.
    func fetchData(_ url: String) -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var html: String = ""
        let url = URL(string:url)!
        
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
    
    // Parse the html and convert it to tracks
    func parseData(_ html: String, _ rowsRequestedInput: Int) throws -> [Track] {
        rowsRequested = rowsRequestedInput
        
        // verifies that a string is present to parse
        guard html != "" else { throw ParseError.empty }
        for words in keywordsArray{
            guard html.contains(words) == true else { throw ParseError.missingKeywords}
        }
        
        // select is modified from swift soup and requires a Document or Element/s to scan
        let doc:Document = try SwiftSoup.parse(html)
        let wikiTable: Elements = try doc.select("table").attr("class", "sortable wikitable")
        let tbody: Element = try wikiTable.select("tbody").array()[2]
        
        numberOfUseableRows = try useableRows(tbody)
        guard numberOfUseableRows >= rowsRequested else { throw ParseError.tooManyRowsRequested(numberOfUseableRows)}
        
        // creates rows array of numbers to request elements of date, artist and title
        // starts at 2 due to the two unuseable rows above it
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
    
    //make sure that the rows requested fall within the useable range
    //counts the number of useable rows for year 1970, requires tbody element in scanableElement
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
    
    //arranges the tracks in tabbed layout
    func arrangeTracks(_ trackArray: [Track]) -> String{
        outputString.append("Date\tArtist\tTitle\n")
        for track in trackArray{
            outputString.append("\(track.date)\t\(track.artist)\t\(track.title)\n")
        }
        return outputString
    }
    
    //calls all the functions
    func parse(_ url: String, _ rows: Int, _ outputFile: String) throws {
        let html = fetchData(url)
        let tracks = try parseData(html, rows)
        let arrangedTracks = arrangeTracks(tracks)
        try write(inputFile: arrangedTracks, outputFile: outputFile)
    }
}
