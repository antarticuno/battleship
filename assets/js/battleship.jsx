import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import _ from 'lodash';
import $ from 'jquery';
import SetupForm from './setup';

export default function game_init(root, channel) {
  ReactDOM.render(<Battleship channel={channel} />, root);
}

class Battleship extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;

    this.state = {
	    my_board: {},
	    opponents: {},
	    my_turn: "",
	    lost: false,
	    board_size: {},
	    rankings: [],         // array of names of players who have lost
	    phase: "joining",     // joining, setup, playing, gameover phases
    }

    this.channel
      .join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.error("Unable to join", resp); });

    this.channel.on("update_view", this.gotView.bind(this));
    this.channel.on("error", err => { console.error(err); });
  }

  on_place(type, startX, startY, isHorizontal) {
    let place = {
      "player_name": window.playerName, 
      "type": type, 
      "start_x": _.parseInt(startX),
      "start_y": _.parseInt(startY),
      "horizontal?": (isHorizontal == "true")
    };
    console.log(place);
    this.channel.push("place", place);
  }

  render() {
    switch (this.state.phase) {
      case "joining":
	      return this.renderJoining();
        break;
      case "setup":
        return this.renderSetup();
        break;
      case "playing":
        return this.renderPlaying();
        break;
      case "gameover":
	      return this.renderGameOver();
        break;
      default:
	      return (<div className="container">Waiting for next phase...</div>);
    }
  }

  gotView(view) {
    console.log("got_view", view);
    this.setState(view);
  }

  renderJoining() {
    return (<div className="container">Waiting for other players to join...</div>);
  }

  renderPlaying() {
    return (
      <div className="container">
        <div className="row">
          <div className="col">
            <EnemyBoards />
          </div>
          <div className="col">
            <div className="row">
              <div className="col">
                <PlayerInput />
              </div>
              <div className="col">
                <PlayerBoard />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  renderSetup() {
    return (
      <div className="container">
        <div className="row">
        <div className="column">
          <PlayerBoard 
            myBoard={this.state.my_board} 
            width={this.state.board_size.width}
            height={this.state.board_size.height}
            status={this.state.status}
          />
        </div>
          <div className="column">
            <SetupForm 
              maxX={this.state.board_size.width}
              maxY={this.state.board_size.height}
              onSubmit={this.on_place.bind(this)}
            />
        </div>
      </div>
    </div>
    );
  }

  renderGameOver() {
    return (<ScoreBoard rankings={this.state.rankings} />);
  }
}

function PlayerInput(props) {
  return (<div>
	    Target X: <input id="target_x" type="text" />
	    Target Y: <input id="target_y" type="text" />
	    <button>Sting!</button>
	  </div>);
}

function Board(props) {
  let status = props.status;
  let caterpillars = _.filter(props.caterpillarCoords, null);

  let rows = [];
  for (let r = 0; r < props.width; r++) {
    let row = [];
    for (let c = 0; c < props.height; c++) {
      // TODO render hit/miss
      let inCaterpillar = caterpillars.includes(r + "," + c);
      row.push(<div key={c} className={"column" + (inCaterpillar ? " caterpillar" : "")}>X</div>);
    }
    rows.push(<div key={r} className="row">{row}</div>);
  }

  return <div className="board container">{rows}</div>;
}

function PlayerBoard(props) {
  let status = props.myBoard.status;
  let caterpillars = []
  _.forIn(props.myBoard.caterpillars, function(value, key) {
    caterpillars = caterpillars.concat(value);
  });
  return <Board width={props.width} height={props.height} status={status} caterpillarCoords={caterpillars} />;
}

function EnemyBoards(props) {
  return (<div></div>);
}

function ScoreBoard(props) {
  let {rankings} = props;
  let r = _.map(rankings, (player_name, ii) => {return <p key={ii}>{ii + 1}. player_name</p>});
  return r;
}
