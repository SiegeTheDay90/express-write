
import { tempLetterToDocx } from "./scripts/resume-builder/util/DocX";

document.addEventListener("DOMContentLoaded", () => {

    const saveDocXButton = document.getElementById("save-docx-btn");

    if(saveDocXButton){
        saveDocXButton.addEventListener('click', tempLetterToDocx);
    }
})