class LoadingBar {
    constructor(container, url, options={}, completionCallback){
        this.bar = document.createElement('progress');
        this.status = document.createElement('p');
        this.container = container.parentElement;
        container.remove();
        this.complete = 0;

        this.completionCallback ||= completionCallback;

        this.container.append(this.bar);
        this.container.append(this.status);

        this.bar.innerText = 0;
        this.bar.max = 100;

        this.interval = setInterval(()=>{if(this.complete<90)this.incComplete(5)}, 750);

        this.status.innerText = "In Progress..."
        options["authenticity_token"] = "<%= form_authenticity_token %>";
        // console.log("LoadingBar: ",options["authenticity_token"]);
        fetch(url, options).then((res) => this.completionCallback(res)).catch(this.failureCallback);
    }

    incComplete(num){
        this.complete += num;
        this.bar.innerText = this.complete;
        this.bar.value = this.complete;
    }

    async completionCallback(response){
        
        this.complete = 100;
        this.bar.innerText = 100;
        this.bar.value = 100;
        if(response.ok){
            this.status.innerText = "Complete!"
        } else {
            this.status.innerText = "ERROR"
        }

    }

    failureCallback(error){
        console.error("Loading Bar Failed: ", error);
        console.log(this);
    }
}
function ajaxSubmit(e){
    e.preventDefault();
    const form = e.target;
    const method = form.querySelector("input[name=_method]") ? form.querySelector("input[name=_method]").value : form.method;
    const options = { method, body: {} };
    const inputs = form.querySelectorAll("input, textarea");
    inputs.forEach((input) => {
        if(input.type === "radio" && input.checked){options.body[input.name] = input.value}
        else if(input.type !== "radio" && input.name){options.body[input.name] = input.value};
    });
    options.headers = {};
    options.headers["X-CSRF-Token"] = options["authenticity_token"];
    options.headers["Content-Type"] = "application/json";
    options.body = JSON.stringify(options.body);
    new LoadingBar(form, form.action, options);
}