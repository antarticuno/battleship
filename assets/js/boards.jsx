import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export function PlayerBoard(props) {
  let status = props.myBoard.status;
  let caterpillars = []
  _.forIn(props.myBoard.caterpillars, function(value, key) {
    caterpillars = caterpillars.concat(value);
  });

  return (
    <Board 
      width={props.width} 
      height={props.height} 
      status={status} 
      caterpillarCoords={caterpillars} 
      name={props.name}
    />
  );
}

export function EnemyBoards(props) {
  let opponentNames = [];
  let opponentStatus = [];
  _.forIn(props.opponents, function(value, key) {
    opponentNames.push(key);
    opponentStatus.push(value);
  });

  let boards = [];
  for (let opp = 0; opp < opponentNames.length; opp++) {
    boards.push(<Board key={opp} width={props.width} height={props.height} status={opponentStatus[opp]} name={opponentNames[opp]}/>)
  }

  return (<div className="opponent-boards">{boards}</div>);
}

function Board(props) {
  let status = props.status;
  let caterpillars = _.filter(props.caterpillarCoords, null);

  let rows = [];
  for (let r = 0; r < props.width; r++) {
    let row = [];
    for (let c = 0; c < props.height; c++) {
      // TODO render hit/miss
      let inCaterpillar = caterpillars.includes(r + "," + c);
      row.push(<div key={c} className={"column" + (inCaterpillar ? " caterpillar" : "")}>X</div>);
    }
    rows.push(<div key={r} className="row">{row}</div>);
  }

  return (
    <div className="board">
      {props.name ? <h4>Board for: {props.name}</h4> : false}
      <div className="container">
        {rows}
      </div>
    </div>
  );
}