module Editor.Node exposing (Node)


type Node
    = Block BlockNode
    | Inline InlineNode
    | Text TextNode


type alias BlockNode =
    { name : String
    , children : List Node
    }


type alias InlineNode =
    { name : String
    , children : List InlineOrText
    }


type alias TextNode =
    { markableChars : List MarkableCharacter }


type InlineOrText
    = InlineOption InlineNode
    | TextOption TextNode


type alias MarkableCharacter =
    { character : Char
    , marks : List Mark
    }


type alias Mark =
    { styles : List ( String, String ) }
