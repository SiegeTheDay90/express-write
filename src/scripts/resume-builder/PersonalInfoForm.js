import { useRef, useState } from 'react'
import React from 'react';

function PersonalInfoForm(){

    const [focus, setFocus] = useState(null);

    return (
        <form>
            <label htmlFor="first-name">Input Field</label>
            <input type="text" className="w-100"></input>
        </form>
    )
}

export default PersonalInfoForm
