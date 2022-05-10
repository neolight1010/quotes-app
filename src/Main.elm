module Main exposing (main)

import Browser
import Html exposing (Html, blockquote, button, div, h2, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http


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
    | GotQuote (Result Http.Error String)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "", fetchRandomQuote )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuote )

        GotQuote result ->
            ( gotQuote result model, Cmd.none )


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


gotQuote : (Result Http.Error String) -> Model -> Model
gotQuote result model =
    case result of
       Err _ ->
            model
       Ok quote ->
           { model | quote = quote }


fetchRandomQuote : Cmd Msg
fetchRandomQuote =
    Http.get
        { url = randomQuoteUrl
        , expect = Http.expectString GotQuote
        }


baseApiUrl : String
baseApiUrl =
    "http://localhost:3001/"


randomQuoteUrl : String
randomQuoteUrl =
    baseApiUrl ++ "api/random-quote"
