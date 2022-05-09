module Main exposing (main)

import Browser
import Html exposing (Html, blockquote, button, div, h2, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { quote : String }


type Msg
    = GetQuote


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetQuote ->
            ( { model | quote = model.quote ++ "A quote!" }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
        , p [ class "text-center" ]
            [ button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
        , blockquote []
            [ p [] [ text model.quote ]
            ]
        ]
