import React, { useRef, useState, useEffect } from "react";
import "./BulletPointInput.scss"
import BulletPointInputItem from "./BulletPointInputItem";

export default function BulletPointInput({idx, name, type, label, bullets: bulletsArg, setValue}){
    const  [bullets, setBullets] = useState(bulletsArg || []);
    const classId = type+"_bullet_input_"+idx;

    useEffect(() => {
        setBullets(bulletsArg || []);
    }, [bulletsArg])


    // Each bullet should be an individual text input. 

    function bulletUpdate(idx){
        const inputElements = document.getElementsByClassName(classId);
        setValue({ target: {value: Array.from(inputElements).map(bullet => JSON.parse(bullet.dataset.value)), name }});
    }

    function newBullet(){
        const inputElements = document.getElementsByClassName(classId);
        setValue({ target: {value: Array.from(inputElements).map(bullet => JSON.parse(bullet.dataset.value)).concat([{text:"", rating: null}]), name }});
    }

    function deleteBullet(bulletIdx){
        const inputElements = document.getElementsByClassName(classId);
        const array = Array.from(inputElements).map(bullet => JSON.parse(bullet.dataset.value));
        array.splice(bulletIdx, 1);
        setValue({ target: {value: array, name}});
    }

    function move(bulletIdx, dir){
        const inputElements = document.getElementsByClassName(classId);
        const array = Array.from(inputElements).map(bullet => JSON.parse(bullet.dataset.value));
        let [up, center, down] = [array[bulletIdx-1], array[bulletIdx], array[bulletIdx+1]];

        if(dir === "up" && bulletIdx >= 1){
            array[bulletIdx-1] = center;
            array[bulletIdx] = up;
        } else if(dir === "down" && array.length - 1 > bulletIdx ){
            array[bulletIdx+1] = center;
            array[bulletIdx] = down;
        }
        setValue({ target: {value: array, name}});
    }

    return(
        <>
        <h3>{label}</h3>
            {bullets.map((bullet, bulletIdx) => <>
                <BulletPointInputItem idx={idx} bulletIdx={bulletIdx} name={name} type={type} value={bullet} onDelete={deleteBullet} onChange={bulletUpdate} move={move} />
            </>)}
            <div className="p-2 bpi-li" onClick={newBullet}>New Bullet <i className="fa-solid fa-plus"></i></div>

        </>
    )
}