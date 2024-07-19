import { useRef, useState } from 'react'
import React from 'react';
``
function IssueListItem({text, bullet, workItemIdx, bulletIdx, subIdx, type, setResume}){

    const liRef = useRef();
    function focusPreview(e){
        const id = e.target.dataset.id;
        const previewLi = document.getElementById(id.slice(1));
        // Scroll into view preview Li
        previewLi.scrollIntoView({block: 'center', behavior: 'smooth'});
        previewLi.classList.toggle("border");
        previewLi.classList.toggle("border-primary");
    };

    function dismiss(){

        setResume(prev => {
            const workItem = prev.work[workItemIdx];
            const bullet = workItem.bullets[bulletIdx];

            if(type === "manual"){
                delete bullet.rating[subIdx];
            } else {
                bullet.rating.errors.splice(subIdx, 1);
            }

            return {
                ...prev
            }
        })
    }

    return (
        <li ref={liRef}
        onMouseEnter={focusPreview} 
        onMouseLeave={focusPreview} 
        className="bullet-issue" 
        data-id={"_"+bullet.rating?.meta.id}>
            {text} <button onClick={dismiss}>Dismiss</button>
        </li>
    );
}

export default IssueListItem
