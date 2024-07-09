import { gsap } from 'gsap';
document.addEventListener("DOMContentLoaded", () => {

    const logoImage = document.querySelector("#logo-img.splash");

    if(logoImage){
        
    //     let imageTL = gsap.timeline({}); // The quill used to slide over and "write" the logo
    //     imageTL
    //     .to("#logo-img.splash", {
    //         x: "43vw",
    //         rotation: 60,
    //         duration: 1,
    //         ease: "power2.in"
    //     }).to("#logo-img.splash",{
    //         rotation: 75,
    //         x: "44vw",
    //         duration: 0.1
    //     })
    //     .to("#logo-img.splash", {
    //         delay: 0.5,
    //         x: -5,
    //         rotation: 65,
    //         duration: 0.1
    //     }).to("#logo-img.splash", {
    //         x: 0,
    //         rotation: 70,
    //         duration: 0.2
    //     })

        let textTL = gsap.timeline({});
        textTL
        .to("#logo-text", {
            delay:0.35,
            "--clip": 0,
            duration: 0.65,
            ease: "power2.in"
        })

        
        // let bannerTL = gsap.timeline({}); // The banner used to start at 40vh and would shrink to 25vh
        // bannerTL
        // .to("#splash-logo", {
        //     delay: 2,
        //     height: "25vh",
        //     duration: 1.5,
        //     ease: "power1.inOut"
        // })
    }
})