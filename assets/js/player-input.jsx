import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import {normalizeCoordinate} from './setup';

export default class PlayerInput extends React.Component {
  constructor(props) {
    super(props);

    this.state = { x: "0", y: "0", opponent: this.props.opponents[0] };

    this.onClick = this.onClick.bind(this);
    this.handleXChange = this.handleXChange.bind(this);
    this.handleYChange = this.handleYChange.bind(this);
    this.handleOpponentChange = this.handleOpponentChange.bind(this);
  }

  handleXChange(ev) {
    let x = normalizeCoordinate(ev.target.value, true, this.props.maxX, this.props.maxY)
    this.setState({x: x})
  }

  handleYChange(ev) {
    let y = normalizeCoordinate(ev.target.value, false, this.props.maxX, this.props.maxY)
    this.setState({y: y})
  }

  handleOpponentChange(ev) {
    this.setState({opponent: ev.target.value});
  }

  onClick(ev) {
    ev.preventDefault();
    this.props.onSubmit(this.state.x, this.state.y, this.state.opponent);
  }

  render() {
    let i = 0;
    let opponents = _.map(this.props.opponents, function(opp) {
      i++;
      return <option key={i} value={opp}>{opp}</option>;
    });

    return (
      <div className="sting">
        <h4>Sting Your Opponent!</h4>
        Opponent: <select name="opponent" value={this.state.opponent} onChange={this.handleOpponentChange}>
          {opponents}
        </select>
        Target X: <input id="target_x" type="number" value={this.state.x} onChange={this.handleXChange} />
        Target Y: <input id="target_y" type="number" value={this.state.y} onChange={this.handleYChange} />
        <button className={this.props.myTurn ? "" : "disabled"} onClick={this.onClick}>Sting!</button>
      </div>
    );
  }
}
