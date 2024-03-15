import { useState } from 'react'
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
    
    const [resume, setResume] = useState({
        personal: {
            firstName: '',
            lastName: '',
            profession: '',
            phoneNumber: '',
            email: '',
            website: ''
        },
        work: [],
        education: [],
        skills: [],
    })

    function focusClick(e){
        e.currentTarget.parentElement.classList.toggle('focused');
        e.currentTarget.parentElement.classList.toggle('closed');
    }

    return (
        <>
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
            <div className="w-100"><button onClick={saveResume}>Download as Docx</button></div>
        </>
    )
    
    
}


export default ResumeBuilder
