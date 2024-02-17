import { useRef, useState } from 'react'
import React from 'react';
import WorkExperienceFormItem from './WorkExperienceFormItem';

function WorkExperienceForm(){

  const [formItems, setFormItems] = useState([<WorkExperienceFormItem key={0} />]);

  function AddItem(e){
    setFormItems(formItems => formItems.concat([<WorkExperienceFormItem key={formItems.length} />]))
  };

    return (
      <>
        <ul>
          {formItems}
        </ul>
        <button className="button button-secondary" onClick={AddItem}>+ Add New Experience</button>
      </>
    );
}

export default WorkExperienceForm
