module Main exposing (..)

import Html exposing (..)
import Html.App
import Editor


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { editorState : Editor.State
    }


init : ( Model, Cmd Msg )
init =
    { editorState = Editor.emptyEditor
    }
        ! []



-- Update


type Msg
    = EditorMsg Editor.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg msg ->
            { model | editorState = Editor.update msg model.editorState } ! []



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View


editorConfig : Editor.Config Msg
editorConfig =
    Editor.fullConfig
        { toMsg = EditorMsg
        , readOnly = False
        }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Editor" ]
        , Editor.view editorConfig model.editorState
        ]
