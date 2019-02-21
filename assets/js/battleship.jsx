import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
// import $ from 'jquery';
import SetupForm from './setup';
import PlayerInput from './player-input';
import {PlayerBoard, EnemyBoards} from './boards';

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
	    my_turn: false,
	    board_size: {},
	    rankings: [],         // array of names of players who have lost
	    phase: "joining",     // joining, setup, playing, gameover phases
    };

    this.channel
      .join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.error("Unable to join", resp); });

    this.channel.on("update_view", this.gotView.bind(this));
    this.channel.on("error", err => { console.error(err); });
  }

  gotView(view) {
    console.log("got_view", view);
    this.setState(view);
  }

  onPlace(type, startX, startY, isHorizontal) {
    let place = {
      "type": type, 
      "start_x": _.parseInt(startX),
      "start_y": _.parseInt(startY),
      "horizontal?": (isHorizontal == "true")
    };
    this.channel.push("place", place);
  }

  onSting(x, y, opponent) {
    if (this.state.my_turn) {
      let sting = {
        x: _.parseInt(x),
        y: _.parseInt(y),
        opponent: opponent
      };
      this.channel.push("sting", sting);
    }
  }

  onNewGame() {
    this.channel.push("new", []);
    // redirect to lobby
    let url = window.location.href.split("/game");
    window.location.replace(url[0]);
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

  renderJoining() {
    return (<div className="container">Waiting for other players to join...</div>);
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
              onSubmit={this.onPlace.bind(this)}
            />
        </div>
      </div>
    </div>
    );
  }

  renderPlaying() {
    let opponentNames = [];
    _.forIn(this.state.opponents, function(value, key) {
      opponentNames.push(key);
    });
    // for games with > 2 players...
    if (this.state.rankings.includes(window.playerName)) {
      return (
      	<div className="container">
      	  <h1>You Lost</h1>
          <EnemyBoards
            onClick={this.onSting.bind(this)}
            opponents={this.state.opponents}
            width={this.state.board_size.width}
            height={this.state.board_size.height}
          />
      	</div>
      );
    } else {  
      return (
        <div className="container">
          <div className="row">
            <div className="column">
              <PlayerBoard 
                myBoard={this.state.my_board} 
                width={this.state.board_size.width}
                height={this.state.board_size.height}
                status={this.state.status}
                name={window.playerName}
              />  
             <PlayerTurn turn={this.state.my_turn} /> 
            </div>
            <div className="column">
              <EnemyBoards 
      	        onClick={this.onSting.bind(this)}
                opponents={this.state.opponents} 
                width={this.state.board_size.width} 
                height={this.state.board_size.height}
              />
            </div>
          </div>
        </div>
      );
    }
  }

  renderGameOver() {
    return (
      <div>
        <h3>Game Over!</h3>
        <ScoreBoard rankings={this.state.rankings} />
        <p><button onClick={this.onNewGame.bind(this)}>Play Again?</button></p>
      </div>
    );
  }
}

function ScoreBoard(props) {
  let {rankings} = props;
  let r = _.map(rankings, (player_name, ii) => {return <p key={ii}>{ii + 1}. {player_name}</p>});
  return (
    <div className="score-board">
      <h5>The results:</h5>
      <div className="rankings">{r}</div>
    </div>
  );
}

function PlayerTurn(props) {
  let {turn} = props;
  if (turn) return <div id="sting-message"><h4>Click an opponent's board to sting!</h4></div>;
  else return <div id="sting-message"><h6>Be patient! Your opponents are taking aim...</h6></div>;
}
