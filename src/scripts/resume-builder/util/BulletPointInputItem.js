import React, { useRef, useState, useEffect } from "react";
import "./BulletPointInput.scss"

export default function BulletPointInputItem({idx, name, type: uniqName, value: bullet, onDelete: deleteBullet, onChange: bulletUpdate, bulletIdx, move}){
    const [active, setActive] = useState(false);
    const [value, setValue] = useState(bullet.text);
    const [ratings, setRatings] = useState(bullet.rating);
    const didChange = useRef(false);
    const ref = useRef();
    const classId = uniqName+"_bullet_input_"+idx;

    useEffect(() => {
        ref.current?.focus();
    }, [active])

    useEffect(() => {
        setValue(bullet.text);
    }, [bullet]);

    function handleChange(e){
        e.target.dataset.value = JSON.stringify({text: e.target.value, rating: null})
        setValue(e.target.value);
        didChange.current = true;
    }

    if(!active){
        return (
            <div className="bpi-div d-flex mb-2">
                <div className="d-flex flex-column">
                    <li className={classId+" ms-4 me-1 mb-1 bpi-li p-2"} data-value={JSON.stringify(bullet)} tabIndex="0" onFocus={()=>setActive(true)}>{bullet.text}</li>
                    
                    {bullet.rating.suggestion ? 
                    <details className="ms-4">
                        <summary style={{fontSize: "smaller"}}>Suggestion

                        </summary>
                        <div style={{fontSize: "smaller"}} className="fst-italic ms-2 mb-2">{bullet.rating.suggestion}</div>
                    </details> : null}

                    {ratings.errors.length ?
                    <details className="ms-4">
                        <summary style={{fontSize: "smaller"}}>Issues ({ratings.errors.length})</summary>
                        {ratings.errors.map((error) => <li style={{fontSize: "smaller"}} className="ms-3">{error}</li>)}
                    </details> : null
                    }
                </div>
                <div className="btn-group">
                    <div className="btn btn-primary" onClick={()=>setActive(true)}>
                        <i className="fa-regular fa-pen-to-square"></i>
                    </div>
                    <div className="btn btn-danger" onClick={() => confirm("Delete this bullet?") ? deleteBullet(bulletIdx) : null}>
                        <i className="fa-solid fa-trash-can"></i>
                    </div>
                    {/*
                        <div className="btn btn-secondary" onClick={() => move(bulletIdx, "down")}>
                            <i className="fa-solid fa-arrow-down"></i>
                        </div>
                        <div className="btn btn-secondary" onClick={() => move(bulletIdx, "up")}>
                            <i className="fa-solid fa-arrow-up"></i>
                        </div>
                    */
                    }
                </div>
            </div>
        )
    } else {
        return <textarea name={name} ref={ref} className={classId+" ms-3 mb-2 p-2 w-100"} data-value={JSON.stringify(bullet)} value={value} onChange={handleChange} onKeyDown={(event) => {if(event.key === "Enter" ||event.keyCode === 13) event.preventDefault()}} onBlur={(e)=>{setActive(false); if(didChange.current) bulletUpdate(classId)}}/>

    }
}