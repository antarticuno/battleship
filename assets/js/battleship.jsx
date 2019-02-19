import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import $ from 'jquery';

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

    this.channel
      .on("update_view", this.updateView.bind(this));
  }

  on_place(ev) {
    this.channel.push("place", {type: "TODO"})
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
          <div className="col">
            <form>
              Caterpillar: <select name="caterpillar">
                <option value="carrier">Carrier</option>
                <option value="battleship">Battleship</option>
                <option value="cruiser">Cruiser</option>
                <option value="submarine">Submarine</option>
                <option value="destroyer">Destroyer</option>
              </select>
              Start X: <input type="text" maxLength={this.state.board_size.width} />
              Start Y: <input type="text" maxLength={this.state.board_size.height} />
              Direction: <select>
              <option value="true">Horizontal</option>
              <option value="false">Vertical</option>
            </select>
            <button onClick={this.on_place.bind(this)}>Place!</button>
          </form>
        </div>
        <div className="col">
          <PlayerBoard myBoard={this.state.my_board}/>
        </div>
      </div>
    </div>
    );
  }

  renderGameOver() {
    return (<ScoreBoard rankings={this.state.rankings} />);
  }
}

function EnemyBoards(props) {
  return (<div></div>);
}

function PlayerInput(props) {
  return (<div>
	    Target X: <input id="target_x" type="text" />
	    Target Y: <input id="target_y" type="text" />
	    <button>Sting!</button>
	  </div>);
}

function PlayerBoard(props) {
  let {myBoard} = props;
  return (<div></div>);
}

function ScoreBoard(props) {
  let {rankings} = props;
  let r = _.map(rankings, (player_name, ii) => {return <p key={ii}>{ii + 1}. player_name</p>});
  return r;
}
