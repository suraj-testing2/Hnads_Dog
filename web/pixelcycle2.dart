import 'dart:html';
import 'dart:async' show Future, Completer;
import 'dart:json' as json;

import 'package:pixelcycle2/src/palette.dart' show Palette, Brush;
import 'package:pixelcycle2/src/movie.dart' show Movie, Frame, WIDTH, HEIGHT;
import 'package:pixelcycle2/src/player.dart' show Player;
import 'package:pixelcycle2/src/server.dart' as server;
import 'package:pixelcycle2/src/ui.dart' as ui;

RegExp savedMoviePath = new RegExp(r"^/m/(\d+)$");

void main() {
  var palette = new Palette.standard();
  var brush = new Brush(palette);
  brush.selection = 26;

  loadPlayer(palette).then((Player player) {
    ui.onLoad(player, brush);
    player.playing = true;
  });
}

Future<Player> loadPlayer(Palette palette) {

  var match = savedMoviePath.firstMatch(window.location.pathname);
  var player;
  if (match != null) {
    var c = new Completer();
    server.load(match.group(1)).then((String data) {
      print("got data");
      c.complete(deserializePlayer(palette, data));
    });
    return c.future;
  }

  var movie = new Movie.blank(palette, 8);
  player = new Player(movie);
  player.speed = 10;
  return new Future.value(player);
}

Player deserializePlayer(Palette palette, String dataString) {
  Map data = json.parse(dataString);
  assert (data["Version" == 1]);
  assert (data["Width"] == WIDTH && data["Height"] == HEIGHT);

  var movie = new Movie(palette);
  for (String frameString in data["Frames"]) {
    List<int> pixels = json.parse(frameString);
    Frame f = new Frame.fromPixels(palette, pixels);
    movie.frames.add(f);
  }
  var player = new Player(movie);
  player.speed = data["Speed"];
  return player;
}