class NoticeBalloon{
    constructor(container, type="notice", message){
        this.type = type;
        this.parent = container;
        this.balloon = document.createElement("div");
        this.balloon.classList.add("balloon")
        this.balloon.classList.add(this.type === "error" ? "text-danger" : "text-info")
        this.balloon.classList.add(type);
        this.balloon.innerText = message;
        this.closeButton = document.createElement("span");
        this.balloon.appendChild(this.closeButton);
        this.closeButton.classList.add("close-button");
        this.close = this.close.bind(this);
        this.closeButton.addEventListener('click', this.close)
        this.opacity = 1;
        this.parent.appendChild(this.balloon);
    }

    close(e){
        this.interval = setInterval(() => {
            if(this.opacity > 0){
                this.opacity -= 0.1;
                this.balloon.style.opacity = this.opacity;
            } else {
                this.balloon.remove();
                clearInterval(this.interval);
            }
        }, 20);
    }


}

export default NoticeBalloon;