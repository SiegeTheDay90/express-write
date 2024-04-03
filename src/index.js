import { ajaxSubmit } from "./scripts/LoadingBar";
import { tempLetterToDocx } from "./scripts/resume-builder/util/DocX";
import NoticeBalloon from "./scripts/NoticeBalloon";
import React from 'react';
import ReactDOM from 'react-dom/client';
import ResumeBuilder from "./scripts/resume-builder/ResumeBuilder";

import "./styles.scss";

document.addEventListener("DOMContentLoaded", () => {
    Array.from(document.getElementsByClassName('ajaxForm'))?.forEach(form => {form.addEventListener('submit', ajaxSubmit);});
    
    const alertContainer = document.getElementById("alert-container");

    Array.from(document.getElementsByClassName('balloon-message'))?.forEach((message) =>{
        new NoticeBalloon(alertContainer, message.dataset.type, message.dataset.text)
    })

    const builderContainer = document.getElementById("resume-builder-container");

    if(builderContainer){
        ReactDOM.createRoot( builderContainer ).render(
            <ResumeBuilder />
        );       
    }

    const saveDocXButton = document.getElementById("save-docx-btn");

    if(saveDocXButton){
        saveDocXButton.addEventListener('click', tempLetterToDocx);
    }
})