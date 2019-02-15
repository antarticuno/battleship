// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".

// Import dependencies
import "phoenix_html"
import $ from "jquery";

// Import local files
import socket from "./socket"
import game_init from "./battleship";

$(() => {
  let root = $('#root')[0];
  if (root) {
    let channel = socket.channel("games:" + window.gameName, {player_name: window.playerName});
    game_init(root, channel);
  }
});