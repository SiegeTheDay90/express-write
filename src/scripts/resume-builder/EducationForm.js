import { useRef, useState } from 'react'
import React from 'react';
import EducationFormItem from './EducationFormItem';

function EducationForm(){

  const [formItems, setFormItems] = useState([<EducationFormItem key={0} />]);

  function AddItem(e){
    setFormItems(formItems => formItems.concat([<EducationFormItem key={formItems.length} />]))
  };

    return (
      <>
        <ul>
          {formItems}
        </ul>
        <button className="button button-secondary" onClick={AddItem}>+ Add New Education</button>
      </>
    );
}

export default EducationForm
