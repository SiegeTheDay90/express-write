import { useRef, useState } from 'react'
import React from 'react';
import '../../styles/ResumeBuilder.scss'
import PersonalInfoForm from './PersonalInfoForm';

function ResumeBuilder() {

    const [focus, setFocus] = useState(null);

    async function focusClick(e){
        // debugger
        focus?.classList?.toggle('focused');
        focus?.classList?.toggle('closed');
        e.currentTarget.classList.toggle('focused');
        e.currentTarget.classList.toggle('closed');
        setFocus(e.currentTarget);
    }

    return (
        <>
            <div className="flex-header">
                This is a React Component! <br/><b>Focused on: {focus?.id || "Nothing!"}</b>
            </div>
            <div className="resume-builder-section border border-primary h-75 w-25" id="resume-builder-left">
                <h3>Sections</h3>
                <div id="resume-builder-one" className="resume-builder-sub-section closed" onClick={focusClick}>
                    <h4>Personal Information</h4>
                    <PersonalInfoForm />

                </div>
                <div id="resume-builder-two"  className="resume-builder-sub-section closed" onClick={focusClick}>
                    <h4>Work Experience</h4> 
                    <PersonalInfoForm />

                </div>
                <div id="resume-builder-three"  className="resume-builder-sub-section closed" onClick={focusClick}>
                    <h4>Education</h4>
                    <PersonalInfoForm />


                </div>
            </div>

            <div className="resume-builder-section border border-primary w-25" id="rseume-builder-right">
                {focus && <div>{focus.id}</div>}
            </div>
        </>
    )
}

export default ResumeBuilder
