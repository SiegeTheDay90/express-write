import React from 'react';
import '../../styles/ResumePreview.scss';

function EducationForm({ resume }){
    const { personal, education, work, skills } = resume;

    console.log(skills);
    return (
        <div id="resume-preview-container" className="p-4 h-100">
            <section id="resume-preview-personal" className="resume-preview-section">
                <h4 id="resume-preview-name">{`${personal.firstName.trim() || 'Jay'} ${personal.lastName.trim() || 'Doe'}`}</h4>
                {personal.profession && <h6 id="resume-preview-profession">{`${personal.profession.trim() || ''}`}</h6>}
                <p id="resume-preview-email">{personal.email.trim() || 'JayDoe@writewise.io'}</p>
                {personal.phoneNumber && <p id="resume-preview-phone">{personal.phoneNumber.trim() || ''}</p>}
                {personal.website && <p id="resume-preview-website">{personal.website.trim() || ''}</p>}
            </section>

            <section id="resume-preview-work" className="mt-4 resume-preview-section">
                <h5>Professional Experience</h5>

                    {
                        work.map( (item, idx) => (
                            <div key={idx} className="resume-preview-work-item mt-1">
                                <h6 className="d-flex flex-row justify-content-between"><span>{item.companyName || 'company'} - {item.jobTitle || 'title'}</span><span>{item.from || 'Date'} to {item.to || 'present'}</span></h6>
                                <p>{item.city || 'City, State'}</p>
                                <p>{item.description || 'Description'}</p>
                            </div>
                        ))
                    }
            </section>

            <section id="resume-preview-education" className="mt-3 resume-preview-section">
                <h5>Education</h5>

                    {
                        education.map( (item, idx) => (
                            <div key={idx} className="resume-preview-work-item mt-1">
                                <h6 className="d-flex flex-row justify-content-between"><span>{item.degreeType ? item.degreeType+' - ' : ''}{item.fieldOfStudy || 'field'}</span><span>{item.to || 'present'}</span></h6>
                                <p>{item.institutionName || 'School'}</p>
                                <p>{item.description || 'Description'}</p>
                            </div>
                        ))
                    }
            </section>

            <section id="resume-preview-skills" className="mt-3 resume-preview-section">
                <h5>Skills</h5>

                    {
                        skills.join(" | ")
                    }
            </section>
        </div>
    );
}

export default EducationForm
