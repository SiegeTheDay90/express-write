import React, { useRef, useState, useEffect } from "react";
import "./BulletPointInput.scss"

export default function BulletPointInput({idx, name, label, value, setValue}){
    const newInputRef = useRef();
    const  [bullets, setBullets] = useState(value?.split("\n") || [""]);

    useEffect(() => {
        setBullets(value?.split("\n") || [""]);
    }, [value])


    // Each bullet should be an individual text input. The values of the overall bullet input will be a \n separated strings combined from the different inputs.

    function bulletUpdate(e){

        const inputElements = document.getElementsByClassName(idx+"_bullet_input");
        setValue({...e, target: {...e.target, value: Array.from(inputElements).map(bullet => bullet.value).join("\n"), name}});
    }

    function newBulletUpdate(e){
        const inputElements = document.getElementsByClassName(idx+"_bullet_input");
        // newInputRef
        if(!newInputRef.current.value.trim()){
            return;
        }
        setValue({
            ...e, target: {...e.target, value: Array.from(inputElements).map(bullet => bullet.value).concat([newInputRef.current.value]).join("\n"), name, append: true}
        });
        newInputRef.current.value = "";
    }

    return(
        <>
        <h3>{label}</h3>
            {bullets.map((bullet, idx) => <>
                <input type="text" className={idx+"_bullet_input mb-2 w-100"} value={bullet} onChange={bulletUpdate} onKeyDown={(event) => {if(event.key === "Enter" ||event.keyCode === 13) event.preventDefault()}} />
                <br/>
            </>)}
            <label>New Bullet: 
                <input ref={newInputRef} type="text" className="new_bullet_input mb-2 w-100" onBlur={newBulletUpdate} onKeyDown={(event) => {if(event.key === "Enter" ||event.keyCode === 13) event.preventDefault()}}/>
            </label>
        </>
    )
}