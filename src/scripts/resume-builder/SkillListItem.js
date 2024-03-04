import { useRef, useState } from 'react'
import React from 'react';

function SkillListItem({value, remove}){

  return (
    <li key={1} className="my-1" >
      {value} &nbsp; <span className="btn btn-danger" onClick={remove}>X</span>
    </li>
  );
}

export default SkillListItem
