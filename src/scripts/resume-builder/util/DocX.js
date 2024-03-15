import * as Docx from "docx";

export function shortDate(dateString) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const [month, day, year] = dateString.split('/');
    const readableDate = months[parseInt(month) - 1] + " " + year;
    return readableDate;
}

export default function generateDocx(resume) {
    const { personal, education, work, skills } = resume;

    
    // Personal Information
    const personalInfo = [
        `${personal.firstName.trim() || 'Jay'} ${personal.lastName.trim() || 'Doe'}`,
        personal.profession.trim() || '',
        personal.email.trim() || 'JayDoe@writewise.io',
        personal.phoneNumber.trim() || '',
        personal.website.trim() || ''
    ];

    const personalInfoItems = [
        new Docx.Paragraph({
            text: personalInfo[0],
            heading: Docx.HeadingLevel.HEADING_1,
            alignment: 'center'
        }),
        new Docx.Paragraph({
            text: personalInfo[1],
            heading: Docx.HeadingLevel.HEADING_3,
            alignment: 'center'
        }),
        new Docx.Paragraph({
            text: personalInfo[2],
            heading: Docx.HeadingLevel.HEADING_4,
            alignment: 'center'
        }),
        new Docx.Paragraph({
            text: personalInfo[3],
            heading: Docx.HeadingLevel.HEADING_4,
            alignment: 'center'
        }),
        new Docx.Paragraph({
            text: personalInfo[4],
            heading: Docx.HeadingLevel.HEADING_4,
            alignment: 'center'
        }),
    ]
    const educationItems = education.reduce((acc, val) => acc.concat(educationItem(val)), []);

    const workItems = work.reduce((acc, val) => acc.concat(workItem(val)), []);


    
    function educationItem(item){
        const to = item.to ? shortDate(new Date(item.to).toLocaleDateString('en-US')) : 'Present';
        const bullets = item.description?.split("\n").map((bullet)=>(
            new Docx.Paragraph({
                bullet: {level: 0},
                text: bullet
            })
        ))
        return [
            new Docx.Paragraph({
                tabStops: [
                    {type: "right", position: Docx.TabStopPosition.MAX}
                ],
                children: [
                    new Docx.TextRun({color: "000000", text: `${item.degreeType ? item.degreeType+' - ' : ''}${item.fieldOfStudy || ''}`}),
                    new Docx.TextRun({
                        color: "000000",
                        children: [new Docx.Tab(), `${to}`]
                    })
                ],
                heading: Docx.HeadingLevel.HEADING_2
            }),
            new Docx.Paragraph({
                text: {color: "000000", text: `${item.institutionName || 'School'}`,}
            }),
            ...bullets,
            new Docx.Paragraph({ })
        ]
    }
    function workItem(item){
        const from = item.from ? `${shortDate(new Date(item.from).toLocaleDateString('en-US'))} - ` : '';
        const to = item.to ? shortDate(new Date(item.from).toLocaleDateString('en-US')) : 'Present';
        const bullets = item.description?.split("\n").map((bullet)=>(
            new Docx.Paragraph({
                bullet: {level: 0},
                text: bullet
            })
        ))
        return [
            new Docx.Paragraph({
                tabStops: [
                    {type: "right", position: Docx.TabStopPosition.MAX}
                ],
                children: [
                    new Docx.TextRun({color: "000000", text: `${item.companyName || 'company'} - ${item.jobTitle || 'title'} `}),
                    new Docx.TextRun({
                        color: "000000",
                        children: [new Docx.Tab(), `${from}${to}`]
                    })
                
                ],
                heading: Docx.HeadingLevel.HEADING_2,
            }),
            new Docx.Paragraph({
                text: {color: "000000", text: `${item.city || 'City, State'}`},
            }),
            ...bullets,
            new Docx.Paragraph({ })
        ]
    }
    const content = ({
        properties: {},
        children: [
            ...personalInfoItems,
            new Docx.Paragraph({}),

            new Docx.Paragraph({text: "Professional Experience", heading: Docx.HeadingLevel.HEADING_1}),
            ...workItems,
            new Docx.Paragraph({}),

            new Docx.Paragraph({text: "Education", heading: Docx.HeadingLevel.HEADING_1}),
            ...educationItems,
            new Docx.Paragraph({}),

            new Docx.Paragraph({text: "Skills", heading: Docx.HeadingLevel.HEADING_1}),
            new Docx.Paragraph({text: skills.join(" | ")})
        ]
    });
    const doc = new Docx.Document({
        sections: [content],
        styles: {
            default: {
                document: {
                    run:{
                        size: "22pt",
                        font: "Calibri",
                        color: "000000"
                    }
                }
            }
        }
    });
    
    return doc;
}