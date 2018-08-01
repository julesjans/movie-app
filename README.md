
# Movie app #

A sample app that accesses https://api.themoviedb.org,  and displays movie information. 

The "now playing" view reloads the next page of content when scrolling down the view. Selecting a movie presents a movie page with description. 
If the movie is part of a collection the associated movies are also loaded, and selectable.

![movie-app](http://bucket-uk.julesjans.com.s3.amazonaws.com/Misc/Images/movie-app.gif)

##  Issues ##

Due to time constraints there are some issues, for example:

* There are very few data fields presented, only title, description, poster image and collections.

* Image fetching is not optimised. There is a basic cache (cleared on app termination), but this needs improving.

* Tests are limited, but demonstate dependency injection with the API client. 



##  Configuration & build ##

The app has been built in Xcode 9.4.1 & Swift 4.1.

The  app needs to be configured with an API token. This needs to be put in a *Secret.swift* file.

1. Clone the repo and copy *Secret.swift.example*  to *Secret.swift* (the renamed file will be ignored by git), open *movie-app.xcodeproj* and ensure that *Secret.swift* is  added to the project, 
and "Target Membership" is checked for movie-app.

```
git clone https://github.com/julesjans/movie-app.git
cd movie-app
cp Secret.swift.example Secret.swift
```
2. Enter relevant credentials in *Secret.swift*:

```Swift
enum APICredentials {
    static let key = "Your API Key here"
}
```
3. The project should now build in Xcode, no further dependencies needed.


##  Testing ##

Tests can be run through the standard test menu functions in Xcode.

1. *movie-appTests/* - Unit tests for the model and the API, uses a mock API that can be switched to test the live API.

2. *movie-appUITests/* - UI tests for the view, uses a mock API (injected using XCUIApplication launch arguments), can be switched to test the live API. 
