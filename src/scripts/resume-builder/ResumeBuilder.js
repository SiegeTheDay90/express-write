// import { useEffect, useState } from 'react'
import React, {useEffect, useState} from 'react';
import '../../styles/ResumeBuilder.scss'
import PersonalInfoForm from './PersonalInfoForm';
import WorkExperienceForm from './WorkExperienceForm';
import EducationForm from './EducationForm';
import SkillList from './SkillList';
import ResumePreview from './ResumePreview';
import { saveAs } from 'file-saver';
import { Packer } from "docx";
import generateDocx from './util/DocX';
import IssueListItem from './IssueListItem';

function ResumeBuilder() {
    
    
    async function saveResume() {
        const doc = generateDocx(resume);
        const blob = await Packer.toBlob(doc);
        saveAs(blob, 'resume.docx');
    }

    function showUploadModal(){
        const modal = document.getElementById("upload-modal");
        modal.showModal();
    }

    function closeUploadModal(){
        document.getElementById("upload-modal").close();
    }
    function hasIssues(){
        return resume.totalIssues > 0;
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
                    bullets: [],
                    current: false
                  }],
                education: [{
                    institutionName: '',
                    fieldOfStudy: '',
                    degreeType: '',
                    city: '',
                    location: '',
                    to: '',
                    bullets: [],
                    current: false
                  }],
                skills: [],
            })
        }
    }

    const [errors, setErrors] = useState(null);
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
            bullets: [],
            current: false
          }],
        education: [{
            institutionName: '',
            fieldOfStudy: '',
            degreeType: '',
            city: '',
            location: '',
            to: '',
            bullets: [],
            current: false
          }],
        skills: [],
    })

    useEffect(() => {
        let storedResume = localStorage.getItem("ew-resume");
    
        if(storedResume) setResume(JSON.parse(storedResume));
        
    }, [])
    
    useEffect(() => {
        localStorage.setItem("ew-resume", JSON.stringify(resume))
    }, [resume])

    function focusClick(e){
        e.currentTarget.parentElement.classList.toggle('focused');
        e.currentTarget.parentElement.classList.toggle('closed');
    }

    async function prefill(e){
        e.preventDefault();

        if(window.confirm("You will lose unsaved work. Are you sure?")){
            const tokenRes = await fetch("/csrf");
            const data = await tokenRes.json();
            const csrfToken = data.token;
            sessionStorage.setItem("X-CSRF-Token", csrfToken);
    
    
            const file = document.getElementById("file").files[0];
            const options = {
                body: file,
                method: "POST",
                headers: {
                    "Content-Type": file.type,
                    "X-CSRF-Token": csrfToken
                }
            };
    
            const response = await fetch("/resumes", options);
            const {ok, status, id} = await response.json();

            const loadingImage = document.createElement('img');
            loadingImage.src = "https://cl-helper-development.s3.amazonaws.com/loading-box.gif";
            loadingImage.id = "loading-gif";
            document.getElementById("modal-form").appendChild(loadingImage);

            const interval = setInterval(async () => {
                const res = await fetch(`/check/${id}`);
                const data = await res.json();
                
                // Poll /check/:id until data.complete == true
                if(data.complete){
                    clearInterval(interval);
                    loadingImage.remove();

                    if(data.ok){
                        // Set Resume on success
                        setResume(JSON.parse(data.messages));
                        document.getElementById("upload-modal").close();
                    } else {
                        // Set Errors on failure
                        setErrors([`${data.messages}`]);
                    }
                }

            }, 5000)
        }


    }

    const [issues, setIssues] = useState([]);

    function refreshIssues(){
        setIssues(prev => []);
        resume.work.forEach((workItem, workItemIdx) => {
            workItem.bullets.forEach((bullet, bulletIdx) => {
                if(bullet.rating?.meta?.total > 0 && !bullet.rating?.meta?.dismissed){
                    Object.entries(bullet.rating).forEach(([key, text]) =>{
                        if(key === "meta" || key === "errors" || key === "suggestion") return;

                        if(typeof(text) === 'boolean'){
                            text = key.replaceAll('_', ' ')
                        }

                        setIssues( prev =>
                            prev.concat([
                                <IssueListItem text={text} bullet={bullet} workItemIdx={workItemIdx} bulletIdx={bulletIdx} type="manual" setResume={setResume} subIdx={key} />
                            ])
                        )
                    })

                    bullet.rating.errors.forEach((error, errorIdx) => {
                        setIssues( prev =>
                            prev.concat([
                                <IssueListItem text={error} bullet={bullet} workItemIdx={workItemIdx} bulletIdx={bulletIdx} type="auto" setResume={setResume} subIdx={errorIdx}/>
                            ])
                        )
                    })
                    console.log("Suggestion: ", bullet.rating.suggestion);
                }
            })
        })
    }
    useEffect(refreshIssues, [resume]);


    
    return (
        <>
            <dialog id="upload-modal">
                <div className="mb-1">
                    <button onClick={closeUploadModal}> X </button>
                </div>
                <form id="modal-form" className="p-2 background-secondary" onSubmit={prefill}>
                    <input type="hidden" name="authenticity_token" value="" />
                    <input type="file" name="file" id="file" accept=".pdf, .docx, .doc" className="mb-3" required />
                    <input type="submit" value="Submit" />
                </form>
                {errors && <div id="errors">
                    Something went wrong. Try again or <a href={`/bug-report?${new URLSearchParams({error: errors[0]})}`} target="_blank">report a bug.</a> <i className="fa-solid fa-arrow-up-right-from-square"></i>
                    <details>
                        <summary>Error Message</summary>
                        {errors[0]}
                    </details>
                </div>}
            </dialog>
            <div className="btn-group hover-menu" role="group">

                <div className="btn btn-primary" onClick={showUploadModal}>
                    Upload Resume <i className="fa-solid fa-cloud-arrow-up"></i>
                </div>
                
                <div className="btn btn-danger" onClick={reset}>
                    Clear <i className="fa-solid fa-rotate-right"></i>
                </div>

                <div className="btn btn-success" onClick={saveResume}>
                    Download <i className="fa-solid fa-download"></i>
                </div>

            </div>
            <div className="resume-builder-section accordion border-end border-light col-lg-5 col-md-4 col-sm-3" id="resume-builder-left">
                {   hasIssues() && 
                    <div className="resume-builder-sub-section closed position-relative" >
                        <i className="fa-solid fa-chevron-up" onClick={focusClick} ></i>
                        <div onClick={focusClick} style={{fontSize: "1.5em; padding: 0"}} >Issues <span className="text-muted">({issues.length})</span></div>
                        <ol className="content ps-3">{ issues }</ol>
                    </div>
                }
                <div id="resume-builder-one" className="resume-builder-sub-section closed position-relative" >
                    <i className="fa-solid fa-chevron-up" onClick={focusClick} ></i>
                    <div onClick={focusClick} style={{fontSize: "1.5em; padding: 0"}} >Personal Info</div>
                    <PersonalInfoForm resume={[resume, setResume]}/>

                </div>
                <div id="resume-builder-two"  className="resume-builder-sub-section closed position-relative" >
                    <i className="fa-solid fa-chevron-up" onClick={focusClick} ></i>
                    <div onClick={focusClick} style={{fontSize: "1.5em; padding: 0"}} >Experience</div> 
                    <WorkExperienceForm resume={[resume, setResume]}/>

                </div>
                <div id="resume-builder-three"  className="resume-builder-sub-section closed position-relative" >
                    <i className="fa-solid fa-chevron-up" onClick={focusClick} ></i>
                    <div onClick={focusClick} style={{fontSize: "1.5em; padding: 0"}} >Education</div>
                    <EducationForm resume={[resume, setResume]}/>
                </div>
                <div id="resume-builder-four"  className="resume-builder-sub-section closed position-relative" >
                    <i className="fa-solid fa-chevron-up" onClick={focusClick} ></i>
                    <div onClick={focusClick} style={{fontSize: "1.5em; padding: 0"}} >Skills</div>
                    <SkillList resume={[resume, setResume]}/>
                </div>
            </div>

            <div className="resume-builder-section col-lg-7 col-md-8 col-sm-9" id="resume-builder-right">
                <ResumePreview resume={resume} />
            </div>
        </>
    )
    
    
}


export default ResumeBuilder
