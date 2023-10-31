class LoadingBar {
    constructor(container, url, options={}, completionCallback){
        this.bar = document.createElement('progress');
        this.status = document.createElement('p');
        this.container = container;
        this.complete = 0;

        this.completionCallback ||= completionCallback;

        this.container.append(this.bar);
        this.container.append(this.status);

        this.bar.innerText = 0;
        this.bar.max = 100;

        this.interval = setInterval(()=>{if(this.complete<90)this.incComplete(5)}, 750);

        this.status.innerText = "In Progress..."
        fetch(url, {mode: 'no-cors'}).then((res) => this.completionCallback(res)).catch(this.failureCallback);
    }

    incComplete(num){
        this.complete += num;
        this.bar.innerText = this.complete;
        this.bar.value = this.complete;
    }

    completionCallback(response){
        this.complete = 100;
        this.bar.innerText = 100;
        this.bar.value = 100;
        debugger
        if(response.ok){
            this.status.innerText = "Complete!"
        } else {
            this.status.innerText = "ERROR"
        }

    }

    failureCallback(error){
        console.error("Loading Bar Failed: ", error);
    }
}

function ajaxSubmit(e){
    e.preventDefault();
    console.log(e.target);
    const form = e.target
    debugger;
    const inputs = form.querySelectorAll("input");
    const method = form.querySelector("input[name=_method]") ? form.querySelector("input[name=_method]").value : form.method;
    new LoadingBar(form, form.action, { method });
}