import { ajaxSubmit } from "./LoadingBar";

document.addEventListener("DOMContentLoaded", () => {
    Array.from(document.getElementsByClassName('ajaxForm')).forEach(form => form.addEventListener('submit', ajaxSubmit));
})