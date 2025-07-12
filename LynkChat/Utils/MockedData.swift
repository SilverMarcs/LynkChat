//
//  MockedData.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/09/2024.
//

import Foundation

extension Message {
    static let mockAssistantMessage = Message.assistant(model: .small_model, content: String.codeBlock)
    
    static let mockUserMessage = Message.user(content: String.shortContent)
}

extension ChatTool {
    static let mockTool = ChatTool(toolCallId: "scrapeLinks123", tool: .scrapeLinks, args: "{urls : [https://9to5mac.com/how-to-fast-charge-the-apple-watch/]}", result: "This is the result of the tool url scraping of page")
    
    static let mockImageTool = ChatTool(toolCallId: "imageTool123", tool: .imageGeneration, args: "{url : https://www.google.com}", result: "https://picsum.photos/200")
    
    static let mockGoogleTool2 = ChatTool(toolCallId: "googleTool123", tool: .webSearch, args: "{query : How to fast charge Apple Watch}", result: nil)

    static let mockTranscribeTool = ChatTool(toolCallId: "transcribel123", tool: .processFile, args: "{key : ddgyusadg67ygyisdgiyas}", result: nil)
}

extension MessageGroup {
    static var mockUserGroup = MessageGroup(message: .mockUserMessage)
    static var mockAssistantGroup = MessageGroup(message: .mockAssistantMessage)
}

extension ImageConfig {
    static var mockImageConfig = ImageConfig()
}

extension Chat {
    static var mockChat = Chat()
}

extension ImageSession {
    static var mockImageSession = ImageSession()
}

extension Generation {
    static var mockGeneration: Generation = .init(config: .mockImageConfig, session: .mockImageSession)
}

extension ChatVM {
    static var mockChatVM = ChatVM.shared
}

extension String {
    static let markdownContent = """
    Certainly! In Python, you can sort data using the built-in `sort()` method for lists or the `sorted()` function. Below are examples of both methods along with explanations.

    ### Using `sort()` Method

    The `sort()` method sorts a list in place. This means that it modifies the original list and does not return a new list.

    ```python
    # Example of using sort() method
    numbers = [5, 2, 9, 1, 5, 6]
    numbers.sort()  # Sorts the list in place
    print("Sorted numbers (in place):", numbers)
    ```

    ## Summary

    - Use `list.sort()` to sort a list in place.
    - Use `sorted(iterable)` to get a new sorted list without changing the original.
    - Use `reverse=True` for descending order.
    - Use the `key` parameter to sort based on custom criteria.

    Feel free to adjust the examples or ask if you have a specific sorting scenario in mind!
    """
    
    static let demoAssistant: String =
    """
    ## Heading   
    There are three ways to print a string in python
    1. Not printing
    2. Printing carelessly
    3. Blaming it on Teammates
    
    ### Subheading
    But whats even better is the ability to see into the future.  
        
    Thank you for using me.
    """
    
    static let codeBlock = """
    This is a sample amrkdown string
    - Sorts a list and prints the sorted list
    - Profit
    
    ```python
    def quick_sort(arr):
        if len(arr) <= 1:
            return arr
        else:
            pivot = arr[0]
            less_than_pivot = [x for x in arr[1:] if x <= pivot]
            greater_than_pivot = [x for x in arr[1:] if x > pivot]
            return quick_sort(less_than_pivot) + [pivot] + quick_sort(greater_than_pivot)

    # Example usage
    my_list = [3, 6, 8, 10, 1, 2, 1]
    sorted_list = quick_sort(my_list)
    print(sorted_list)
    ```
    1. Sort a list and print the sorted list
    2. Profit
    """
    
    static var onlyCodeBlock = """
    ```python
    def quick_sort(arr):
        if len(arr) <= 1:
            return arr
        else:
            pivot = arr[0]
            less_than_pivot = [x for x in arr[1:] if x <= pivot]
            greater_than_pivot = [x for x in arr[1:] if x > pivot]
            return quick_sort(less_than_pivot) + [pivot] + quick_sort(greater_than_pivot)

    # Example usage
    my_list = [3, 6, 8, 10, 1, 2, 1]
    sorted_list = quick_sort(my_list)
    print(sorted_list)
    ```
    """
    
    static let shortContent = """
        Hello, World! Could you show me some unstructured text formatted in markdown?
        """
    
    static let properMarkdown = """
        The error you're encountering is because you're trying to call a mutating function (`visit`) on `self` within a non-mutating context. In Swift, the `mutating` keyword indicates that the function modifies the instance it belongs to, and such methods can only be called on mutable instances.

        To resolve this, you need to refactor your code to ensure that `visit` does not require a mutating context, or alternatively, refactor the logic so that the `visit` function is called outside of contexts where `self` is immutable.

        ### Solution: Refactor `visit` Function

        Let's assume `visit` is a function that traverses a `ListItem` and returns an `NSAttributedString`. You should ensure that this function is non-mutating, or you separate the logic such that `visit` does not capture `self` in a way that requires it to be mutable.

        Here's how you can refactor your code:

        1. **Ensure `visit` is Non-Mutating**: If possible, modify the `visit` function so it does not require mutating `self`.

        ```swift
        func visit(_ markup: Markup) -> NSAttributedString {
            // Your logic to convert markup to NSAttributedString
            // This logic should not depend on mutating self
            return NSAttributedString(string: markup.format())
        }
        ```

        2. **Refactor `parserResults`**: If `visit` inherently requires mutating behavior, consider separating the logic into a non-mutating context:

        ```swift
        mutating func parserResults(from document: Document, highlightText: String) -> [ContentItem] {
            var results = [ContentItem]()
            var currentTextBuffer = NSMutableAttributedString()
            
            func appendCurrentAttrString() {
                if !currentTextBuffer.string.isEmpty {
                    applyHighlighting(to: currentTextBuffer, highlightText: highlightText)
                    results.append(.text(currentTextBuffer))
                    currentTextBuffer = NSMutableAttributedString()
                }
            }
            
            func mapListItems(_ listItems: LazyMapSequence<MarkupChildren, ListItem>) -> [ListItemContent] {
                listItems.map { listItem in
                    let text = visit(listItem) // Ensure `visit` is non-mutating
                    return ListItemContent(text: text, checkbox: listItem.checkbox)
                }
            }
            
            document.children.forEach { markup in
                if let codeBlock = markup as? CodeBlock {
                    appendCurrentAttrString()
                    results.append(.codeBlock(codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines), language: codeBlock.language))
                } else if let table = markup as? Table {
                    appendCurrentAttrString()
                    results.append(.table(table))
                } else if let orderedList = markup as? OrderedList {
                    appendCurrentAttrString()
                    let listItems = mapListItems(orderedList.listItems)
                    results.append(.list(.ordered, listItems))
                } else if let unorderedList = markup as? UnorderedList {
                    appendCurrentAttrString()
                    let listItems = mapListItems(unorderedList.listItems)
                    results.append(.list(.unordered, listItems))
                } else {
                    let visitedText = visit(markup)
                    currentTextBuffer.append(visitedText)
                }
            }
            
            appendCurrentAttrString()
            
            return results
        }
        ```

        ### Explanation

        - **Non-Mutating `visit`**: Ensure `visit` does not need to modify `self`. It should be a pure function that takes a `Markup` and returns an `NSAttributedString`.
        - **Separate Logic**: If `visit` must remain mutating, try to refactor your code to call `visit` in contexts where you have a mutable `self`, or redesign your data flow to avoid such requirements.

        By ensuring `visit` is non-mutating or restructuring your code to avoid mutating contexts, you can resolve this error.
    """
    
    static let mockGoogleSearch = """
        [1] Revealed: The Top Artists, Songs, Albums, Podcasts, and ...
        URL: https://www.twitter.com/2024-12-04/top-songs-artists-podcasts-audiobooks-albums-trends-2024/
        Snippet: Dec 4, 2024 ... Spotify Wrapped is all about celebrating the fans, artists, authors, podcasters, and creators who made 2024 the record-breaking, ...

        [2] Where can i find my most played songs - The Spotify Community
        URL: https://www.facebook.com/t5/Content-Questions/Where-can-i-find-my-most-played-songs/td-p/6105746
        Snippet: May 31, 2024 ... In your profile, you'll find 2 sections: Top artists this month and Top tracks this month. Hope this clears things up. If you have any questions ...

        [3] From Breakout Pop Stars to Country Crossovers, Here's the Scoop ...
        URL: https://www.theverge.com/2024-12-04/from-breakout-pop-stars-to-country-crossovers-heres-the-scoop-on-2024s-biggest-music-trends-on-spotify/
        Snippet: Dec 4, 2024 ... ... 2024's Biggest Music Trends on Spotify ... Level with us: Which 2024 music trend surprised you the most? ... Taylor Swift Takes the Crown as ...

        [4] Solved: How to exclude artist and/or genre from recommende ...
        URL: https://www.instagram.co,/t5/Content-Questions/How-to-exclude-artist-and-or-genre-from-recommended-music-and/td-p/5171617
        Snippet: Mar 20, 2021 ... ... last summer, my son used my phone to cast music during a party. ... Does this method mess up the AI calculations and lead to spotify suggesting ...

        [5] The Top Songs, Artists, Podcasts, and Listening Trends of 2023 ...
        URL: https://www.9to5mac.com/2023-11-29/top-songs-artists-podcasts-albums-trends-2023/
        Snippet: Nov 29, 2023 ... In the last 24 months, India's classical music consumption grew by close to 500% on Spotify. Over 45% of Indian classical music listeners on ...

        [6] Global Top 50 | 2024 Hits - playlist by Topsify | Spotify
        URL: https://open.spotify.com/playlist/1KNl4AYfgZtOVm9KHkhPTF
        Snippet: Global Top 50 | 2024 Hits. Packed with all the best songs of 2024. Today's most streamed tracks and top songs - worldwide! ... NEW DROP. Don Toliver. luther ...

        [7] Solved: How to search for low-plays tracks? - The Spotify Community
        URL: https://community.spotify.com/t5/Other-Podcasts-Partners-etc/How-to-search-for-low-plays-tracks/td-p/4398267
        Snippet: About the boldness/size of the genres and artists, I would say that more popular ones are bolder than the lesser-known ones. I can't really think of a better or ...
        """
    static let mockTranscription = """
    This is the Micromachine Man presenting the most midget miniature motorcade of micromachines. Each one has dramatic details, terrific trim, precision paint jobs, plus incredible micromachine pocket play sets. There's a police station, fire station, restaurant, service station, and more. Perfect pocket portables to take any place. And there are many miniature play sets to play with, and each one comes with its own special edition micromachine vehicle and fun fantastic features that miraculously move. Raise the boat lift at the airport, marina, man the gun turret at the army base, clean your car at the car wash, raise the toll bridge. And these play sets fit together to form a micromachine world. Micromachine pocket play sets so tremendously tiny, so perfectly precise, so dazzlingly detailed, you'll want to pocket them all. Micromachines and micromachine pocket play sets sold separately from Galoob. The smaller they are, the better they are.
    """
}

extension String {
    static let mockTavilyThorough = """
    {
      "query": "Squid Game 2 reviews opinions",
      "responseTime": 1.62,
      "images": [],
      "results": [
        {
          "title": "Squid Game: Season 2 First Reviews: Just as Twisted and Ruthless, with ...",
          "url": "https://editorial.rottentomatoes.com/article/squid-game-season-2-first-reviews-just-as-twisted-and-ruthless-with-plenty-of-surprises/",
          "content": "Squid Game: Season 2 First Reviews: Just as Twisted and Ruthless, with Plenty of Surprises | Rotten Tomatoes 86% Squid Game: Season 2 The worldwide phenomenon is back, as Squid Game returns to Netflix this week for another thrilling season. 86% Squid Game: Season 2 (2024) premiered on Netflix on December 26, 2024. Resident of the states listed in the 'Your Rights' section of NBCUniversal’s Privacy Policy Only: To opt out of selling or sharing/processing for targeted advertising of information such as cookies and device identifiers processed for targeted ads (as defined by law) and related purposes for this site/app on this browser/device, switch this toggle to off (grey color) by moving it left and clicking “Confirm My Choice” below.",
          "rawContent": null,
          "score": 0.8014549
        },
        {
          "title": "'Squid Game' Season 2 Review: The Games Work, Everything ... - Forbes",
          "url": "https://www.forbes.com/sites/paultassi/2024/12/28/squid-game-season-2-review-the-games-work-everything-else-doesnt/",
          "content": "Squid Game season 2 After three years, Netflix’s most successful show of all time has returned in the form of Squid Game season 2. Squid Game season 2 excels in some ways and not in others, fattened up with what feels like filler content, which is not great for a season only seven episodes long. There is also an interesting dynamic introduced here that was not present in season 1, the ability for players to vote to leave the games after every round, which results in some dramatic sequences and eventually wild moments like sides killing each other in order to secure their numbers. In order to do so, please follow the posting rules in our site's Terms of Service.",
          "rawContent": null,
          "score": 0.7116118
        },
        {
          "title": "'Squid Game' Season Two: A spoiler-free review",
          "url": "https://indianapolisrecorder.com/squid-game-season-2-review/",
          "content": "Season two of \"Squid Game\" delivers a powerful continuation of the gripping and visceral drama that captivated global audiences in its first outing. Directed by Hwang Dong-hyuk, returning to the series' helm, season two raises the stakes while preserving the elements that made season one a cultural phenomenon.",
          "rawContent": null,
          "score": 0.68064564
        },
        {
          "title": "'Squid Game' Season 2 Review - New Games, New Players, Still as Subtle ...",
          "url": "https://collider.com/squid-game-season-2-review/",
          "content": "Season 2 switches up the formula for Squid Game to offer a fresh take on the concept. Still, despite a promising start, the show continues to rely too heavily on the same archetypes that made the",
          "rawContent": null,
          "score": 0.6701125
        },
        {
          "title": "'Squid Game' Season 2 Arrives With Worse Reviews Than Season 1 - Forbes",
          "url": "https://www.forbes.com/sites/paultassi/2024/12/26/squid-game-season-2-arrives-with-worse-reviews-than-season-1/",
          "content": "Squid Game season 2 has finally arrived after three years, the follow-up to the most-watched Netflix series of all time which has become a full-on brand for the service. Squid Game season – 2.2 billion hours viewed, 265.2 million views Stranger Things season 4 – 1.83 billion hours viewed, 140.7 million views Wednesday season 1 – 1.72 billion hours viewed, 252.1 million views Bridgerton season 1 – 929.3 million hours viewed, 113.3 million views Bridgerton season 3 – 846.5 million hours viewed, 106 million views Forbes Community Guidelines In order to do so, please follow the posting rules in our site's Terms of Service. Please read the full list of posting rules found in our site's Terms of Service.",
          "rawContent": null,
          "score": 0.57837737
        }
      ],
      "answer": null
    }
    """

}

extension String {
    static let mockTavilyModerate = """
    [{\"url\":\"https://www.simplymac.com/iphone/iphone-se-4-latest-updates-specs-info-release-date-expectations-rumors\",\"content\":\"Apple’s strategic timing for the SE 4 release allows it to maintain market momentum between flagship iPhone launches. Apple is likely to release the iPhone SE 4 in March 2025. With a rumored March release, it’s expected to feature a modern iPhone XR-like design, a powerful A17 or A18 chip, and possibly Apple’s own 5G modem. The iPhone SE 4 features a significant camera upgrade. Apple may adjust the iPhone SE 4’s price due to its enhanced features. The iPhone SE 4 is generating buzz with its expected upgrades and new features. Apple is likely to launch the iPhone SE 4 in early 2025. What are the rumored new features of the iPhone SE 4?\"},{\"url\":\"https://www.macrumors.com/guide/iphone-se-4/\",\"content\":\"MacRumors guides you through the latest rumors about the iPhone SE 4, expected to launch in 2025. Learn about the possible features, such as an all-display design, a 6.1-inch OLED display, a 48-megapixel camera, and an Apple-designed 5G modem.\"},{\"url\":\"https://www.cnet.com/tech/mobile/iphone-se-4-rumors-apples-next-cheap-phone-may-pack-big-upgrades/\",\"content\":\"iPhone SE 4 Rumors: Apple's Next Cheap Phone May Pack Big Upgrades - CNET iPhone SE 4 Rumors: Apple's Next Cheap Phone May Pack Big Upgrades The iPhone SE Apple/CNET The analyst Kuo also reported in October that mass production of the new iPhone SE would begin in December 2024, further indication that an early 2025 release may be in store for Apple's next tiny phone. If the company is working on another iPhone SE, it will likely have a 6.1-inch screen similar to Apple's modern flagship phones. Apple doesn't disclose the battery capacities for its phones, but it says the iPhone 14 should get five extra hours of video playback compared to the third-generation iPhone SE. If the report is accurate, the iPhone SE will only have one rear camera, unlike Apple's more expensive phones.\"},{\"url\":\"https://www.macrumors.com/2024/12/29/iphone-se-4-rumored-features/\",\"content\":\"Apple plans to release a fourth-generation iPhone SE in March, according to multiple reports and rumors circulating in recent months. The device is expected to have a similar design as the base\"},{\"url\":\"https://www.phonearena.com/iphone-se-4-release-date-price-features-news\",\"content\":\"iPhone SE 4 release date predictions, price, specs, and must-know features - PhoneArena iPhone SE 4 design Adding more weight to the early 2025 launch rumors, well-known Apple insider Mark Gurman recently revealed that Apple is getting close to starting production of the new iPhone SE, codenamed V59. Overall, a March 2025 release seems to be the most likely option, especially with a recent leak again pointing to March as the month Apple will unveil the next-gen iPhone SE model. iPhone SE 4 price If the offers for the iPhone SE 3 are anything to go by, Apple, Verizon, AT&T, and T-Mobile will likely offer similar promotions and discounts when the new model launches. Latest iPhone SE 4 news\"}]
    """
}
