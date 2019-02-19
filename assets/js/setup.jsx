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
    this.handleXChange = this.handleXChange.bind(this);
    this.handleYChange = this.handleYChange.bind(this);
  }

  onSubmit(ev) {
    ev.preventDefault();
    this.props.onSubmit(this.state.caterpillar, this.state.startX, this.state.startY, this.state.isHorizontal);
  }

  handleCaterpillarChange(ev) {
    this.setState({caterpillar: ev.target.value});
  }

  handleXChange(ev) {
    this.setState({startX: this.normalizeCoordinate(ev.target.value, true)});
  }

  handleYChange(ev) {
    this.setState({startY: this.normalizeCoordinate(ev.target.value, false)});
  }

  normalizeCoordinate(c, isX) {
    let coordinate = c < 0 ? 0 : c;
    if (isX) {
      coordinate = coordinate > this.props.maxX ? this.props.maxX : coordinate;
    } else {
      coordinate = coordinate > this.props.maxY ? this.props.maxY : coordinate;
    }
    return coordinate;
  }

  handleDirectionChange(ev) {
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
        Start X: <input type="number" min={1} max={this.props.maxX} onChange={this.handleXChange} />
        Start Y: <input type="number" min={1} max={this.props.maxY} onChange={this.handleYChange} />
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