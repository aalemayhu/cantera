# cantera

A small app I am making for a technical challenge from FINN.no.

## Structure

In the top level directory of `cantera` there is the usual Xcode files.  I have
tried to structure everything in small groups, explained below with clickable
links for your convenience ;)

- [Storage](cantera/Storage) - wrapper to read / write JSON from application sandbox
- [Networking](cantera/Networking/) - contains URLSession wrapper functions to fetch the JSON payload, download images, endpoints, and image cache handling.
- [Extensions](cantera/Extensions/) - extensions to UIColor and String for convenience
- [Controller](cantera/Controller) - the view controllers used in the app
- [View](cantera/View/) - contains the collection view cell for the ads controller
- [Model](cantera/Model/) - split into API response model and UI model

TODO: add a proper description

TODO: higlight interesting bits in the code

TODO: mention potential improvements to the codebase

TODO: if I had more time what would I want to do

