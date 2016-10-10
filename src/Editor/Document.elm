module Editor.Document
    exposing
        ( Document
        , empty
        , map
        )

import Editor.Node exposing (Node)


empty : Document
empty =
    Document { nodes = [] }


type Document
    = Document { nodes : List Node }


map : (Node -> b) -> Document -> List b
map fn docs =
    []
