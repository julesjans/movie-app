
# Movie app  #

A sample app that accesses https://api.themoviedb.org,  and displays movie information.

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

There are two test targets, both of which can be run through the standard test menu functions in Xcode.

1. *movie-appTests/* - Unit tests for the model and the API, uses a mock API that can simply be switched to test the live API.

2. *movie-appUITests/* - UI Tests...
