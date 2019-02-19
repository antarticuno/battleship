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
	    my_turn: "",
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
      "player_name": window.playerName, 
      "type": type, 
      "start_x": _.parseInt(startX),
      "start_y": _.parseInt(startY),
      "horizontal?": (isHorizontal == "true")
    };
    console.log(place);
    this.channel.push("place", place);
  }

  onSting(startX, startY) {
    let sting = {
      // TODO
    };
    console.log(sting);
    this.channel.push("sting", sting);
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
            <PlayerInput 
              maxX={this.state.board_size.width} 
              maxY={this.state.board_size.height} 
              onSubmit={this.onSting.bind(this)}
            />
          </div>
          <div className="column">
            <EnemyBoards 
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
  let r = _.map(rankings, (player_name, ii) => {return <p key={ii}>{ii + 1}. player_name</p>});
  return r;
}
