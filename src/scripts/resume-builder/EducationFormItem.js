import React from 'react';
import BulletPointInput from './util/BulletPointInput';

function EducationFormItem( { item: formData, resume: [resume, setResume], idx} ){

    const handleChange = (e) => {
      let { name, value, checked } = e.target;
      if(e.target.type === "checkbox"){
        value = checked;
      }

      let newList = [...resume.education];
      newList[idx] = {
        ...newList[idx],
        [name]: value
      }

      setResume(prevState => ({
        ...prevState,
        education: newList
      }));

    };

    function move(e){
      e.preventDefault();
      const dir = e.target.dataset.dir * 1;

      setResume(prevState => {
        const items = [...prevState.education];
        const holder = prevState.education[idx];
        items[idx] = items[idx + dir];
        items[idx + dir] = holder;
        return {
          ...prevState,
          education: items
        }
      })
    }

    function remove(e){
      e.preventDefault();

      setResume(prevState => {
        const items = [...prevState.education];
        
        return {
          ...prevState,
          education: items.slice(0, idx).concat(items.slice(idx+1))
        }
      })
    }

    return (
    <form className='content p-2 my-1'>
      <div className="row mb-3">
        <div className="col-sm-5">
          <label htmlFor="institutionName" className="invisible position-absolute ms-2 col-form-label">Institution name</label>
          <input type="text" className="form-control-sm ps-2 bg-light" placeholder='School or Institution' id="institutionName" name="institutionName" value={formData.institutionName} onChange={handleChange} />
        </div>
        <div className="col-sm-4">
          <label htmlFor="fieldOfStudy" className="invisible position-absolute ms-2 col-form-label">Field of study</label>
          <input type="text" className="form-control-sm ps-2 bg-light" placeholder='Field of Study' id="fieldOfStudy" name="fieldOfStudy" value={formData.fieldOfStudy} onChange={handleChange} />
        </div>
        <div className="col-sm-3 d-flex justify-content-end mb-3">
          <div className="btn-group" role="group" >
            <button onClick={move} data-dir="-1" className={`btn btn-sm btn-secondary ${idx == 0 ? 'disabled' : ''}`}><i className="fa-solid fa-arrow-up"></i></button>
            <button onClick={move} data-dir="1" className={`btn btn-sm btn-secondary ${idx == resume.education.length-1 ? 'disabled' : ''}`}><i className="fa-solid fa-arrow-down"></i></button>
            <button onClick={remove} className={`btn btn-sm btn-danger`}><i className="fa-solid fa-trash-can"></i></button>
          </div>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-5">
          <label htmlFor="degreeType" className="invisible position-absolute ms-2 col-form-label">Degree</label>
          <input type="text" className="form-control-sm ps-2 bg-light" placeholder='Degree Type' id="degreeType" name="degreeType" value={formData.degreeType} onChange={handleChange} />
        </div>
        <div className="col-sm-6">
          <label htmlFor="location" className="invisible position-absolute ms-2 col-form-label">Location</label>
          <input type="tel" className="form-control-sm ps-2 bg-light" placeholder='Location' id="location" name="location" value={formData.location} onChange={handleChange} />
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-5 d-flex align-items-center" >
          <label htmlFor="current" className="ms-2 col-form-label">I currently attend </label>
          <input type="checkbox" className="ms-2 bg-light" id="current" name="current" checked={formData.current} value={formData.current} onChange={handleChange} />
        </div>
        <div className="col-sm-6">
          <input type="date" className="form-control-sm ps-2 bg-light" placeholder='_' id="to" name="to" value={formData.to} onChange={handleChange} />
          <label htmlFor="to" className="ms-2 col-form-label">{formData.current ? "Expected Completion" : "Completed"}</label>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-sm-10">
          <BulletPointInput type={"education"} name={"bullets"} label={"Bullet Points"} value={formData.bullets} setValue={handleChange}/>
        </div>
      </div>
    </form>
    )
}

export default EducationFormItem
