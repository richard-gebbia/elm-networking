module Counters where

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode 
import Json.Encode
import Signal exposing (Signal)

-- MODEL

type alias Model = 
    { yours: Int            -- the counter that you can control
    , other's: Int          -- the counter that the other person controls
    , clientID: String      -- your ID on the server
    }

init : Model 
init = 
    { yours = 0
    , other's = 0
    , clientID = clientID
    }

-- UPDATE

type Action 
    = Increment 
    | Decrement 
    | SetOther Int
    | NoOp

type SideEffect 
    = SetValue String Int
    | NoSideEffects


sideEffectToJson : SideEffect -> Json.Encode.Value
sideEffectToJson sideEffect =
    case sideEffect of
        SetValue clientID value ->
            Json.Encode.object
                [ ("requestType", Json.Encode.string "setValue")
                , ("clientID", Json.Encode.string clientID)
                , ("value", Json.Encode.int value)
                ]

        _ ->
            Json.Encode.null


update : Action -> Model -> (Model, SideEffect)
update action model = 
    case action of
        -- if we increment, tell the server
        Increment -> 
            let newYours = model.yours + 1
            in
            ({ model | yours <- newYours }, SetValue model.clientID newYours)

        -- if we decrement, tell the server
        Decrement -> 
            let newYours = model.yours - 1
            in
            ({ model | yours <- newYours }, SetValue model.clientID newYours)

        -- this should happen when we receive an update about the other
        -- counter from the server
        SetOther other ->
            ({ model | other's <- other }, NoSideEffects)

        _  -> 
            (model, NoSideEffects)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ div [] [ text "Yours:" ]
        , button [ onClick address Decrement ] [ text "-" ]
        , div [] [ text (toString model.yours) ]
        , button [ onClick address Increment ] [ text "+" ]
        , br [] []  -- these are just line breaks for space in the page
        , br [] []  -- these are just line breaks for space in the page
        , div [] [ text "Other's:" ]
        , u [ style [ ("color", "green") ]] [ text (toString model.other's) ]
        ]

-- MAIN

type alias App =
    { model: Signal Model               -- our state at each step
    , html: Signal Html                 -- our output at each step
    , sideEffects: Signal SideEffect    -- side effects at each step
    }                                   -- by "step" I'm referring to each
                                        --  instance of the "update" function
                                        --  getting called


actions : Signal.Mailbox Action
actions = 
    Signal.mailbox NoOp


app : App
app =
    let updateStep : Action -> (Model, SideEffect) -> (Model, SideEffect)
        updateStep action (model, _) =
            update action model

        signals : Signal Action
        signals =
            Signal.mergeMany
                [ actions.signal                -- actions from UI
                , Signal.map SetOther setOther  -- actions from the server
                ]

        step : Signal (Model, SideEffect)
        step =
            Signal.foldp updateStep (init, NoSideEffects) signals

        model : Signal Model
        model = 
            Signal.map fst step
    in
    { model = model
    , html = Signal.map (view actions.address) model
    , sideEffects = Signal.map snd step
    }


main =
    app.html


port clientID : String

port setOther : Signal Int

port sideEffects : Signal Json.Encode.Value
port sideEffects =
    Signal.map sideEffectToJson app.sideEffects