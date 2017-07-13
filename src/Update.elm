module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (..)
import Routing exposing (Route(..), parseLocation)
import Navigation exposing (Location)
import RemoteData exposing (RemoteData)
import ContentUtils
import Types exposing (Content)
import Helpers exposing (cmd)
import FetchContent


changeUrlCommand : Model -> Route -> Content -> Cmd Msg
changeUrlCommand model route content =
    case route of
        ArchiveRoute ->
            Cmd.none

        TrainingRoute ->
            Cmd.none

        AuthorRoute ->
            Cmd.none

        _ ->
            FetchContent.fetch content model.url.base_url


changeUrlProcedure : Model -> Route -> ( Model, Cmd Msg )
changeUrlProcedure model route =
    case getContentForRoute route of
        Nothing ->
            ( { model | route = NotFoundRoute }, Navigation.modifyUrl (model.url.base_url ++ "/404") )

        Just content ->
            let
                newContent =
                    { content | markdown = RemoteData.Loading }

                newCmd =
                    changeUrlCommand model route newContent
            in
                ( { model
                    | currentContent = newContent
                    , route = route
                  }
                , newCmd
                )


getContentForRoute : Route -> Maybe Content
getContentForRoute =
    ContentUtils.findByRoute ContentUtils.allContent


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location model.url.base_url
            in
                Debug.log (toString (newRoute))
                    changeUrlProcedure
                    model
                    newRoute

        NewUrl url ->
            Debug.log (url)
                model
                ! [ Cmd.batch
                        [ (Navigation.newUrl url)
                        , cmd (HideSideMenu)
                        ]
                  ]

        FetchedContent response ->
            let
                currentContent =
                    model.currentContent

                newContent =
                    { currentContent | markdown = response }
            in
                ( { model | currentContent = newContent }
                , Cmd.none
                )

        ToggleSideMenu ->
            ( { model | ui = Ui (not model.ui.sideMenuActive) }
            , Cmd.none
            )

        HideSideMenu ->
            ( { model | ui = Ui False }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )
