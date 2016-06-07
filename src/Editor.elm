port module Editor exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Html.App as Html
import Array exposing (Array)
import Regex exposing (..)


debug : Bool
debug =
    True


main : Program Never
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { blocks : List Block
    , selection : Selection
    }


type alias Block =
    { text : String
    }


type alias Selection =
    { startsAt : Int
    , startOffset : Int
    , endsAt : Int
    , endOffset : Int
    }


init : ( Model, Cmd Msg )
init =
    { blocks = [ Block "Foo" ]
    , selection = Selection 0 0 0 0
    }
        ! []



-- Update


type Msg
    = Change String
    | Key Int


port setCursorPosition : String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        Change str ->
            model ! []

        -- <CR>
        Key 13 ->
            let
                block' =
                    Block ""

                selection' =
                    nextLine model.selection
            in
                { model | blocks = model.blocks ++ [ block' ], selection = selection' } ! []

        Key _ ->
            model ! []


removeNewLines : String -> String
removeNewLines =
    replace All (regex "\n") (always "")


nextLine : Selection -> Selection
nextLine sel =
    { sel | startsAt = sel.startsAt + 1, endsAt = sel.endsAt + 1 }



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View


targetText : Json.Decoder String
targetText =
    Json.at [ "target", "innerText" ] Json.string


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)


view : Model -> Html Msg
view model =
    div []
        [ buttonBar
        , contentEditor model.blocks
        , debugger model
        ]


buttonBar : Html Msg
buttonBar =
    div []
        [ button [] [ text "Bold" ]
        , button [] [ text "Italic" ]
        , button [] [ text "Underline" ]
        ]


contentEditor : List Block -> Html Msg
contentEditor blocks =
    div
        [ contenteditable True
        , onWithOptions "input" { preventDefault = True, stopPropagation = True } <| Json.map Change targetText
        , onKeyDown Key
        , id "EditorContent"
        ]
        [ div []
            <| List.map renderBlock blocks
        ]


renderBlock : Block -> Html Msg
renderBlock block =
    div [] [ text block.text ]


debugger : Model -> Html Msg
debugger model =
    if debug then
        text <| toString model
    else
        text ""
