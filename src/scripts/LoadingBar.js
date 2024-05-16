import NoticeBallon from "./NoticeBalloon";

class LoadingBar {
  constructor(form, url, options={}, action, completionCallback){
      this.bar = document.createElement('progress');
      this.status = document.createElement('span');
      this.statusBox = document.createElement('p');
      this.loadingImage = new Image();
      this.loadingImage.src = ["https://cl-helper-development.s3.amazonaws.com/loading-box.gif", "https://cl-helper-development.s3.amazonaws.com/loading-ball.gif"][Math.floor(Math.random()*2)]
      this.loadingImage.id = "loading-gif"
      this.container = form.parentElement;
      this.originalForm = form;
      // form.remove();
      this.action = action;
      this.complete = 0;
      this.timeElapsed = 0;
      this.resourceId;
      this.progressMessages = ["Dipping pen...", "Mixing Ink...", "Ruffling paper..."]
      this.defaultMessage = "Writing... This can take a few minutes."
      
      this.completionCallback ||= completionCallback;
      
      this.popUp = document.createElement('dialog');
      const closePopUp = document.createElement('button');
      this.popUp.innerHTML = `
      <div>
        <p>While you wait, consider sharing us on LinkedIn! It takes a few seconds an means the world to me!</p>
        <a href="https://www.linkedin.com/sharing/share-offsite/?url=https%3A%2F%2Fwrite-wise-4d2bfd5abb7a.herokuapp.com%2F&text=" target="_blank">
          LinkedIn
        </a>
      </div>
      `
      closePopUp.innerText = "x";
      closePopUp.addEventListener("click", () => {
        this.popUp.remove();
        this.popUp.close();
      });
      this.popUp.append(closePopUp);
      this.popUp.append(document.createElement('br'));
      this.popUp.append(this.bar);

      this.statusBox.append(this.status);
      this.statusBox.append(this.loadingImage);
      this.popUp.append(this.statusBox);
      this.container.append(this.popUp);
      this.popUp.showModal();

      this.bar.innerText = 0;
      this.bar.max = 100;

      this.status.innerHTML = "Getting Started..."
      // options["authenticity_token"] = "<%= form_authenticity_token %>";
      fetch(url, options).then((res) => {this.loadingCallback(res)}).catch(() => {this.popUp.remove(); this.failureCallback()});
  }

  incComplete(num){
      this.complete += num;
      this.bar.innerText = this.complete;
      this.bar.value = this.complete;
  }

  async loadingCallback(response){
    if(response.ok){
      const data = await response.json(); // Parse API response
      this.request_id = data.id; // Request_id from backend
      
      this.interval = setInterval(async () => { // Ping backend until request is complete
        const response = await fetch(`/check/${this.request_id}`)
        const data = await response.json();
        if(data.complete){ // Request complete
          clearInterval(this.interval);
          if(data.ok){ // Success
            this.messages = data.messages
            this.completionCallback(data.resource_id);
          } else{ // Failure
            this.failureCallback(JSON.parse(data.messages));
          }
        } else if(this.timeElapsed > 240){ // Timeout
          clearInterval(this.interval);
          this.failureCallback("Timeout");
        }
        
        this.status.innerText = this.progressMessages.length ? this.progressMessages.pop() : this.defaultMessage;
        this.timeElapsed += 5;
      }, 5000)
    }
  }

  async completionCallback(id){
      
      this.complete = 100;
      this.bar.innerText = 100;
      this.bar.value = 100;
      let count = 5;
      let bio;
      let params;
      this.status.innerText = `Complete! Redirecting in ${count}.....`
      switch(this.action){
        case "listings#generate":
          this.nextPath = `/listings/${id}/`;
        break;

        case "letters#generate":
          this.nextPath = `/letters/${id}/`;
        break;

        case "profiles#new":
          bio = JSON.parse(this.messages);
          params = new URLSearchParams(bio).toString();
          this.nextPath = `/profiles/new?`+params;
        break;

        case "profiles#edit":
          bio = JSON.parse(this.messages);
          params = new URLSearchParams(bio).toString();
          this.nextPath = `/profiles/${id}/edit?`+params+"&m=Profile+Not+Yet+Saved";
        break;

        case "express#generate":
          this.nextPath = `/temp/${id}`;
        break;

        case "express-member#generate":
          this.nextPath=`/letters/${id}`
        break;

        default:
          this.nextPath = "/";
      }

      setTimeout(() => {
        window.location.href = window.location.origin + this.nextPath;
      }, 5000);
      setInterval(() => {
        this.status.innerText = `Complete! Redirecting in ${--count}`+'.'.repeat(count);
      }, 990);

  }

  failureCallback(errors){
    console.error("Request Failed: ", errors.join("\n"));
    const alertContainer = document.getElementById("alert-container");
    errors.forEach(error => {
      new NoticeBallon(alertContainer, "error", error)
    })
    this.status.innerText = "ERROR";
    const tryAgain = document.createElement("button");
    tryAgain.classList.add("btn");
    tryAgain.classList.add("btn-primary");
    tryAgain.innerText = "Try Again?";
    tryAgain.addEventListener("click", (e) => {
      this.container.append(this.originalForm);
      this.bar.remove();
      this.status.remove();
      this.loadingImage.remove();
      tryAgain.remove();
    })
    this.container.append(tryAgain);
  }
}

export const ajaxSubmit = function(e){
  e.preventDefault();
  const form = e.target;
  const method = form.querySelector("input[name=_method]") ? form.querySelector("input[name=_method]").value : form.method || "GET";
  const options = { method, body: {}, headers: {} };
  options.headers["Content-Type"] = "application/json";
  
  const inputs = form.querySelectorAll("input, textarea, select");
  let queryParams = new URLSearchParams();
  inputs.forEach((input) => {
    if(!input.name) return;
    switch(input.type){
      case "radio":
        if(input.checked) queryParams.append(input.name, input.value);
        break;

      case "file":
        if(options.body["link"]) break;
        // options.body = new FormData();
        options.body = input.files[0];
        // options.body.append('file', input.files[0]);
        const type = document.getElementById("resume-format").value;
        if(type === "PDF"){
          options.headers["Content-Type"] = 'application/pdf';
          queryParams.append("resume-format", "PDF");
        } else if(type === "DOCX"){
          options.headers["Content-Type"] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          queryParams.append("resume-format", "DOCX");
        }
        break;

      default:
        if (input.name === "authenticity_token"){
          options.headers["X-CSRF-Token"] = input.value
        } 
        else {
          queryParams.append(input.name, input.value)
          // options.body[input.name] = input.value
        };
    }
  });

  if(options.headers["Content-Type"] === "application/json") options.body = JSON.stringify(options.body);
  
  new LoadingBar(
    form, //Form Element to be relplaced
    form.action+"?"+queryParams.toString(), // Fetch URL
    options, // Method, Body, Headers
    form.dataset?.action // i.e. data-action="letters#generate"
  );
}

async function isValidURL(url) {
  // Regular expression pattern to match URLs
  const urlPattern = /(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})/;
  if(!urlPattern.test(url)){
    return false;
  }
  try{
    await fetch(url, {mode: 'no-cors'});
    return true;
  } catch {
    return false;
  }
}



async function checkValidSite(input, button){
  let url = input.value;
  input.disabled = true;
  const loadingImage = new Image();
  loadingImage.src = ["https://cl-helper-development.s3.amazonaws.com/loading-box.gif", "https://cl-helper-development.s3.amazonaws.com/loading-ball.gif"][Math.floor(Math.random()*2)]
  loadingImage.id = "loading-gif"
  button.parentElement.appendChild(loadingImage);
  const statusDiv = document.getElementById('status');
  if(url.slice(0,4).toLowerCase() !== "http"){
    url = "https://" + url;
  }
  if(!(await isValidURL(url))){
    statusDiv.classList.add('text-danger');
    statusDiv.classList.remove('text-sucess');
    statusDiv.innerHTML = `❌ Not a valid URL`;
  } else {
    const response = await fetch(`/url-check/?url=${url}`);
    const {ok, status} = await response.json();

    if(ok === true){
      button.disabled = false;
      statusDiv.innerHTML = `✅`;
      statusDiv.classList.add('text-success');
      statusDiv.classList.remove('text-danger');
    } else {
      button.disabled = true;
      statusDiv.classList.remove('text-sucess');
      statusDiv.classList.add('text-danger');
      statusDiv.innerHTML = `❌ ${status}`;
    }
  }
  input.disabled = false;
  loadingImage.remove();
}

function listingInputChange(e=event){
  if(localStorage.getItem('debounce')){
    clearTimeout(localStorage.getItem('debounce'));
  }
  const type = Array.from(document.querySelectorAll("input[type=radio]")).filter(radio => radio.checked)[0].value;
  const input = document.getElementById("text-input");
  const submit = document.getElementById("express-submit");
  submit.disabled = true;
  if(input.value === "") return;
  if(e.target.type === "radio"){
    input.value = "";
  } else {
    if(type === 'url'){
      const debounce = setTimeout(() => {
        checkValidSite(input, submit);
      }, 500);

      localStorage.setItem('debounce', debounce);

    } else {
      if(e.target.value.trim()){
        submit.disabled = false;
      } else {
        submit.disabled = true;
      }
    }
  }

}