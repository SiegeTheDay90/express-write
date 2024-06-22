import React, { useRef, useState, useEffect } from "react";
import "./BulletPointInput.scss"
import BulletPointInputItem from "./BulletPointInputItem";

export default function BulletPointInput({idx, name, type, label, value, setValue}){
    const  [bullets, setBullets] = useState(value?.length ? value?.split("\n") : []);
    const classId = type+"_bullet_input_"+idx;

    useEffect(() => {
        setBullets(value?.length ? value?.split("\n") : []);
    }, [value])


    // Each bullet should be an individual text input. The values of the overall bullet input will be a \n separated strings combined from the different inputs.

    function bulletUpdate(){
        const inputElements = document.getElementsByClassName(classId);
        setValue({ target: {value: Array.from(inputElements).map(bullet => bullet.dataset.value).join("\n"), name }});
    }

    function newBullet(){
        const inputElements = document.getElementsByClassName(classId);
        setValue({ target: {value: Array.from(inputElements).map(bullet => bullet.dataset.value).concat([" "]).join("\n"), name, append: true }});
    }

    function deleteBullet(bulletIdx){
        const inputElements = document.getElementsByClassName(classId);
        const array = Array.from(inputElements).map(bullet => bullet.dataset.value);
        array.splice(bulletIdx, 1);
        setValue({ target: {value: array.join("\n"), name, removal: bulletIdx+1 }});
    }

    function move(bulletIdx, dir){
        const inputElements = document.getElementsByClassName(classId);
        const array = Array.from(inputElements).map(bullet => bullet.dataset.value);
        let [up, center, down] = [array[bulletIdx-1], array[bulletIdx], array[bulletIdx+1]];

        if(dir === "up" && bulletIdx >= 1){
            array[bulletIdx-1] = center;
            array[bulletIdx] = up;
        } else if(dir === "down" && array.length - 1 > bulletIdx ){
            array[bulletIdx+1] = center;
            array[bulletIdx] = down;
        }
        console.log("moving");
        setValue({ target: {value: array.join("\n"), name, move: [bulletIdx, dir]}});
    }

    return(
        <>
        <h3>{label}</h3>
            {bullets.map((bullet, bulletIdx) => <>
                <BulletPointInputItem idx={idx} bulletIdx={bulletIdx} name={name} type={type} value={bullet} onDelete={deleteBullet} onChange={bulletUpdate} move={move} />
                <br/>
            </>)}
            <div className="p-2 bpi-li" onClick={newBullet}>New Bullet <i className="fa-solid fa-plus"></i></div>

        </>
    )
}