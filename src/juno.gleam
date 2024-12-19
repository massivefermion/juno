import gleam/dict
import gleam/dynamic
import gleam/json
import gleam/list
import gleam/option

pub type Value(a) {
  Null
  Int(Int)
  Custom(a)
  Bool(Bool)
  Float(Float)
  String(String)
  Array(List(Value(a)))
  Object(dict.Dict(String, Value(a)))
}

pub fn decode(json: String, custom_decoders: List(dynamic.Decoder(a))) {
  json.decode(json, value(_, list.map(custom_decoders, wrap)))
}

pub fn decode_object(json: String, custom_decoders: List(dynamic.Decoder(a))) {
  json.decode(json, object(list.map(custom_decoders, wrap)))
}

fn wrap(decoder) {
  dynamic.decode1(Custom, decoder)(_)
}

fn value(dyn, custom_decoders) {
  let value_decoders =
    list.append(custom_decoders, [
      int(),
      bool(),
      float(),
      string(),
      array(custom_decoders),
      object(custom_decoders),
    ])

  case dynamic.optional(dynamic.any(value_decoders))(dyn) {
    Ok(option.Some(value)) -> Ok(value)
    Ok(option.None) -> Ok(Null)
    Error(error) -> Error(error)
  }
}

fn object(custom_decoders) {
  dynamic.decode1(
    Object,
    dynamic.dict(dynamic.string, value(_, custom_decoders)),
  )(_)
}

fn array(custom_decoders) {
  dynamic.decode1(Array, dynamic.list(value(_, custom_decoders)))(_)
}

fn int() {
  dynamic.decode1(Int, dynamic.int)(_)
}

fn float() {
  dynamic.decode1(Float, dynamic.float)(_)
}

fn bool() {
  dynamic.decode1(Bool, dynamic.bool)(_)
}

fn string() {
  dynamic.decode1(String, dynamic.string)(_)
}
