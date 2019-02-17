import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Battleship channel={channel} />, root);
}

class Battleship extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;

    this.state = {
	    myBoard: {},
	    opponents: {},
	    myTurn: "",
	    lost: false,
	    boardSize: {},
	    rankings: [],         // array of names of players who have lost
	    phase: "joining",     // joining, setup, playing, gameover phases
    }

    this.channel
      .join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.error("Unable to join", resp); });
  }

  on_place(ev) {
    this.channel.push("place", {type: "TODO"})
  }

  render() {
    switch (this.state.phase) {
      case "joining":
	return (<div className="container">Waiting for other players to join...</div>);
      case "setup":
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
		  Start X: <input type="text" maxlength={this.state.boardSize.width} />
		  Start Y: <input type="text" maxlength={this.state.boardSize.height} />
		  Direction: <select>
		    <option value="true">Horizontal</option>
		    <option value="false">Vertical</option>
		  </select>
	          <button onClick={this.on_place.bind(this)}>Place!</button>
	        </form>
	      </div>
	      <div className="col">
		<PlayerBoard myBoard={this.state.myBoard}/>
	      </div>
	    </div>
	  </div>
	);
      case "playing":
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
      case "gameover":
	return (<ScoreBoard rankings={this.state.rankings} />);
      default:
	return (<div className="container">Waiting for next phase...</div>);
    }
  }

  gotView(view) {
    this.setState(view.game);
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
