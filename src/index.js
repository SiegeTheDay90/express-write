import { ajaxSubmit } from "./scripts/LoadingBar";
import NoticeBalloon from "./scripts/NoticeBalloon";
import "./styles.scss";

document.addEventListener("DOMContentLoaded", () => {
    Array.from(document.getElementsByClassName('ajaxForm'))?.forEach(form => {form.addEventListener('submit', ajaxSubmit);});
    const hamburgerClick = (e) => {
        e.stopPropagation();
        const sidebar = document.getElementById("sidebar");
        sidebar.classList.add("show");
        const hide = function(e){
            if(!sidebar.contains(e.target)){
              e.preventDefault();
              sidebar.classList.remove("show");
              document.removeEventListener('click', hide);
            }
        }
        document.addEventListener('click', hide);
    }
    document.getElementById("hamburger-container")?.addEventListener('click', hamburgerClick);

    const alertContainer = document.getElementById("alert-container");

    Array.from(document.getElementsByClassName('balloon-message'))?.forEach((message) =>{
        new NoticeBalloon(alertContainer, message.dataset.type, message.dataset.text)
    })
})