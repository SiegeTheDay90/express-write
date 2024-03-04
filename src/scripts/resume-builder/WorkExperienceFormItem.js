import { useRef, useState } from 'react'
import React from 'react';

function WorkExperienceFormItem(){
    const [formData, setFormData] = useState({
        companyName: '',
        jobTitle: '',
        city: '',
        location: '',
        from: '',
        to: '',
        description: '',
        current: false
    });

    const handleChange = (e) => {
      let { name, value, checked } = e.target;
      if(e.target.type === "checkbox"){
        value = checked;
      }
      setFormData(prevState => ({
          ...prevState,
          [name]: value
      }));

    };

    const handleSubmit = (e) => {
    e.preventDefault();
    console.log(formData);

    setFormData({
        companyName: '',
        jobTitle: '',
        city: '',
        location: '',
        from: '',
        to: '',
        description: '',
        current: false
    });
    };

    return (
    <form onSubmit={handleSubmit} className='content p-2 my-1'>
      <div className="row mb-3">
        <div className="col-sm-6 form-floating">
          <input type="text" className="form-control ps-2 bg-light" placeholder='_' id="companyName" name="companyName" value={formData.companyName} onChange={handleChange} />
            <label htmlFor="companyName" className="ms-2 col-form-label">Company name *</label>
        </div>
        <div className="col-sm-6 form-floating">
          <input type="text" className="form-control ps-2 bg-light" placeholder='_' id="jobTitle" name="jobTitle" value={formData.jobTitle} onChange={handleChange} />
            <label htmlFor="jobTitle" className="ms-2 col-form-label">Job title *</label>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-6 form-floating">
          <input type="tel" className="form-control ps-2 bg-light" placeholder='_' id="city" name="city" value={formData.city} onChange={handleChange} />
            <label htmlFor="city" className="ms-2 col-form-label">Location</label>
        </div>
        <div className="col-sm-6 form-floating">
          <input type="date" className="form-control ps-2 bg-light" placeholder='_' id="from" name="from" value={formData.from} onChange={handleChange} />
            <label htmlFor="from" className="ms-2 col-form-label">From</label>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-6 d-flex align-items-center" >
          <label htmlFor="current" className="ms-2 col-form-label">I currently work here </label>
          <input type="checkbox" className="ms-2 bg-light" id="current" name="current" checked={formData.current} value={formData.current} onChange={handleChange} />
        </div>
        <div className="col-sm-6 form-floating hideable">
          <input type="date" className="form-control ps-2 bg-light" placeholder='_' id="to" name="to" value={formData.to} onChange={handleChange} disabled={formData.current} />
            <label htmlFor="to" className="ms-2 col-form-label">To</label>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-10 form-floating">
            <textarea className="form-control ps-2 bg-light" placeholder='_' id="description" name="description" value={formData.description} onChange={handleChange} />
            <label htmlFor="description" className="ms-2 col-form-label">Description</label>
        </div>
      </div>
      <div className="row mb-3">
        <div className="col-sm-10 form-floating">
          <button className="btn btn-primary">Generate with AI</button>
        </div>
      </div>
    </form>
    )
}

export default WorkExperienceFormItem
