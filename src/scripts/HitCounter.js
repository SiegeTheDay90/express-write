    import { initializeApp } from "firebase/app";
    import { getFirestore, doc, getDoc, setDoc} from "firebase/firestore";

    export default function HitCounter(document_name){
        const firebaseConfig = {
            _name: "HitCounter",
            authDomain: "hitcounter-c6795.firebaseapp.com",
            projectId: "hitcounter-c6795",
            storageBucket: "hitcounter-c6795.appspot.com",
            messagingSenderId: "337902042079",
            appId: "1:337902042079:web:f5396784d6cba619ed626a"
        };
        const app = initializeApp(firebaseConfig, "HitCounter");
        const db = getFirestore(app);

        // Returns the current count of particular counter
        HitCounter.getHits = async function(){
            const docRef = await doc(db, "Hits", document_name);
            let fetchedDoc = await getDoc(docRef);
            const data = fetchedDoc?.data() || {};
            return data;
        }
        
        // Increment existing or create new counter
        // Counters are organized by App then by Date
        HitCounter.inc = async function inc(){
            const date = new Date().toLocaleDateString("en-US").replaceAll("/", "-");
            const docRef = await doc(db, "Hits", document_name);
            let fetchedDoc = await getDoc(docRef);

            const data = fetchedDoc?.data() || {};
            data[date] ||= 0;
            data[date] += 1;

            setDoc(docRef, data)
            .catch((error) => console.error(error, `Hit Counter Send Error for ${document_name}`));
        }

        return HitCounter;
    }




