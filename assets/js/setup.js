import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import _ from 'lodash';
import $ from 'jquery';

export default class SetUpForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      caterpillar: "carrier",
      startX: 0,
      startY: 0,
      isHorizontal: "true"
    }

    this.handleCaterpillarChange = this.handleCaterpillarChange.bind(this);
    this.handleDirectionChange = this.handleDirectionChange.bind(this);
    this.handleCoordinateChange = this.handleCoordinateChange.bind(this);
  }

  onSubmit(ev) {
    ev.preventDefault();
    this.props.onSubmit(this.state.caterpillar, this.state.startX, this.state.startY, this.state.isHorizontal);
  }

  handleCaterpillarChange(ev) {
    this.setState({caterpillar: ev.target.value});
  }

  handleCoordinateChange(ev, isX) {
    if (isX) {
      this.setState({startX: ev.target.value});
    } else {
      this.setState({startY: ev.target.value})
    }
  }

  handleDirectionChange(ev) {
    console.log("handle direction");
    this.setState({isHorizontal: ev.target.value})
  }

  render() {
    return (
      <form>
        Caterpillar: 
        <select name="caterpillar" value={this.state.caterpillar} onChange={this.handleCaterpillarChange}>
          <option value="carrier">Carrier</option>
          <option value="battleship">Battleship</option>
          <option value="cruiser">Cruiser</option>
          <option value="submarine">Submarine</option>
          <option value="destroyer">Destroyer</option>
        </select>
        Start X: <input type="number" min={1} max={this.props.maxLengthX} />
        Start Y: <input type="number" min={1} max={this.props.maxLengthY} />
        Direction: 
        <select value={this.state.isHorizontal} onChange={this.handleDirectionChange}>
          <option value="true">Horizontal</option>
          <option value="false">Vertical</option>
        </select>
        <button onClick={this.onSubmit.bind(this)}>Place!</button>
      </form>
    );
  }
}