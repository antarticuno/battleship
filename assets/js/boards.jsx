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
    boards.push(<Board key={opp} sting={props.onClick} width={props.width} height={props.height} status={opponentStatus[opp]} name={opponentNames[opp]}/>)
  }
  return (<div className="opponent-boards">{boards}</div>);
}

function Board(props) {
  let status = props.status;
  let caterpillars = _.filter(props.caterpillarCoords, null);
  let onClick = props.sting;
  let cols = [];
  for (let c = -1; c < props.width; c++) {
    let col = [];
    for (let r = -1; r < props.height; r++) {

      if (c == -1 && r == -1) {
        col.push(<div key={r} className="col column board-cell label"></div>);
      } else if (c == -1) {
        col.push(<div key={r} className="col column board-cell label">{r}</div>);
      } else if (r == -1) {
        col.push(<div key={r} className="col column board-cell label">{c}</div>);
      } else {
        let coord = r + "," + c;
        let s = props.status[coord];
        
        let isHit = s == "hit";
        let isMiss = s == "miss";
      	let isDead = s == "dead";
        let hit = isHit ? " hit" : isMiss ? " miss" : isDead ? "dead" : "";
        let onClickSting = () => {if (onClick != null && !isHit && !isMiss && !isDead) {onClick(r, c, props.name);};};

        col.push(<div key={r} onClick={onClickSting.bind(this)} className={coord + " col column board-cell " + (caterpillars.includes(coord) ? "caterpillar " : "") + hit}>
        </div>);
      }
    }
    cols.push(<div key={c} className="row battleship-row">{col}</div>);
  }

  return (
    <div className="board">
      {props.name ? <h4>Board for: {props.name}</h4> : false}
      <div className="container battleship-container">
        {cols}
      </div>
    </div>
  );
}
