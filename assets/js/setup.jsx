import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

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
    this.setState({startX: normalizeCoordinate(ev.target.value, true, this.props.maxX, this.props.maxY)});
  }

  handleYChange(ev) {
    this.setState({startY: normalizeCoordinate(ev.target.value, false, this.props.maxX, this.props.maxY)});
  }

  handleDirectionChange(ev) {
    this.setState({isHorizontal: ev.target.value})
  }


  render() {
    return (
      <div className="setup">
      <form>
        Caterpillar: 
        <select name="caterpillar" value={this.state.caterpillar} onChange={this.handleCaterpillarChange}>
    	  <option value="carrier">Carrier (5)</option>
          <option value="battleship">Battleship (4)</option>
          <option value="destroyer">Destroyer (3)</option>
          <option value="submarine">Submarine (3)</option>
          <option value="patrol">Patrol (2)</option>
        </select>
        <div>
          <div className="inline inline-1"> Start X: <input type="number" min={1} max={this.props.maxX} value={this.state.startX} onChange={this.handleXChange} /></div>
          <div className="inline inline-2">Start Y: <input type="number" min={1} max={this.props.maxY} value={this.state.startY} onChange={this.handleYChange} /></div>
        </div>
        Direction: 
        <select value={this.state.isHorizontal} onChange={this.handleDirectionChange}>
          <option value="true">Horizontal</option>
          <option value="false">Vertical</option>
        </select>
        <button onClick={this.onSubmit.bind(this)}>Place!</button>
      </form>
      </div>
    );
  }
}

export function normalizeCoordinate(c, isX, maxX, maxY) {
  let coordinate = c < 0 ? 0 : c;
  if (isX) {
    coordinate = coordinate > maxX ? maxX : coordinate;
  } else {
    coordinate = coordinate > maxY ? maxY : coordinate;
  }
  return coordinate;
}
