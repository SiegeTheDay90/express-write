import { useRef, useState } from 'react'
import React from 'react';
import '../../styles/ResumeBuilder.scss'
import PersonalInfoForm from './PersonalInfoForm';
import WorkExperienceForm from './WorkExperienceForm';

function ResumeBuilder() {

    const resumeImage = new Image();
    resumeImage.src = "./lorem-resume.png";

    function focusClick(e){
        e.currentTarget.parentElement.classList.toggle('focused');
        e.currentTarget.parentElement.classList.toggle('closed');
        setFocus(e.currentTarget);
    }

    return (
        <>
            <div className="resume-builder-section accordion border-end border-light w-50" id="resume-builder-left">
                <div id="resume-builder-one" className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Personal Information</h4>
                    <PersonalInfoForm />

                </div>
                <div id="resume-builder-two"  className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Work Experience</h4> 
                    <WorkExperienceForm />

                </div>
                <div id="resume-builder-three"  className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Education</h4>
                    <PersonalInfoForm />
                </div>
                <div id="resume-builder-four"  className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Skills</h4>
                    <PersonalInfoForm />
                </div>
            </div>

            <div className="resume-builder-section w-50" id="rseume-builder-right">
                {/* {focus && <div>{focus.id}</div>} */}
                <img id="resume-image" src="/lorem-resume.png" />
            </div>
        </>
    )
}

export default ResumeBuilder
