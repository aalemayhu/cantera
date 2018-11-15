# cantera

![app-icon](./cantera/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png)

A small app I am making for a technical challenge from FINN.no.

>Note: I have only run the code on simulators, so there might be some surprises in the real world.

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

The app consists mainly of two view controllers [AdsCollectionViewController](cantera/Controller/AdsCollectionViewController.swift) and 
[AdsDetailViewController](cantera/Controller/AdsDetailViewController.swift). The AdsCollectionViewController let's you pick advertisements from the grid
which are then opened in the detail view. I was initially going to with a
UISwitch to toggle between all ads and the favourites, but after asking for
feedback from a friend. He suggested instead to use bar button items and a
stronger colour for the favorite icon. I incorporated his feedback.

Hmm, not sure if there is any interesting bits worth mentioning from the code, but if you are interested
in stats below is the output of [cloc](github.com/AlDanial/cloc):

```
$ cloc .
      32 text files.
      31 unique files.
      11 files ignored.

github.com/AlDanial/cloc v 1.78  T=1.04 s (21.1 files/s, 1093.7 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Swift                           15            130            139            557
JSON                             5              0              0            227
Markdown                         1             20              0             43
YAML                             1              2              0             24
-------------------------------------------------------------------------------
SUM:                            22            152            139            851
-------------------------------------------------------------------------------
```

## Potential improvements

There is some copy / pasta in between the view controllers. Would have been
nice to plan out better and create separate view component classes that could
be reused across them f. ex. the favourite button.

Error states are not being handled at all. They should be addressed gracefully
with sane default behaviour. I feel like the ads view controller could have
been done much better, getting it to support dynamic attributed text was harder
than I thought it would be using Auto Layout.

## If I had more time what would I want to do

It would have been awesome if I had gotten around to making some animations. Like
these ones:

- Transitions between view controllers.
- User toggles the favourite button.

It would have been cool to show different views based on the `ad-type`, maybe
icons like FINN does?  I tried hard to avoid adding any third party dependency,
maybe that was a mistake?  I could have speed up things by pulling in something
like [FinniversKit][f] for the UI.

One more thing. The feature I wanted to add was a collection of predefined
layouts the user could switch between. So for ex. you would press a
`UIBarButtonItem`  and it would change the layout from grid to table view. I
mainly wanted to support three layouts, the table view type one, regular
collection view grid and a nice full screen one.

[f]: https://github.com/finn-no/FinniversKit
