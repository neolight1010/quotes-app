module Main exposing (main)

import Browser
import Debug exposing (toString)
import Html exposing (Html, blockquote, button, div, h2, h3, input, label, p, text)
import Html.Attributes exposing (class, for, id, type_, value)
import Html.Events exposing (onClick)
import Http
import Json.Decode
import Json.Encode
import Url.Builder
import Html.Events exposing (onInput)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { quote : String
    , username : String
    , password : String
    , token : String
    , errorMsg : String
    }


type Msg
    = GetQuote
    | GotQuote (Result Http.Error String)
    | AuthedUser (Result Http.Error String)
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "" "" "" "", fetchRandomQuote )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuote )

        GotQuote result ->
            ( gotQuote result model, Cmd.none )

        AuthedUser result ->
            ( authedUser result model, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        isLoggedIn : Bool
        isLoggedIn =
            not <| String.isEmpty model.token

        authBoxView =
            let
                showErrorClass : String
                showErrorClass =
                    if String.isEmpty model.errorMsg then
                        "hidden"

                    else
                        ""

                greeting : String
                greeting =
                    "Hello, " ++ model.username ++ "!"
            in
            if isLoggedIn then
                div [ id "greeting" ]
                    [ h3 [ class "text-center" ] [ text greeting ]
                    , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]
                    ]

            else
                div [ id "form" ]
                    [ h2 [ class "text-center" ] [ text "Log In or Register" ]
                    , div [ class showErrorClass ]
                        [ div [ class "alert alert-danger" ] [ text model.errorMsg ]
                        ]
                    , div [ class "form-group-row" ]
                        [ div [ class "col-md-offset-2 col-md-8" ]
                            [ label [ for "username" ] [ text "Username:" ]
                            , input [ id "username", type_ "text", class "form-control", value model.username, onInput SetUsername ] []
                            ]
                        ]
                    , div [ class "form-group-row" ]
                        [ div [ class "col-md-offset-2 col-md-8" ]
                            [ label [ for "password" ] [ text "Password:" ]
                            , input [ id "password", type_ "password", class "form-control", value model.password, onInput SetPassword ] []
                            ]
                        ]
                    , div [ class "text-center"]
                        [ button [class "btn btn-link", onClick ClickRegisterUser] [text "Register"]

                            ]
                    ]
    in
    div [ class "container" ]
        [ h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
        , p [ class "text-center" ]
            [ button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
        , blockquote []
            [ p [] [ text model.quote ]
            ]
        , div [ class "jumbotron text-left" ]
            [ authBoxView
            ]
        ]


gotQuote : Result Http.Error String -> Model -> Model
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
    "http://localhost:3001"


randomQuoteUrl : String
randomQuoteUrl =
    Url.Builder.crossOrigin baseApiUrl [ "api", "random-quote" ] []


registerUrl : String
registerUrl =
    Url.Builder.crossOrigin baseApiUrl [ "users" ] []


userEncoder : Model -> Json.Encode.Value
userEncoder model =
    Json.Encode.object
        [ ( "username", Json.Encode.string model.username )
        , ( "password", Json.Encode.string model.password )
        ]


authUser : Model -> String -> Cmd Msg
authUser model url =
    Http.post
        { url = url
        , body =
            model
                |> userEncoder
                |> Http.jsonBody
        , expect = Http.expectJson AuthedUser tokenDecoder
        }


tokenDecoder : Json.Decode.Decoder String
tokenDecoder =
    Json.Decode.field "access_token" Json.Decode.string


authedUser : Result Http.Error String -> Model -> Model
authedUser result model =
    case result of
        Err error ->
            { model | errorMsg = toString error }

        Ok token ->
            { model | token = token, password = "", errorMsg = "" } |> Debug.log "Got new token!"
