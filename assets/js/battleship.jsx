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

    }

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.error("Unable to join", resp); });
  }

  render() {
    return (
      <div className="container">
        <div className="row">
          <div className="col">
            <p>Game view goes here</p>
          </div>
        </div>
      </div>
    );
  }

  gotView(view) {
    this.setState(view.game);
  }
}