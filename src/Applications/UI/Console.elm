module UI.Console exposing (view)

import Chunky exposing (..)
import Color
import Color.Ext as Color
import Conditional exposing (..)
import Css
import Css.Ext as Css
import Css.Media
import Html as UnstyledHtml
import Html.Styled as Html exposing (Html, text)
import Html.Styled.Attributes exposing (class, css, style)
import Html.Styled.Events exposing (on, onClick)
import Json.Decode as Decode
import Material.Icons exposing (Coloring(..))
import Material.Icons.Av as Icons
import Maybe.Extra as Maybe
import Queue
import Tachyons.Classes as T
import UI.Css
import UI.Kit
import UI.Queue as Queue
import UI.Reply exposing (Reply(..))
import UI.Tracks as Tracks



-- 🗺


view : Maybe Queue.Item -> Bool -> Bool -> Bool -> Bool -> Bool -> Html Reply
view activeQueueItem repeat shuffle hasStalled isLoading isPlaying =
    brick
        [ css consoleStyles ]
        [ T.mt1, T.tc, T.w_100 ]
        [ -----------------------------------------
          -- Now Playing
          -----------------------------------------
          chunk
            [ T.f6
            , T.i
            , T.lh_copy
            , T.pb3
            , T.pt3
            , T.white
            ]
            [ if hasStalled then
                slab
                    Html.span
                    []
                    [ T.dib ]
                    [ text "Audio connection got interrupted, trying to reconnect ..." ]

              else if isLoading then
                text "Loading track ..."

              else
                case Maybe.map .identifiedTrack activeQueueItem of
                    Just ( _, { tags } ) ->
                        Html.span
                            [ onClick ScrollToNowPlaying, class T.pointer ]
                            [ text (tags.artist ++ " - " ++ tags.title) ]

                    Nothing ->
                        text "Diffuse"
            ]

        -----------------------------------------
        -- Progress Bar
        -----------------------------------------
        , brick
            [ on "click" (clickLocationDecoder Seek) ]
            [ T.pointer
            , T.pv1
            ]
            [ brick
                [ css progressBarStyles ]
                [ T.br1 ]
                [ brick
                    [ css progressBarInnerStyles, style "width" "0" ]
                    [ "progressBarValue" ]
                    []
                ]
            ]

        -----------------------------------------
        -- Buttons
        -----------------------------------------
        , brick
            [ css buttonsContainerStyles ]
            [ T.flex
            , T.justify_between
            , T.justify_center_ns
            , T.mb2
            , T.mt3
            , T.pb1
            ]
            [ button (smallLight repeat) (icon Icons.repeat 18) ToggleRepeat
            , button lightPlaceHolder (icon Icons.fast_rewind 20) RewindQueue
            , button (largeLight isPlaying) play TogglePlayPause
            , button lightPlaceHolder (icon Icons.fast_forward 20) ShiftQueue
            , button (smallLight shuffle) (icon Icons.shuffle 18) ToggleShuffle
            ]
        ]


button : Html msg -> Html msg -> msg -> Html msg
button light content msg =
    brick
        [ onClick msg ]
        [ T.flex, T.flex_column, T.items_center, T.mh1, T.mh4_ns, T.ph1, T.pointer ]
        [ brick
            [ css [ Css.height (Css.px 4) ] ]
            []
            [ light ]
        , brick
            [ css [ Css.height (Css.px 25) ] ]
            [ T.flex, T.items_center, T.mv2 ]
            [ content ]
        ]


smallLight : Bool -> Html msg
smallLight isOn =
    brick
        [ css
            [ Css.backgroundColor
                (ifThenElse isOn (Css.rgb 157 174 255) (Css.rgba 255 255 255 0.25))
            , Css.height (Css.px 4)
            , Css.width (Css.px 4)
            ]
        ]
        [ T.br_100 ]
        []


largeLight : Bool -> Html msg
largeLight isOn =
    brick
        [ css
            [ Css.backgroundColor
                (ifThenElse isOn (Css.rgb 198 254 153) (Css.rgba 255 255 255 0.25))
            , Css.height (Css.px 4)
            , Css.left (Css.px -2)
            , Css.width (Css.px 17)
            ]
        ]
        [ T.br_pill, T.relative ]
        []


lightPlaceHolder : Html msg
lightPlaceHolder =
    brick
        [ css [ Css.height (Css.px 4) ] ]
        []
        []


play : Html msg
play =
    brick
        [ css playTextStyles ]
        [ T.fw7, T.nowrap, T.relative ]
        [ text "PLAY" ]


icon : (Int -> Coloring -> UnstyledHtml.Html msg) -> Int -> Html msg
icon iconFunction int =
    Html.fromUnstyled (iconFunction int <| Color iconColor)



-- 🖼


buttonsContainerStyles : List Css.Style
buttonsContainerStyles =
    [ Css.disableUserSelection ]


consoleStyles : List Css.Style
consoleStyles =
    [ Css.Media.withMedia
        [ UI.Css.largeMediaQuery ]
        [ Css.maxWidth (Css.vh UI.Kit.insulationWidth)
        , Css.minWidth (Css.px 840)
        ]
    ]


iconColor : Color.Color
iconColor =
    Color.rgba 1 1 1 0.875


playTextStyles : List Css.Style
playTextStyles =
    [ Css.color (Color.toElmCssColor iconColor)
    , Css.fontFamilies UI.Kit.headerFontFamilies
    , Css.fontSize (Css.px 11.25)
    , Css.letterSpacing (Css.px 3.75)
    ]


progressBarStyles : List Css.Style
progressBarStyles =
    [ Css.backgroundColor (Css.rgba 255 255 255 0.25)
    , Css.disableUserSelection
    , Css.height (Css.px 3)
    ]


progressBarInnerStyles : List Css.Style
progressBarInnerStyles =
    [ Css.backgroundColor (Css.rgba 255 255 255 0.325)
    , Css.height (Css.px 3)
    ]



-- EVENTS


clickLocationDecoder : (Float -> msg) -> Decode.Decoder msg
clickLocationDecoder message =
    Decode.map message
        (Decode.map2
            (\a b -> a / b)
            (Decode.at [ "offsetX" ] Decode.float)
            (Decode.at [ "currentTarget", "clientWidth" ] Decode.float)
        )
