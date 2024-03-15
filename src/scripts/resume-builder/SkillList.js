import { useState } from 'react'
import React from 'react';

function SkillList({resume: [resume, setResume]}){

  const formItems = resume.skills;
  const [newSkill, setNewSkill] = useState("");
  const [count, setCount] = useState(0);

  function newSkillChange(e){
    setNewSkill(e.target.value);
  }

  function AddItem(e){
    if(newSkill.trim()){
      setNewSkill("");
      const item = newSkill;
  
      setResume(prevState => ({
        ...prevState,
        skills: prevState.skills.concat([item])
      }))
    }
  };

  function remove(e){
    const idx = parseInt(e.currentTarget.dataset.idx);
    // debugger
    setResume(prevState => ({
      ...prevState,
      skills: prevState.skills.slice(0, idx).concat(prevState.skills.slice(idx+1))
    }))
  }

  function move(e){
    const dir = e.currentTarget.dataset.dir === "up" ? -1 : 1;
    const idx = parseInt(e.currentTarget.dataset.idx);


    setResume(prevState => {
      const items = [...prevState.skills];
      const holder = prevState.skills[idx];
      items[idx] = items[idx + dir];
      items[idx + dir] = holder;
      return {
        ...prevState,
        skills: items
      }
    })
  }

    return (
      <>
        <ul>
          {formItems.map((el, idx) => {
            return <li className="mb-1" key={idx}>
              <span>{el} &nbsp;</span>
              <div className="btn-group" role="group" >
                <button onClick={move} data-idx={idx} data-dir="up" className={`btn btn-secondary ${idx == 0 ? 'disabled' : ''}`}><i className="fa-solid fa-arrow-up"></i></button>
                <button onClick={move} data-idx={idx} data-dir="down" className={`btn btn-secondary ${idx == resume.skills.length-1 ? 'disabled' : ''}`}><i className="fa-solid fa-arrow-down"></i></button>
                <button onClick={remove} data-idx={idx} className={`btn btn-danger`}><i className="fa-solid fa-trash-can"></i></button>
              </div>
            </li>
          })}
        </ul>
        <div className='col-sm-6 d-flex'>
          <input type="text" className="form-control-sm bg-light" name="new-skill" value={newSkill} onChange={newSkillChange} />
          <button className="btn btn-sm btn-secondary ms-2" onClick={AddItem}>Save</button>
        </div>
      </>
    );
}

export default SkillList
