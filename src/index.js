import { ajaxSubmit } from "./scripts/LoadingBar";
import NoticeBalloon from "./scripts/NoticeBalloon";
import "./styles.scss";

// DOM Attatchments
document.addEventListener("DOMContentLoaded", () => {
    // Add event listener to all forms with class 'ajaxForm' to handle AJAX submission
    Array.from(document.getElementsByClassName('ajaxForm'))?.forEach(form => {form.addEventListener('submit', ajaxSubmit);});

    // Display notice balloons for elements with class 'balloon-message'
    const alertContainer = document.getElementById("alert-container");
    Array.from(document.getElementsByClassName('balloon-message'))?.forEach((message) =>{
        new NoticeBalloon(alertContainer, message.dataset.type, message.dataset.text)
    })
})

// Incrememnts specific hit counters on page load
import HitCounter from "./scripts/HitCounter";
const meta_name = document.querySelector("meta[name='hit-counter-name']")?.content || "EW-NoMeta";
const counter = HitCounter(meta_name);
counter.inc();