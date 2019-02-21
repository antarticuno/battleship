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
	    lost: false,
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

  onNew() {
    this.channel.push("new", []);
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

  updateView(view) {
    console.log("update_view", view);
    this.setState(view);
  }

  gotView(view) {
    console.log("got_view", view);
    this.setState(view);
  }

  renderJoining() {
    return (<div className="container">Waiting for other players to join...
	    <p><button onClick={this.onNew.bind(this)}>Play Again?</button></p></div>);
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

  renderGameOver() {
    return (<ScoreBoard rankings={this.state.rankings} />);
  }
}

function ScoreBoard(props) {
  let {rankings} = props;
  let r = _.map(rankings, (player_name, ii) => {return <p key={ii}>{ii + 1}. {player_name}</p>});
  // TODO get this at the end: r.push(<button>Play Again?</button>);
  return r;
}

function PlayerTurn(props) {
  let {turn} = props;
  console.log(turn);
  if (turn) return <div id="sting-message"><h4>Time to Sting!</h4></div>;
  else return <div id="sting-message"><h6>Be patient! Your opponents are taking aim...</h6></div>;
}
