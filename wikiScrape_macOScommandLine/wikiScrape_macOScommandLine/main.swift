//
//  main.swift
//  wikiScrape_macOScommandLine
//
//  Created by Benjamin Saltzman on 6/14/21.
//

import Foundation
import SwiftSoup

let semaphore = DispatchSemaphore(value: 0)
var html: String = ""

let url = URL(string: "https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s")!

let session = URLSession(configuration: .ephemeral)
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
    let date: String
    let artist: String
    let title: String
}

func parseResponse(_ string: String? = nil, error: Error? = nil) throws -> [[String]] {
    var trackArray = [[String]]()
    
    guard error == nil else {
        print(error!)
        return(trackArray)
        //I would like to return void, or just return, but the function requires a return. Setting [[String]]? didn't help
        //This is why I had to declarre trackArray up top
    }

    do {
        trackArray.append(["Date", "Artist", "Title"])
        let doc: Document = try SwiftSoup.parse(html)
        let wikiTable = try doc.select("table").attr("class", "sortable wikitable jquery-tablesorter")
        let tbody: Element = try wikiTable.select("tbody").array()[2]
        for count in 2...11{
            let row: Element = try tbody.select("tr").array()[count]
            let date: String = try row.select("td").array()[1].text()
            let artist: String = try row.select("td").array()[2].text()
            let title: String = try row.select("td").array()[3].text()
            trackArray.append([date, artist, title])
        }

    } catch Exception.Error(_, let message) {
        print(message)
    } catch {
        print("error")
    }
    return(trackArray)
}

var outputString: String = ""
    
let tracks = try parseResponse(html, error: nil)
for track in tracks{
    outputString.append("\(track[0]) \t \(track[1]) \t \(track[2])\n")
}
let outputFile = URL(fileURLWithPath: "/Users/soqank/Desktop/music.txt")
try outputString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
 

/*
 //helpful info to understand swiftsoup
do {
    let html: String = "<p>An <a href='http://example.com/'><b>example</b></a> link.</p>";
    let doc: Document = try SwiftSoup.parse(html)
    let link: Element = try doc.select("a").first()!
    
    let text: String = try doc.body()!.text(); // "An example link"
    let linkHref: String = try link.attr("href"); // "http://example.com/"
    let linkText: String = try link.text(); // "example""
    
    let linkOuterH: String = try link.outerHtml(); // "<a href="http://example.com"><b>example</b></a>"
    let linkInnerH: String = try link.html(); // "<b>example</b>"

} catch Exception.Error(let type, let message) {
    print(message)
} catch {
    print("error")
}
*/

