
# Movie app #

A sample app that accesses: https://api.themoviedb.org, and displays movie information. 

The "Now Playing" view fetches new content when scrolling down. Selecting a movie presents a movie page with description. 
If the movie is part of a collection the associated movies are also loaded, and selectable.

![movie-app](http://bucket-uk.julesjans.com.s3.amazonaws.com/Misc/Images/movie-app-2.gif)

##  Configuration & build ##

The app has been built in Xcode 9.4.1 & Swift 4.1.

The  app needs to be configured with an API token. This needs to be put in the *Secret.swift* file.

1. Clone the repo and copy *Secret.swift.example*  to *Secret.swift*, open *movie-app.xcodeproj* and ensure that *Secret.swift* is  added to the project, 
and "Target Membership" is checked for movie-app:

```
git clone https://github.com/julesjans/movie-app.git
cd movie-app
cp Secret.swift.example Secret.swift
open movie-app.xcodeproj
```

2. Enter credentials in *Secret.swift*:

```Swift
enum APICredentials {
    static let key = "Your API Key here"
}
```
3. The project should now build in Xcode, no dependencies are needed.

##  Overview ##

### *movie-app/* ###

* *movie-app/Model*
    * APIClient - Protocols and class for handling API requests.
    * Model definitions:
        * NowPlaying 
        * Movie
        * Genre
        * MovieCollection
    
* *movie-app/View*
    * Main - Stoyboard uses Autolayout for a universal iPhone/iPad app.
    * CollectionCell - Resuable collection view cell.
    * Rating - Provides a 10-star rating view.
    
* *movie-app/Controller*
    * ViewController - Controller for "Now Playing" movies.
    * DetailViewController - Controller for movie detail, with collection view for collection.

### *movie-app/Supporting Files* ###

Necessary files, configuration, assets and seed data for tests.

##  Testing ##

Tests can be run through the standard test functions in Xcode.

1. *movie-appTests/* - Unit tests for the model and the API, uses a mock API that can be switched to test the live API.

2. *movie-appUITests/* - BDD UI tests for the view, uses a mock API and can also be switched to test the live API.

##  Notes ##

* Network connectivity is assumed, there is no handling of offline states, error messages etc.

* Image fetching is not optimised. There is a cache (cleared on app termination).

* Tests are limited, but demonstrate dependency injection with the API client. 

##  iPad Layout ##

![movie-app-ipad](http://bucket-uk.julesjans.com.s3.amazonaws.com/Misc/Images/movie-app-ipad-small.jpg)

