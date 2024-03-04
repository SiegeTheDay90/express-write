import { useRef, useState } from 'react'
import React from 'react';
import SkillListItem from './SkillListItem';

function SkillList(){

  const [formItems, setFormItems] = useState([]);
  const [newSkill, setNewSkill] = useState("");
  const [count, setCount] = useState(0);

  function newSkillChange(e){
    // console.log(e);
    setNewSkill(e.target.value);
  }

  function AddItem(e){
    if(newSkill.trim()){
      setNewSkill("");
      setCount(count + 1);
      const remove = () => setFormItems(items => items.filter(el => el.num !== count));
      
      const item = <SkillListItem key={count} value={newSkill.trim()} remove={remove}/>
  
  
      setFormItems(formItems => formItems.concat([{ num: count, item }]))
    }
  };

    return (
      <>
        <ul>
          {formItems.map((el) => el.item)}
        </ul>
        <div className='col-sm-3 d-flex'>
          <input type="text" className="form-control bg-light" name="new-skill" value={newSkill} onChange={newSkillChange} />
          <button className="btn btn-secondary ms-2" onClick={AddItem}>Save</button>
        </div>
      </>
    );
}

export default SkillList
