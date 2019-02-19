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
  let cols = [];
  for (let c = -1; c < props.width; c++) {
    let col = [];
    for (let r = -1; r < props.height; r++) {

      if (c == -1 && r == -1) {
        col.push(<div className="column board-cell label"></div>);
      } else if (c == -1) {
        col.push(<div className="column board-cell label">{r}</div>);
      } else if (r == -1) {
        col.push(<div className="column board-cell label">{c}</div>);
      } else {
        let coord = r + "," + c;
        let s = props.status[coord];
        
        let isHit = s == "hit";
        let isMiss = s == "miss";
        let hit = isHit ? " hit" : isMiss ? " miss" : "";

        col.push(<div key={r} className={coord + " column board-cell" + (caterpillars.includes(coord) ? " caterpillar" : "") + hit}>
          {isHit ? "X" : isMiss ? "O" : "_"}
        </div>);
      }
    }
    cols.push(<div key={c} className="row">{col}</div>);
  }

  return (
    <div className="board">
      {props.name ? <h4>Board for: {props.name}</h4> : false}
      <div className="container">
        {cols}
      </div>
    </div>
  );
}