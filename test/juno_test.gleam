import gleam/dict
import gleam/dynamic
import gleam/json
import gleeunit
import gleeunit/should
import juno

pub fn main() {
  gleeunit.main()
}

pub fn decode_test() {
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
  |> should.be_ok
  |> should.equal(get_map())
}

pub fn decode_number_test() {
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

  juno.decode(
    30.2
    |> json.float
    |> json.to_string,
    [active_player_decoder, game_decoder],
  )
  |> should.be_ok
  |> should.equal(juno.Float(30.2))
}

pub fn decode_object_string_error_test() {
  juno.decode_object(
    "Gattaca"
    |> json.string
    |> json.to_string,
    [],
  )
  |> should.be_error
}

pub fn decode_object_test() {
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

  juno.decode_object(json, [active_player_decoder, game_decoder])
  |> should.be_ok
  |> should.equal(get_map())
}

type Entity {
  Player(id: String, score: Int, eliminated: Bool)
  Game(id: String, players: List(String), winner: String, prize: String)
}

const json = "{
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

fn get_map() {
  juno.Object(
    dict.from_list([
      #(
        "2023-11-24",
        juno.Object(
          dict.from_list([
            #("weather", juno.String("rainy")),
            #(
              "14:00",
              juno.Custom(Game("G528", ["P10", "P6"], "P10", "vacation")),
            ),
            #(
              "16:00->21:00",
              juno.Array([
                juno.Custom(Game("G561", ["P10", "P3"], "P10", "toaster")),
                juno.Custom(Game("G595", ["P3", "P6"], "P3", "car")),
              ]),
            ),
            #(
              "attending",
              juno.Object(
                dict.from_list([
                  #(
                    "anton",
                    juno.Object(
                      dict.from_list([
                        #("id", juno.String("P36")),
                        #("eliminated", juno.Bool(True)),
                        #("scores", juno.Array([juno.Int(45), juno.Int(55)])),
                      ]),
                    ),
                  ),
                  #("gerome", juno.Custom(Player("P6", 15, False))),
                  #("irene", juno.Custom(Player("P10", 21, False))),
                  #("vincent", juno.Custom(Player("P3", 28, False))),
                ]),
              ),
            ),
          ]),
        ),
      ),
    ]),
  )
}
