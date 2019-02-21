import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import SetupForm from './setup';
import {PlayerBoard, EnemyBoards} from './boards';

export default function game_init(root, channel) {
  ReactDOM.render(<Battleship channel={channel} />, root);
}

const INITIAL_STATE = {
  my_board: {},
  opponents: {},
  my_turn: false,
  board_size: {},
  rankings: [],         // array of names of players who have lost
  phase: "joining",     // joining, setup, playing, gameover phases
};

// interfaces with the channel
class Battleship extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;

    this.state = {
      error: {}, 
      game: INITIAL_STATE
    }

    this.updateGame = this.updateGame.bind(this);
    this.handleError = this.handleError.bind(this);
    this.onPlace = this.onPlace.bind(this);
    this.onSting = this.onSting.bind(this);
    this.onNewGame = this.onNewGame.bind(this);
    this.onCloseError = this.onCloseError.bind(this);

    this.channel
      .join()
      .receive("ok", this.updateGame)
      .receive("error", err => { this.handleError(err)});

    this.channel.on("update_view", this.updateGame);
    this.channel.on("error", this.handleError);
  }

  updateGame(game) {
    console.log("game", game);
    this.setState({game: game});
  }

  handleError(error) {
    console.error(error);
    this.setState({error: error})
  }

  render() {
    return (
      <div>
        <ErrorMessage reason={this.state.error.reason} message={this.state.error.message} onClick={this.onCloseError} />
        <Game 
          game={this.state.game} 
          playerName={window.playerName}
          onPlace={this.onPlace}
          onSting={this.onSting}
          onNewGame={this.onNewGame}
        />
      </div>
    );
  }

  onCloseError() {
    this.setState({error: {}});
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
    if (this.state.game.my_turn) {
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
    redirectToLobby();
  }
}

function redirectToLobby() {
  let url = window.location.href.split("/game");
  window.location.replace(url[0]);
}

function ErrorMessage(props) {
  if (!props.message) {
    return false;
  }

  let action = props.reason == "unauthorized" ? <button onClick={redirectToLobby}>Return to Lobby</button> : false;
  return (
    <div className="error-message">
      <p>{props.message}</p>
      {action}
      <div className="close" onClick={props.onClick}>✕</div>
    </div>
  );
}

// renders the game states
class Game extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    switch (this.props.game.phase) {
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
            myBoard={this.props.game.my_board} 
            width={this.props.game.board_size.width}
            height={this.props.game.board_size.height}
            status={this.props.game.status}
          />
        </div>
          <div className="column">
            <SetupForm 
              maxX={this.props.game.board_size.width}
              maxY={this.props.game.board_size.height}
              onSubmit={this.props.onPlace}
            />
        </div>
      </div>
    </div>
    );
  }

  renderPlaying() {
    let opponentNames = [];
    _.forIn(this.props.game.opponents, function(value, key) {
      opponentNames.push(key);
    });
    // for games with > 2 players...
    if (this.props.game.rankings.includes(window.playerName)) {
      return (
      	<div className="container">
      	  <h1>You Lost! Observing...</h1>
          <EnemyBoards
            onClick={() => {}} // can't sting if lost
            opponents={this.props.game.opponents}
            width={this.props.game.board_size.width}
            height={this.props.game.board_size.height}
          />
      	</div>
      );
    } else {  
      return (
        <div className="container">
          <div className="row">
            <div className="column">
              <PlayerBoard 
                myBoard={this.props.game.my_board} 
                width={this.props.game.board_size.width}
                height={this.props.game.board_size.height}
                status={this.props.game.status}
                name={this.props.playerName}
              />  
             <PlayerTurn turn={this.props.game.my_turn} /> 
            </div>
            <div className="column">
              <EnemyBoards 
      	        onClick={this.props.onSting}
                opponents={this.props.game.opponents} 
                width={this.props.game.board_size.width} 
                height={this.props.game.board_size.height}
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
        <ScoreBoard rankings={this.props.game.rankings} />
        <p><button onClick={this.props.onNewGame}>Play Again?</button></p>
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
