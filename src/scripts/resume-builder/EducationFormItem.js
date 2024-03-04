import { useRef, useState } from 'react'
import React from 'react';

function EducationFormItem(){
    const [formData, setFormData] = useState({
        institutionName: '',
        degreeType: '',
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
        institutionName: '',
        degreeType: '',
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
          <input type="text" className="form-control ps-2 bg-light" placeholder='_' id="institutionName" name="institutionName" value={formData.institutionName} onChange={handleChange} />
            <label htmlFor="institutionName" className="ms-2 col-form-label">Institution name</label>
        </div>
        <div className="col-sm-6 form-floating">
          <input type="text" className="form-control ps-2 bg-light" placeholder='_' id="fieldOfStudy" name="fieldOfStudy" value={formData.fieldOfStudy} onChange={handleChange} />
            <label htmlFor="fieldOfStudy" className="ms-2 col-form-label">Field of study</label>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-6 form-floating">
          <input type="text" className="form-control ps-2 bg-light" placeholder='_' id="degreeType" name="degreeType" value={formData.degreeType} onChange={handleChange} />
            <label htmlFor="degreeType" className="ms-2 col-form-label">Degree</label>
        </div>
        <div className="col-sm-6 form-floating">
          <input type="tel" className="form-control ps-2 bg-light" placeholder='_' id="location" name="location" value={formData.location} onChange={handleChange} />
            <label htmlFor="location" className="ms-2 col-form-label">Location</label>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-6 d-flex align-items-center" >
          <label htmlFor="current" className="ms-2 col-form-label">I currently attend </label>
          <input type="checkbox" className="ms-2 bg-light" id="current" name="current" checked={formData.current} value={formData.current} onChange={handleChange} />
        </div>
        <div className="col-sm-6 form-floating">
          <input type="date" className="form-control ps-2 bg-light" placeholder='_' id="to" name="to" value={formData.to} onChange={handleChange} />
            <label htmlFor="to" className="ms-2 col-form-label">{formData.current ? "Expected Completion" : "Completed"}</label>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-10 form-floating">
            <textarea className="form-control ps-2 bg-light" placeholder='_' id="description" name="description" value={formData.description} onChange={handleChange} />
            <label htmlFor="description" className="ms-2 col-form-label">Description</label>
        </div>
      </div>
    </form>
    )
}

export default EducationFormItem
