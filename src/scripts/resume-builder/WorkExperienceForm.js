import React from 'react';
import WorkExperienceFormItem from './WorkExperienceFormItem';

function WorkExperienceForm( {resume: [resume, setResume]}){

  const formItems = resume.work;

  function AddItem(e){
    setResume(prevState => {
      return {
        ...prevState,
        work: prevState.work.concat([{
          companyName: '',
          jobTitle: '',
          city: '',
          location: '',
          from: '',
          to: '',
          bullets: [],
          current: false
        }])
      }
    })
  };

    return (
      <>
        <ul className='ps-1'>
          {formItems.map((item, idx) => {return <WorkExperienceFormItem key={idx} resume={[resume, setResume]} idx={idx} item={item} />})}
        </ul>
        <button className="btn btn-sm btn-secondary" onClick={AddItem}>+ Add New Experience</button>
      </>
    );
}

export default WorkExperienceForm
