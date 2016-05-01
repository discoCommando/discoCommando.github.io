module Cztery where

import Http exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task exposing (Task, andThen)
import String exposing (..)
import Json.Decode exposing (..)
import Json.Encode exposing (..)
import Effects exposing (Effects, Never)
import StartApp

-- MODEL

type alias Model = {
  temp : String,
  list : List Wpis,
  lastLists : List (List Wpis)}

type alias Wpis = {
  nr : Int,
  kto : String,
  ile : Int}
--toNextTick : Int -> Time -- z tempa w milisekundy
--toNextTick tempo = toFloat ((tempo*1000) / 60)

convertLine : String -> Wpis
convertLine str =
  let
    arr = String.split "," str
    fst = List.head arr |> Maybe.withDefault "Bartek"
    snd' = List.head (List.drop 1 arr) |> Maybe.withDefault "0" |> String.toInt
    snd = case snd' of
      Ok i -> i
      Err str -> 0
  in
    Wpis 0 fst snd

unconvertLine : Wpis -> String
unconvertLine w = w.kto ++ "," ++ (toString w.ile)

ponumeruj : List Wpis -> List Wpis
ponumeruj l = List.indexedMap (\int wpis -> {wpis | nr = int}) l |> List.map (\wpis -> {wpis | nr = wpis.nr + 1})

sortFunction : List Wpis -> List Wpis
sortFunction a = List.sortBy .kto a |> List.sortBy .ile |> ponumeruj

getModelFromRaw : String -> List Wpis
getModelFromRaw s = String.trim s |> lines |> List.map convertLine |> sortFunction

getRawFromModel : List Wpis -> String
getRawFromModel l = List.map unconvertLine l |> List.intersperse "\n" |> String.concat

model : Model
model = {temp = "NIC", list = [], lastLists = []}

init = (model, Effects.none)
-- VIEW

viewList : Signal.Address Action -> List Wpis -> List Html
viewList address l = 
  let 
    viewSingle wpis = 
      tr [] [
        th 
          []
          [ text <| toString wpis.nr ],
        th 
          [] 
          [ text wpis.kto ],
        th 
          [] 
          [ text <| toString wpis.ile ],
        th 
          [] 
          [ button 
            [ onClick address (ButtonClick wpis.kto),
              class "btn btn-primary btn-sm" 
            ] 
            [ text "Zapłacił" ]
          ]
      ]
  in List.map viewSingle l

viewTable : Signal.Address Action -> Model -> Html
viewTable address model = 
    table 
    [ class "table" ]
    [ thead 
      [] 
      [ tr 
        [] 
        [ th [] [ text "#" ],
          th [] [ text "Kto" ], 
          th [] [ text "Ile" ], 
          th [] [ text "Akcja" ]
        ]
      ],

      tbody
      []
      (viewList address model.list)           
    ]

view : Signal.Address Action -> Model -> Html
view address model =
  div 
  []
  [ 
    div 
    [ class "row" ]
    [ div
      [ class "col-md-6 col-md-offset-3" ]
      [ viewTable address model ]
    ],

    div
    [ class "row" ]
    [ 
      div
      [ class "col-md-3 col-md-offset-3" ]
      [ a
        (
        if (List.isEmpty model.lastLists) 
        then 
          [ class "btn btn-lg btn-default disabled" ] 
        else 
          [ onClick address ZatwierdźButtonClick,
            class "btn btn-lg btn-default"
          ]
        )
        [ text "Zatwierdź" ]
      ],

      div
      [ class "col-md-4 " ]
      [ a
        (if (List.isEmpty model.lastLists) 
        then 
          [ class "btn btn-lg btn-danger disabled" ] 
        else 
          [ onClick address CofnijButtonClick,
            class "btn btn-lg btn-danger  "
          ]
        )
        [ text "Cofnij" ]
      ]
    ]
  ]
  
-- UPDATE

type Action = NoOp | GetSite String | ButtonClick String | CofnijButtonClick | ZatwierdźButtonClick

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)
    GetSite s ->
      ({model | temp = s, list = getModelFromRaw s}, Effects.none)
    ButtonClick s ->
      ({model | 
        list = List.map (\wpis -> if (wpis.kto == s) then {wpis | ile = wpis.ile + 1} else wpis) model.list |> sortFunction,
        lastLists = [model.list] ++ model.lastLists
      },
      Effects.none)
    CofnijButtonClick ->
      ({model | list = List.head model.lastLists |> Maybe.withDefault model.list, lastLists = List.drop 1 model.lastLists}, Effects.none)
    ZatwierdźButtonClick ->
      (model, Effects.task <| ((setSiteTask <| getRawFromModel model.list) `Task.onError` (\_ -> Task.succeed "")) `Task.andThen` (\_ -> Task.succeed NoOp))
-- MAILBOXES

inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp
  
--modelSignal : Signal Model
--modelSignal =
--  Signal.foldp update model inbox.signal

-- MAIN

getSiteTask : Task Error String
getSiteTask = Http.url "http://students.mimuw.edu.pl/~tw336034/ktoPlaci/server.php"  [("mode", "GET")]
  |> Http.getString 
sendToInbox : String -> Task x ()
sendToInbox s = let foo = Debug.log s s in Signal.send inbox.address <| GetSite s

setSiteTask : String -> Task Error String 
setSiteTask s = Http.url "http://students.mimuw.edu.pl/~tw336034/ktoPlaci/server.php"  [("mode", "SET"), ("content", s)] 
  |> Http.getString

--port timer : Signal (Task x ())
--port timer =
--  Signal.map 

port getAndSendSite : Task Error ()
port getAndSendSite = getSiteTask `Task.andThen` sendToInbox

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

--main : Signal Html
--main =
--  Signal.map (view inbox.address) modelSignal

app =
  StartApp.start
  { init = init
  , update = update
  , view = view
  , inputs = [inbox.signal]
  }


main =
  app.html