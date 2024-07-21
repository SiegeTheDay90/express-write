import { useRef, useState } from 'react'
import React from 'react';
``
function IssueListItem({text, bullet, workItemIdx, bulletIdx, subIdx, type, setResume}){

    const liRef = useRef();
    function focusIn(e){
        const id = e.target.dataset.id;
        const previewLi = document.getElementById(id.slice(1));
        // Scroll into view preview Li
        previewLi.scrollIntoView({block: 'center', behavior: 'smooth'});
        previewLi.classList.add("border");
        previewLi.classList.add("border-primary");
    };

    function focusOut(e){
        const id = e.target.dataset.id;
        const previewLi = document.getElementById(id.slice(1));
        previewLi.classList.remove("border");
        previewLi.classList.remove("border-primary");
    }

    function dismiss(e){
        setResume(prev => {
            const workItem = prev.work[workItemIdx];
            const bullet = workItem.bullets[bulletIdx];

            if(type === "manual"){
                delete bullet.rating[subIdx];
            } else {
                bullet.rating.errors.splice(subIdx, 1);
            }

            bullet.rating.meta.total -= 1;

            return {
                ...prev
            }
        })
    }

    return (
        <li ref={liRef}
        onMouseEnter={focusIn} 
        onMouseLeave={focusOut} 
        className="bullet-issue" 
        data-id={"_"+bullet.rating?.meta.id}>
            {text} <br/> <span className="btn-group"><button style={{fontSize: "0.7em"}}className="btn btn-sm btn-primary" onClick={dismiss}>Dismiss</button><a href={`https://www.expresswrite.ai/bug-report?${new URLSearchParams({"error": `Reported Issue: ${text}`})}`} style={{fontSize: "0.7em"}}className="btn btn-sm btn-danger">Report</a></span>
        </li>
    );
}

export default IssueListItem
