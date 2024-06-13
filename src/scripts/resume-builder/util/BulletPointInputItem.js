import React, { useRef, useState, useEffect } from "react";
import "./BulletPointInput.scss"

export default function BulletPointInputItem({idx, value: bullet, onChange: bulletUpdate}){
    const [active, setActive] = useState(false);
    const ref = useRef();

    useEffect(() => {
        ref.current?.focus();
    }, [active])

    if(!active){
        return <li class={idx+"_bullet_input ms-4"} value={bullet} tabindex="0" onFocus={()=>setActive(true)}>{bullet}</li>
    } else {
        return <textarea ref={ref} className={idx+"_bullet_input ms-3 mb-2 p-2 w-100"} value={bullet} onChange={bulletUpdate} onKeyDown={(event) => {if(event.key === "Enter" ||event.keyCode === 13) event.preventDefault()}} onBlur={()=>setActive(false)}/>

    }
}