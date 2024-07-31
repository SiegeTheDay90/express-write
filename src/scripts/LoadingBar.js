import NoticeBallon from "./NoticeBalloon";

class LoadingBar {
  constructor(_form, url, options={}, action, completionCallback){
      this.bar = document.createElement('progress');
      this.action = action;
      this.maxTime = 60;
      this.status = document.createElement('span');
      this.statusBox = document.createElement('p');
      this.loadingImage = new Image();
      this.loadingImage.src = "https://cl-helper-development.s3.amazonaws.com/loading-box.gif";
      this.loadingImage.id = "loading-gif";
      
      this.timeElapsed = 0;
      this.progressMessages = ["Mixing Ink...", "Dipping pen...", "Shuffling papers...", "Thinking...", "Writing..."]
      this.defaultMessage = "Writing... This can take a minute."
      
      this.completionCallback ||= completionCallback;
      
      this.popUp = document.createElement('dialog');
      this.popUp.id = 'loadingModal';
      this.popUp.style = {
        ...this.popUp.style,
        border: '2px solid green',
        padding: '20px',
        display: 'flex',
        gap: '10px'
      }
      this.popUp.innerHTML = `
      <style>
      #modal {
        position: relative;
        width: 100%;
        max-width: 600px;
        margin: 0 auto;
        padding: 20px;
        border: 1px solid #ccc;
        border-radius: 8px;
        background-color: #fff;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      }
      
      #closeButton {
        position: absolute;
        top: 10px;
        left: 10px;
        background: none;
        border: none;
        font-size: 16px;
        cursor: pointer;
      }
      
      #modalContent {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      #modalText {
        flex: 1;
        padding-right: 20px;
        line-height: 175%;
      }
      
      #modalLinks {
        display: flex;
        flex-direction: column;
      }
      
      #modalLinks a {
        margin-bottom: 10px;
      }
      
      #modalLinks img {
        width: 85px;
        height: auto;
      }
    </style>      
      <div id="modal">
        <div id="modalContent">
          <div id="modalText">
            <p>While you wait, consider following 
              <a href="https://www.linkedin.com/company/express-write/" target="_blank">ExpressWrite</a>!<br/> It takes a few seconds and means the world to me!
            </p>
          </div>
          <div id="modalLinks">
            <h5>Support ExpressWrite</h5>
            <h6>Donate</h6>
            <span style="display:flex;gap:10px;">
              <a href="https://cash.app/CJS90" target="_blank">
                <img style="border-radius: 100%; width: 50px" src="https://cl-helper-development.s3.amazonaws.com/cashapp.png" />
              </a> 
              <a href="https://venmo.com/clarence-james-1" target="_blank">
                <img style="border-radius: 100%; width: 50px" src="https://cl-helper-development.s3.amazonaws.com/venmo.png" />
              </a> 
            </span>
            <h6>Share</h6>  
            <a href="https://www.linkedin.com/sharing/share-offsite/?url=https%3A%2F%2Fwww.expresswrite.ai%2F&text=ExpressWrite%20is%20a%20project%20built%20by%20one%20developer.%20Test%20it%20out%20for%20free%21" target="_blank">
              <img src="https://cl-helper-development.s3.amazonaws.com/linkedin-share-button-icon.png" />
            </a> 
            <br/>
            <a href="https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fwww.expresswrite.ai%2F" target="_blank">
              <img src="https://cl-helper-development.s3.amazonaws.com/facebook-share-button-icon.png" />
            </a>
          </div>
        </div>
      </div>
    `
      this.popUp.append(document.createElement('br'));
      this.popUp.append(this.bar);

      this.statusBox.append(this.status);
      this.statusBox.append(this.loadingImage);
      this.popUp.append(this.statusBox);
      document.querySelector('*').append(this.popUp);
      this.popUp.showModal();

      this.bar.innerText = 0;
      this.bar.max = 100;

      this.status.innerHTML = "Getting Started..."
      // options["authenticity_token"] = "<%= form_authenticity_token %>";
      fetch(url, options).then((res) => {this.loadingCallback(res)}).catch((error) => {
        this.failureCallback([error.toString()]);
      });
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
        } else if(this.timeElapsed > this.maxTime){ // Timeout
          this.status.innerHTML = "";
          const statusText = document.createElement('p');
          statusText.innerText = "This is taking longer than usual."
          const cancelButton = document.createElement('button');
          cancelButton.innerText = "Cancel & Try Again";
          cancelButton.classList.add("btn");
          cancelButton.classList.add("btn-primary");

          cancelButton.addEventListener('click', () => {
            this.failureCallback("cancel");
          })
          this.status.append(statusText);
          this.status.append(cancelButton);
          this.status.append(" or wait a little longer!")
          return;
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
      this.status.innerText = `Complete! Link ready in ${count}.....`
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
        this.status.innerHTML = `<a href="${window.location.origin + this.nextPath}">Your Letter</a>`;
        this.loadingImage.remove();
      }, 5000);
      setInterval(() => {
        this.status.innerText = `Complete! Link ready in ${--count}`+'.'.repeat(count);
      }, 990);

  }

  failureCallback(errors){
    this.popUp.remove();
    if(errors === "cancel"){
      clearInterval(this.interval);
      errors = ["Action cancelled."]
    }
    console.error("Request Failed: ", errors.join("\n"));
    const alertContainer = document.getElementById("alert-container");
    errors.forEach(error => {
      new NoticeBallon(alertContainer, "error", error)
    })

  }
}

export const ajaxSubmit = function(e){
  e.preventDefault();
  const form = e.target;
  const method = form.querySelector("input[name=_method]") ? form.querySelector("input[name=_method]").value : form.method || "GET";
  const options = { method, headers: {} };
  // options.headers["Content-Type"] = "application/json";
  
  const inputs = form.querySelectorAll("input, textarea, select");
  let queryParams = new URLSearchParams();
  inputs.forEach((input) => {
    if(!input.name || input.classList.contains("hidden")) return;
    switch(input.type){
      case "radio":
        if(input.checked) queryParams.append(input.name, input.value);
        break;

      case "file":
        // if(options.body["link"]) break;
        options.body ||= new FormData();
        // options.body = input.files[0];
        options.body.append(input.name, input.files[0]);
        // const type = document.getElementById("resume-format").value;
        // if(type === "PDF"){
          // options.headers["Content-Type"] = 'application/pdf';
          // queryParams.append("resume-format", "PDF");
        // } else if(type === "DOCX"){
          // options.headers["Content-Type"] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          // queryParams.append("resume-format", "DOCX");
        // }
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

  // if(options.headers["Content-Type"] === "application/json") options.body = JSON.stringify(options.body);
  
  new LoadingBar(
    form, //Form Element to be relplaced
    form.action+"?"+queryParams.toString(), // Fetch URL
    options, // Method, Body, Headers
    form.dataset?.action // i.e. data-action="letters#generate"
  );
}
