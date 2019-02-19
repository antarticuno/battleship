import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import {normalizeCoordinate} from './setup';

export default class PlayerInput extends React.Component {
  constructor(props) {
    super(props);

    this.state = { x: 0, y: 0 };

    this.handleXChange = this.handleXChange.bind(this);
    this.handleYChange = this.handleYChange.bind(this);
  }

  handleXChange(ev) {
    let x = normalizeCoordinate(ev.target.value, true, this.props.maxX, this.props.maxY)
    this.setState({targetX: x})
  }

  handleYChange(ev) {
    let y = normalizeCoordinate(ev.target.value, false, this.props.maxX, this.props.maxY)
    this.setState({y: y})
  }

  onClick(ev) {
    ev.preventDefault();
    this.props.onSubmit(this.state.x, this.state.y);
  }

  render() {
    return (
      <div className="sting">
        <h4>Sting Your Opponent!</h4>
        Target X: <input id="target_x" type="number" value={this.state.x} onChange={this.handleXChange} />
        Target Y: <input id="target_y" type="number" value={this.state.y} onChange={this.handleYChange} />
        <button onClick={this.onClick}>Sting!</button>
      </div>
    );
  }
}