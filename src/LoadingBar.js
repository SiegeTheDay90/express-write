class LoadingBar {
  constructor(form, url, options={}, action, completionCallback){
      this.bar = document.createElement('progress');
      this.status = document.createElement('p');
      this.container = form.parentElement;
      this.originalForm = form;
      form.remove();
      this.action = action;
      this.complete = 0;
      this.timeElapsed = 0;
      this.resourceId;
      this.progressMessages = ["Dipping pen...", "Mixing Ink...", "Ruffling paper..."]
      this.defaultMessage = "Writing... This can take a few minutes."

      this.completionCallback ||= completionCallback;

      this.container.append(this.bar);
      this.container.append(this.status);

      this.bar.innerText = 0;
      this.bar.max = 100;

      this.status.innerText = "Getting Started..."
      // options["authenticity_token"] = "<%= form_authenticity_token %>";
      fetch(url, options).then((res) => this.loadingCallback(res)).catch(this.failureCallback);
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
          if(data.ok){ // Success
            this.messages = data.messages
            clearInterval(this.interval);
            this.completionCallback(data.resource_id);
          } else{ // Failure
            clearInterval(this.interval);
            this.failureCallback(data.errors);
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

  failureCallback(error){
    console.error("Request Failed: ", error);
    this.status.innerText = "ERROR";
    const tryAgain = document.createElement("button");
    tryAgain.classList.add("btn");
    tryAgain.classList.add("btn-primary");
    tryAgain.innerText = "Try Again?";
    tryAgain.addEventListener("click", (e) => {
      this.container.append(this.originalForm);
      this.bar.remove();
      this.status.remove();
      tryAgain.remove();
    })
    this.container.append(tryAgain);
  }
}

export const ajaxSubmit = function(e){
  e.preventDefault();
  const form = e.target;
  const method = form.querySelector("input[name=_method]") ? form.querySelector("input[name=_method]").value : form.method;
  const options = { method, body: {}, headers: {} };
  options.headers["Content-Type"] = "application/json";
  
  const inputs = form.querySelectorAll("input, textarea, select");
  let extraParam = "";
  inputs.forEach((input) => {
    if(!input.name) return;
    switch(input.type){
      case "radio":
        if(input.checked) options.body[input.name] = input.value;
        break;

      case "file":
        if(options.body["link"]) break;
        options.body = new FormData();
        options.body.append('file', input.files[0]);
        const type = document.getElementById("type").value;
        if(type === "PDF"){
          options.headers["Content-Type"] = 'application/pdf';
          extraParam = "?type=PDF"
        } else if(type === "DOCX"){
          options.headers["Content-Type"] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          extraParam = "?type=DOCX"
        }
        break;

      default:
        if (input.name === "authenticity_token"){
          options.headers["X-CSRF-Token"] = input.value
        } 
        else {
          options.body[input.name] = input.value
        };
    }
  });
  if(options.headers["Content-Type"] === "application/json") options.body = JSON.stringify(options.body);
  debugger
  new LoadingBar(
    form, //Form Element to be relplaced
    form.action+extraParam, // Fetch URL
    options, // Method, Body, Headers
    form.dataset?.action // i.e. data-action="letters#generate"
  );
}