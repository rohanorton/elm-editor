module Editor
    exposing
        ( State
        , emptyEditor
        , Msg
        , update
        , Config
        , fullConfig
        , view
        )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode exposing (Decoder)
import Json.Decode.Extra
import Editor.Document as Document exposing (Document)
import Dict exposing (Dict)


-- Model


type State
    = State
        { data : Document
        , buffer : String
        }


emptyEditor : State
emptyEditor =
    State
        { data = Document.empty
        , buffer = ""
        }


bufferSet : String -> { state | buffer : String } -> { state | buffer : String }
bufferSet newBuffer state =
    { state | buffer = newBuffer }



-- Update


type Msg
    = BeforeInput String
    | Input String
    | Select


update : Msg -> State -> State
update msg state =
    case Debug.log "Update:" msg of
        BeforeInput str ->
            state

        Input str ->
            state
                |> extractState
                |> bufferSet str
                |> Debug.log "hm"
                |> State

        Select ->
            state



-- View


type Config msg
    = Config
        { toMsg : Msg -> msg
        , readOnly : Bool
        }


fullConfig :
    { toMsg : Msg -> msg
    , readOnly : Bool
    }
    -> Config msg
fullConfig config =
    Config config


keypressRules : Dict Int String
keypressRules =
    Dict.fromList
        [ ( 13, "enter" )
        ]


keypressDecoder : Config msg -> Decoder msg
keypressDecoder config =
    Events.keyCode
        |> Json.Decode.andThen
            (\code ->
                keypressRules
                    |> Dict.get code
                    |> Maybe.map (toMsg config << BeforeInput)
                    |> Result.fromMaybe "This key is not handled"
                    |> Json.Decode.Extra.fromResult
            )


view : Config msg -> State -> Html msg
view config state =
    let
        _ =
            extractState state
                |> Debug.log "state:"

        children =
            extractState state
                |> .data
                |> Document.map (nodeView config)
    in
        Html.div
            [ Attr.contenteditable <| isEditable config
            , Events.onWithOptions "keydown" { preventDefault = True, stopPropagation = False } <| keypressDecoder config
            , Events.on "input" <| Json.Decode.map (toMsg config << Input) <| Json.Decode.at [ "target", "innerHTML" ] Json.Decode.string
              -- , Events.on "mouseup" <| Json.Decode.succeed <| toMsg config Select
              -- , Events.on "keyup" <| Json.Decode.succeed <| toMsg config Select
            ]
            children


nodeView : Config msg -> a -> Html msg
nodeView config foo =
    Html.div [] []



-- Utilities


{-| Sometimes it's nice to not have to use destructuring
-}
extractConfig : Config msg -> { toMsg : Msg -> msg, readOnly : Bool }
extractConfig (Config config) =
    config


extractState : State -> { data : Document, buffer : String }
extractState (State state) =
    state


isEditable : Config msg -> Bool
isEditable (Config config) =
    not config.readOnly


toMsg : Config msg -> (Msg -> msg)
toMsg (Config config) =
    config.toMsg
