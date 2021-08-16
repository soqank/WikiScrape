//
//  main.swift
//  wikiScrape
//
//  Created by Benjamin Saltzman on 6/14/21.
//
import Foundation
import WikiScrapeCore

var parser = Parser()

let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
let desktopDirectory = paths[0]
let outputFile = URL(fileURLWithPath: desktopDirectory).appendingPathComponent("music.txt")

do{
    try parser.parse("https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s", 10, outputFile)
} catch {
    print("Error: \(error)")
}
