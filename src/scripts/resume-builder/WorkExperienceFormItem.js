import { useRef, useState } from 'react'
import React from 'react';

function WorkExperienceFormItem( { item: formData, resume: [resume, setResume], idx} ){

    const handleChange = (e) => {
      let { name, value, checked } = e.target;
      if(e.target.type === "checkbox"){
        value = checked;
      }

      let newWork = [...resume.work];
      newWork[idx] = {
        ...newWork[idx],
        [name]: value
      }
      setResume(prevState => ({
        ...prevState,
        work: newWork
      }));

    };

    function move(e){
      e.preventDefault();
      const dir = e.target.dataset.dir === "up" ? -1 : 1;

      setResume(prevState => {
        const items = [...prevState.work];
        const holder = prevState.work[idx];
        items[idx] = items[idx + dir];
        items[idx + dir] = holder;
        return {
          ...prevState,
          work: items
        }
      })
    }

    function remove(e){
      e.preventDefault();

      setResume(prevState => {
        const items = [...prevState.work];
        
        return {
          ...prevState,
          work: items.slice(0, idx).concat(items.slice(idx+1))
        }
      })
    }


    return (
    <form className='content p-2 my-1 resume-form'>
      <div className="row mb-3">
        <div className="col-sm-4">
          <label htmlFor="companyName" className="position-absolute invisible col-form-label">Employer</label>
          <input type="text" className="h-75 form-control-sm ps-2 bg-light" placeholder='Employer' id="companyName" name="companyName" value={formData.companyName} onChange={handleChange} />
        </div>
        <div className="col-sm-4">
            <label htmlFor="jobTitle" className="position-absolute invisible col-form-label">Job Title</label>
          <input type="text" className="h-75 form-control-sm ps-2 bg-light" placeholder='Job Title' id="jobTitle" name="jobTitle" value={formData.jobTitle} onChange={handleChange} />
        </div>
        <div className="col-sm-4 d-flex justify-content-end mb-3">
          <div className="btn-group" role="group" >
            <button onClick={move} data-dir="up" className={`btn btn-secondary ${idx == 0 ? 'disabled' : ''}`}><i className="fa-solid fa-arrow-up"></i></button>
            <button onClick={move} data-dir="down" className={`btn btn-secondary ${idx == resume.work.length-1 ? 'disabled' : ''}`}><i className="fa-solid fa-arrow-down"></i></button>
            <button onClick={remove} className={`btn btn-danger ${resume.work.length == 1 ? 'disabled' : ''}`}><i className="fa-solid fa-trash-can"></i></button>
          </div>
        </div>
      </div>

      <div className="row mb-3 me-5">
        <div className="col-sm-4">
          <label htmlFor="city" className="position-absolute invisible col-form-label">Location</label>
          <input type="tel" className="form-control-sm ps-2 bg-light" placeholder='Location' id="city" name="city" value={formData.city} onChange={handleChange} />
        </div>
        <div className="d-flex justify-content-end col-sm-6">
          <label htmlFor="from" className="me-2 col-form-label">From</label>
          <input type="date" className="form-control-sm ps-2 bg-light" id="from" name="from" value={formData.from} onChange={handleChange} />
        </div>
      </div>

      <div className="row mb-3 me-5">
        <div className="col-sm-4 d-flex align-items-center" >
          <label htmlFor="current" className="ms-2 col-form-label">I currently work here </label>
          <input type="checkbox" className="ms-2 bg-light" id="current" name="current" checked={formData.current} value={formData.current} onChange={handleChange} />
        </div>
        <div className="d-flex justify-content-end col-sm-6 hideable">
          <label htmlFor="to" className="me-2 col-form-label">To</label>
          <input type="date" className="form-control-sm ps-2 bg-light" id="to" name="to" value={formData.to} onChange={handleChange} disabled={formData.current} />
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-10 form-floating">
            <textarea className="form-control ps-2 bg-light" placeholder='_' id="description" name="description" value={formData.description} onChange={handleChange} />
            <label htmlFor="description" className="ms-2 col-form-label">Description</label>
        </div>
      </div>
      <div className="row mb-3">
        <div className="col-sm-10">
          <button className="btn btn-primary">Generate with AI</button>
        </div>
      </div>
    </form>
    )
}

export default WorkExperienceFormItem
