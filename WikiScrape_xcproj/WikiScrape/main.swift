//
//  main.swift
//  wikiScrape
//
//  Created by Benjamin Saltzman on 6/14/21.
//
import Foundation

let parser = Parser()
try parser.parse("https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s", 10, "/Users/Soqank/Desktop/music.txt" )



