import React from 'react';
import ReactDOM from 'react-dom/client';
import ResumeBuilder from "./scripts/resume-builder/ResumeBuilder";




document.addEventListener("DOMContentLoaded", () => {
    const builderContainer = document.getElementById("resume-builder-container");

    if(builderContainer){
        ReactDOM.createRoot( builderContainer ).render(
            <ResumeBuilder />
        );       
    }

});