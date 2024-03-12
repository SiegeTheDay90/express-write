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
            firstName: 'Clarence',
            lastName: 'Smith',
            profession: 'Software Engineer',
            phoneNumber: '6463747244',
            email: 'ClarenceSmith90@gmail.com',
            website: ''
        },
        work: [{
            companyName: 'App Academy',
            jobTitle: 'Instructor',
            city: 'New York, NY',
            from: '01-01-2023',
            to: '06-21-2024',
            description: 'This is a\nTest Descriptionn\nMeep',
            current: false
        },
        {
            companyName: 'NYC DOE',
            jobTitle: 'Math Teacher',
            city: 'Bronx, NY',
            from: '10-19-2016',
            to: '08-15-2022',
            description: 'This is a\nTest Descriptionn\nMeep',
            current: false
        }],
        education: [{
            institutionName: 'Hunter College',
            fieldOfStudy: 'Mathematics',
            degreeType: 'BA',
            city: '',
            from: '',
            to: '01-01-2013',
            description: 'This is a\nTest Descriptionn\nMeep',
            current: false
        }],
        skills: ['Object Oriented Programming', 'Web Development', 'Teaching', 'Documentation', 'Presentation']
    })

    function focusClick(e){
        e.currentTarget.parentElement.classList.toggle('focused');
        e.currentTarget.parentElement.classList.toggle('closed');
    }

    return (
        <>
            <div className="resume-builder-section accordion border-end border-light w-50" id="resume-builder-left">
                <div id="resume-builder-one" className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Personal Information</h4>
                    <PersonalInfoForm resume={[resume, setResume]}/>

                </div>
                <div id="resume-builder-two"  className="resume-builder-sub-section closed" >
                    <h4 onClick={focusClick} >Work Experience</h4> 
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
