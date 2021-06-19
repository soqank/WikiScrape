import WebKit
import Foundation


let siteURL = "https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s"

func performRequest(_ urlString: String){
    print("performing request")
    if let url = URL(string: urlString){
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url, completionHandler: handle(data: response: error:))
        task.resume()
        print("task started")
    }
}

func handle(data: Data?, response: URLResponse?, error: Error?){
    print("handle started")
    if error != nil{
        print(error!)
        return
    }
    
    if let safeData = data{
        print("safeData started")
        let dataString = String(data: safeData, encoding: .utf8)
        print(dataString!)
    }
}
performRequest(siteURL)
/*
DispatchQueue.main.async {
    performRequest(siteURL)
}
*/


//MARK: -
/*
let url = URL(string: "https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s")!

let session = URLSession(configuration: .default)
let task = session.dataTask(with: url) { (data, response, error) in
    print("task started")
    if let safeData = data {
        print("safeData created")
        if let dataString = String(data: safeData, encoding: .utf8){
            print("dataString is: \(dataString)")
        } else{
            print(error ?? "Failed")
        }
    }
}
task.resume()
*/
//MARK: -
/*
let siteURL = "https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s"
if let url = URL(string: siteURL) {
    print(url)
    
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: url) { (data, response, error) in
        print("func started")
        if error != nil {
            print("error started")
            print(error ?? "something went wrong")
            return
        }
        
        if let safeData = data {
            print("safeData started")
            print(safeData)
        }
        print("nothing happened")
    }
    task.resume()
}
*/


//MARK: -
/*
let url = URL(string: "https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_number-one_singles_of_the_1970s")!
print("Url is: \(url)")

let runLoop = CFRunLoopGetCurrent()
let session = URLSession(configuration: .ephemeral)
let task = session.dataTask(with: url) { (data, response, error) in
    print("Retrieved data")
    CFRunLoopStop(runLoop)
    if let safeData = data {
        print("safeData started")
        if let dataString = String(data: safeData, encoding: .utf8){
            print("success")
            print("safeData is: \(safeData)")
            print("dataString is: \(dataString)")
            //if I can print this out, then I can start parsing it
        } else{
            print("Fail")
        }
    }
}
task.resume()
CFRunLoopRun()
print("done")

*/
