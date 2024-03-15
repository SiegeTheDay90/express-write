import { useRef, useState } from 'react'
import React from 'react';
import EducationFormItem from './EducationFormItem';

function EducationForm({resume: [resume, setResume]}){

  const formItems = resume.education;

  function AddItem(e){
    setResume(prevState => {
      return {
        ...prevState,
        education: prevState.education.concat([{
          institutionName: '',
          fieldOfStudy: '',
          degreeType: '',
          city: '',
          location: '',
          to: '',
          description: '',
          current: false
        }])
      }
    })
  };


  return (
    <>
      <ul className="ps-1">
        {formItems.map((item, idx) => <EducationFormItem key={idx} resume={[resume, setResume]} idx={idx} item={item} />)}
      </ul>
      <button className="btn btn-secondary btn-sm" onClick={AddItem}>+ Add New Education</button>
    </>
  );
}

export default EducationForm
