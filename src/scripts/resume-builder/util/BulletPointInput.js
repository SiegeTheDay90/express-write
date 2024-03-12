import React, { useRef } from "react";
import "./BulletPointInput.scss"

export default function BulletPointInput({id, label, value, setValue}){
    const inputRef = useRef();
    const listRef = useRef();

    function leaveInput(){
        inputRef.current.classList.add("invisible");
        inputRef.current.classList.add("position-absolute");
        listRef.current.classList.remove("invisible");
        listRef.current.classList.remove("position-absolute");
    }

    function listClick(e){
        e.preventDefault();
        inputRef.current.classList.remove("invisible");
        inputRef.current.classList.remove("position-absolute");
        listRef.current.classList.add("invisible");
        listRef.current.classList.add("position-absolute");
        inputRef.current.focus();
    }

    return(
        <>
            <label htmlFor={id} onClick={listClick} className="ms-2 col-form-label" role="button">{label} (Bullet Points, separated by new-lines)</label>
            <textarea id={id} name={id} ref={inputRef} onBlur={leaveInput} className="ms-2 d-block invisible position-absolute form-control bg-light" value={value} onChange={setValue} />
            <ul className="w-100 form-control-sm bg-light ps-4 ms-2 bullet-list" ref={listRef} onClick={listClick} role="button">
                {
                    value.split("\n").map((item, idx) => (
                        item.trim() ? <li className={"bullet-point"} key={idx}>{item}</li> : null
                    ))
                }
            </ul>
        </>
    )
}