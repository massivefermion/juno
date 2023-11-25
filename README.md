<!-- ![juno](https://raw.githubusercontent.com/massivefermion/bison/main/banner.png) -->
![juno](https://raw.githubusercontent.com/massivefermion/juno/main/banner.png)

[![Package Version](https://img.shields.io/hexpm/v/juno)](https://hex.pm/packages/juno)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/juno)

# juno 

Juno is a tool for decoding JSON in a more flexible way, which can be useful in situations where the exact structure of the data is not known but there are still patterns in it that need to be captured.

## 🦋 Quick start

```sh
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```

## 🦋 Installation

```sh
gleam add juno
```

## 🦋 Usage

```gleam
import gleam/dynamic
import juno

pub type Entity {
  Player(id: String, score: Int, eliminated: Bool)
  Game(id: String, players: List(String), winner: String, prize: String)
}

pub fn main() {
  let json = "{
      \"2023-11-24\": {
        \"weather\": \"rainy\",
        \"attending\": {
          \"anton\": {
            \"id\": \"P36\",
            \"scores\": [45, 55],
            \"eliminated\": true
          },
          \"vincent\": {
            \"id\": \"P3\",
            \"score\": 28,
            \"eliminated\": false
          },
          \"gerome\": {
            \"id\": \"P6\",
            \"score\": 15,
            \"eliminated\": false
          },
          \"irene\": {
            \"id\": \"P10\",
            \"score\": 21,
            \"eliminated\": false
          }
        },
        \"14:00\": {
          \"id\": \"G528\", 
          \"players\": [
            \"P10\",
            \"P6\"
          ],
          \"winner\": \"P10\",
          \"prize\": \"vacation\"
        },
        \"16:00->21:00\": [
          {
            \"id\": \"G561\", 
            \"players\": [
              \"P10\",
              \"P3\"
            ],
            \"winner\": \"P10\",
            \"prize\": \"toaster\"
          },
          {
            \"id\": \"G595\", 
            \"players\": [
              \"P3\",
              \"P6\"
            ],
            \"winner\": \"P3\",
            \"prize\": \"car\"
          } 
        ]
      }
    }"

  let active_player_decoder =
    dynamic.decode3(
      Player,
      dynamic.field("id", dynamic.string),
      dynamic.field("score", dynamic.int),
      dynamic.field("eliminated", dynamic.bool),
    ) 

  let game_decoder =
    dynamic.decode4(
      Game,
      dynamic.field("id", dynamic.string),
      dynamic.field("players", dynamic.list(dynamic.string)),
      dynamic.field("winner", dynamic.string),
      dynamic.field("prize", dynamic.string),
    )

  juno.decode(json, [active_player_decoder, game_decoder])
}
```