# cantera

A small app I am making for a technical challenge from FINN.no.

![gif](GitHub/vid.gif)

## Structure

In the top level directory of `cantera` there is the usual Xcode files.  I have
tried to structure everything in small groups, explained below with clickable
links for your convenience ;)

- [Handlers](cantera/Handlers) - wrapper to read / write JSON from / to application sandbox, URLSession wrapper functions to fetch the JSON payload, download images, endpoints, and image cache handling.
- [Extensions](cantera/Extensions/) - extensions to UIColor and String for convenience
- [Controller](cantera/Controller) - the view controllers used in the app
- [View](cantera/View/) - contains the collection view cell for the ads controller
- [Model](cantera/Model/) - split into API response model and UI model


## Design

The app consists of one view controller [AdsCollectionViewController](cantera/Controller/AdsCollectionViewController.swift). 
The controllers main content view is a collection view that uses the [AdViewCollectionViewCell](cantera/View/AdViewCollectionViewCell.swift).
The other views are [LoadingIndicatorView](cantera/View/LoadingIndicatorView.swift), [EmptyCollectionView](cantera/View/EmptyCollectionView.swift) and [FavoriteButton](cantera/View/FavoriteButton.swift).

The networking requests are managed by the [RequestHandler](cantera/Handlers/RequestHandler.swift).
For the persistence [StorageHandler](cantera/Handlers/StorageHandler.swift) is used.

## Potential improvements

Error states are not being handled at all. They should be addressed gracefully
with sane default behaviour. I feel like the ads view controller could have
been done much better, getting it to support dynamic attributed text was harder
than I thought it would be using Auto Layout.

## If I had more time what would I want to do

It would have been awesome if I had gotten around to making some animations.
Like f. ex.  user toggles the favourite button.

It would have been cool to show different views based on the `ad-type`, maybe
icons like FINN does?  I tried hard to avoid adding any third party dependency,
maybe that was a mistake?  I could have speed up things by pulling in something
like [FinniversKit][f] for the UI.

Misc topics

- Cleanup strategy for persisted file
- Mentioned earlier above, but a proper error strategy
- Performance tuning using instruments

One more thing. The feature I wanted to add was a collection of predefined
layouts the user could switch between. So for ex. you would press a
`UIBarButtonItem`  and it would change the layout from grid to table view. I
mainly wanted to support three layouts, the table view type one, regular
collection view grid and a nice full screen one.

[f]: https://github.com/finn-no/FinniversKit
