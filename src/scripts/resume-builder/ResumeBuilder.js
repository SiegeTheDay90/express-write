import { useEffect, useState } from 'react'
import React from 'react';
import '../../styles/ResumeBuilder.scss'
import PersonalInfoForm from './PersonalInfoForm';
import WorkExperienceForm from './WorkExperienceForm';
import EducationForm from './EducationForm';
import SkillList from './SkillList';
import ResumePreview from './ResumePreview';
import { saveAs } from 'file-saver';
import * as Docx from "docx";
import generateDocx from './util/DocX';

function ResumeBuilder() {
    
    
    async function saveResume() {
        const doc = generateDocx(resume);
        const blob = await Docx.Packer.toBlob(doc);
        saveAs(blob, 'resume.docx');
    }
    
    async function cloudSave() {
        const csrfRes = await fetch('/session');
        const data = await csrfRes.json();
        const csrfToken = csrfRes.headers["X-CSRF-Token"] || data.token;
        const user = data.user;
        if(user  === "null"){
            alert("You must be signed in to access cloud saves.");
            return
        }
        const res = await fetch('/resumes', {
            method: "POST",
            headers: {
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({...resume, user_id: user.id})
        }) 
        

        const success = await res.json();
        if(success){
            alert(`Successfully saved resume "${resume.title}" for ${user.first_name}`)
        } else {
            alert(`Unsuccessful save. Try again.`)
        }

    }

    function reset(){
        if(confirm("Are you sure? Your local save will be lost.")){
            setResume({
                personal: {
                    firstName: '',
                    lastName: '',
                    profession: '',
                    phoneNumber: '',
                    email: '',
                    website: ''
                },
                work: [{
                    companyName: '',
                    jobTitle: '',
                    city: '',
                    location: '',
                    from: '',
                    to: '',
                    description: '',
                    current: false
                  }],
                education: [{
                    institutionName: '',
                    fieldOfStudy: '',
                    degreeType: '',
                    city: '',
                    location: '',
                    to: '',
                    description: '',
                    current: false
                  }],
                skills: [],
            })
        }
    }



    const [resume, setResume] = useState({
        personal: {
            firstName: '',
            lastName: '',
            profession: '',
            phoneNumber: '',
            email: '',
            website: ''
        },
        work: [{
            companyName: '',
            jobTitle: '',
            city: '',
            location: '',
            from: '',
            to: '',
            description: '',
            current: false
          }],
        education: [{
            institutionName: '',
            fieldOfStudy: '',
            degreeType: '',
            city: '',
            location: '',
            to: '',
            description: '',
            current: false
          }],
        skills: [],
    })

    useEffect(() => {
        let storedResume = localStorage.getItem("resume");
    
        if(storedResume){
            setResume(JSON.parse(storedResume));
        }
    }, [])
    
    useEffect(() => {
        localStorage.setItem("resume", JSON.stringify(resume))
    }, [resume])

    function focusClick(e){
        e.currentTarget.parentElement.classList.toggle('focused');
        e.currentTarget.parentElement.classList.toggle('closed');
    }

    return (
        <>
            <div className="btn-group hover-menu" role="group">
                {/* <div className="btn btn-success">
                    <i className="fa-solid fa-floppy-disk"></i>
                </div> */}
                
                <div className="btn btn-danger" onClick={reset}>
                    Start Over <i className="fa-solid fa-rotate-right"></i>
                </div>
                {/* <div className="btn btn-primary" onClick={cloudSave}>
                    Cloud Save <i className="fa-solid fa-cloud-arrow-up"></i>
                </div> */}
                <div className="btn btn-primary" onClick={saveResume}>
                    Download <i className="fa-solid fa-download"></i>
                </div>
                {/* <div className="btn btn-light">
                    <i className="fa-solid fa-gear"></i>
                </div> */}
            </div>
            <div className="resume-builder-section accordion border-end border-light w-50" id="resume-builder-left">
                <div id="resume-builder-one" className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Personal Info</h4>
                    <PersonalInfoForm resume={[resume, setResume]}/>

                </div>
                <div id="resume-builder-two"  className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Experience</h4> 
                    <WorkExperienceForm resume={[resume, setResume]}/>

                </div>
                <div id="resume-builder-three"  className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Education</h4>
                    <EducationForm resume={[resume, setResume]}/>
                </div>
                <div id="resume-builder-four"  className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Skills</h4>
                    <SkillList resume={[resume, setResume]}/>
                </div>
            </div>

            <div className="resume-builder-section w-50" id="resume-builder-right">
                <ResumePreview resume={resume} />
            </div>
        </>
    )
    
    
}


export default ResumeBuilder
