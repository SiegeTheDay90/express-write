import { ajaxSubmit } from "./scripts/LoadingBar";
import { tempLetterToDocx } from "./scripts/resume-builder/util/DocX";
import NoticeBalloon from "./scripts/NoticeBalloon";
import React from 'react';
import ReactDOM from 'react-dom/client';
import ResumeBuilder from "./scripts/resume-builder/ResumeBuilder";
import { gsap } from 'gsap';

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

    const logoImage = document.querySelector("#logo-img.splash");

    if(logoImage){
        
        let imageTL = gsap.timeline({});
        imageTL
        .to("#logo-img.splash", {
            x: "43vw",
            rotation: 60,
            duration: 1,
            ease: "power2.in"
        }).to("#logo-img.splash",{
            rotation: 75,
            x: "44vw",
            duration: 0.1
        })
        .to("#logo-img.splash", {
            delay: 0.5,
            x: -5,
            rotation: 65,
            duration: 0.1
        }).to("#logo-img.splash", {
            x: 0,
            rotation: 70,
            duration: 0.2
        })

        let textTL = gsap.timeline({});
        textTL
        .to("#logo-text", {
            delay:0.35,
            "--clip": 0,
            duration: 0.65,
            ease: "power2.in"
        })

        
        let bannerTL = gsap.timeline({});
        bannerTL
        .to("#splash-logo", {
            delay: 2,
            height: "25vh",
            duration: 1.5,
            ease: "power1.inOut"
        })

    }
})