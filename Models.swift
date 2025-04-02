import Foundation

struct HealthTrend: Identifiable, Codable {
    let id: Int
    let illness: String
    let severity: String
    let trend: String
}

struct SymptomEntry: Identifiable, Codable {
    let id: Int
    let date: Date
    let severity: Double
    let symptoms: [String]
}

struct UserProfile: Codable {
    var name: String
    var occupation: String
    var region: String
    var age: Int
    var gender: Gender
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
        case preferNotToSay = "Prefer not to say"
    }
}

class IllnessEstimator {
    private let illnessPatterns: [String: [String]] = [
        "Common Cold": ["runny nose", "sore throat", "cough", "congestion", "sneezing", "fatigue", "mild fever", "watery eyes", "headache", "post-nasal drip", "mild body aches", "chills"],
        "Flu": ["high fever", "body aches", "chills", "fatigue", "cough", "sore throat", "headache", "nausea", "vomiting", "diarrhea", "loss of appetite", "muscle pain", "weakness", "sweating", "rapid onset"],
        "Stomach Bug": ["nausea", "vomiting", "diarrhea", "stomach cramps", "fever", "loss of appetite", "dehydration", "weakness", "headache", "muscle aches", "chills", "sweating", "rapid onset"],
        "Sinus Infection": ["facial pain", "congestion", "thick mucus", "cough", "headache", "fatigue", "fever", "bad breath", "tooth pain", "pressure in face", "post-nasal drip", "reduced sense of smell", "ear pressure"],
        "Bronchitis": ["cough", "mucus production", "wheezing", "chest discomfort", "fatigue", "shortness of breath", "fever", "chills", "body aches", "sore throat", "headache", "chest tightness", "rapid breathing"],
        "Strep Throat": ["severe sore throat", "painful swallowing", "red tonsils", "white patches", "fever", "headache", "nausea", "loss of appetite", "swollen lymph nodes", "rash", "body aches", "bad breath", "abdominal pain"],
        "Pneumonia": ["cough", "fever", "chills", "shortness of breath", "chest pain", "fatigue", "sweating", "rapid breathing", "confusion", "nausea", "vomiting", "diarrhea", "bluish lips", "rapid heartbeat"],
        "COVID-19": ["fever", "cough", "shortness of breath", "fatigue", "body aches", "loss of taste/smell", "sore throat", "headache", "diarrhea", "nausea", "vomiting", "chills", "congestion", "chest pain", "rapid breathing"],
        "Allergies": ["sneezing", "runny nose", "itchy eyes", "congestion", "post-nasal drip", "fatigue", "cough", "wheezing", "skin rash", "itchy throat", "watery eyes", "dark circles", "itchy ears", "seasonal pattern"],
        "Migraine": ["severe headache", "sensitivity to light", "nausea", "vomiting", "aura", "fatigue", "sensitivity to sound", "dizziness", "visual disturbances", "throbbing pain", "neck pain", "mood changes", "food cravings"],
        "Ear Infection": ["ear pain", "hearing loss", "fever", "fluid drainage", "headache", "irritability", "loss of balance", "trouble sleeping", "loss of appetite", "tugging at ear", "crying", "ear pressure", "fussiness"],
        "UTI": ["frequent urination", "burning sensation", "cloudy urine", "pelvic pain", "fever", "fatigue", "back pain", "nausea", "chills", "strong-smelling urine", "blood in urine", "urgency", "incomplete emptying"],
        "Food Poisoning": ["nausea", "vomiting", "diarrhea", "stomach cramps", "fever", "dehydration", "weakness", "loss of appetite", "headache", "chills", "sweating", "muscle aches", "rapid onset", "abdominal pain"],
        "RSV": ["cough", "wheezing", "runny nose", "fever", "shortness of breath", "fatigue", "decreased appetite", "rapid breathing", "bluish skin", "nasal flaring", "grunting", "chest retractions", "rapid heartbeat", "dehydration"],
        "Hand Foot Mouth": ["fever", "sore throat", "mouth sores", "rash on hands/feet", "loss of appetite", "irritability", "blisters", "painful swallowing", "headache", "body aches", "dehydration", "rash on buttocks", "drooling"],
        "Laryngitis": ["hoarse voice", "loss of voice", "sore throat", "dry cough", "fever", "fatigue", "difficulty speaking", "throat clearing", "tickling sensation", "swollen lymph nodes", "voice changes", "throat pain"],
        "Conjunctivitis": ["red eyes", "itchy eyes", "watery eyes", "eye discharge", "swollen eyelids", "sensitivity to light", "crusty eyelids", "gritty feeling", "blurred vision", "eye pain", "eye redness", "tearing"],
        "Bronchiolitis": ["wheezing", "rapid breathing", "cough", "fever", "runny nose", "decreased appetite", "fatigue", "difficulty breathing", "nasal flaring", "grunting", "chest retractions", "rapid heartbeat", "dehydration"],
        "Gastroenteritis": ["diarrhea", "nausea", "vomiting", "stomach cramps", "fever", "dehydration", "loss of appetite", "headache", "muscle aches", "chills", "weakness", "fatigue", "abdominal pain", "rapid onset"],
        "Tonsillitis": ["sore throat", "swollen tonsils", "difficulty swallowing", "fever", "headache", "bad breath", "stiff neck", "loss of voice", "ear pain", "white patches", "red tonsils", "swollen lymph nodes", "abdominal pain"],
        "Mononucleosis": ["fatigue", "sore throat", "fever", "swollen lymph nodes", "headache", "body aches", "loss of appetite", "swollen spleen", "rash", "night sweats", "weakness", "enlarged liver", "jaundice", "prolonged duration"],
        "Asthma": ["wheezing", "shortness of breath", "cough", "chest tightness", "rapid breathing", "fatigue", "anxiety", "sweating", "rapid heartbeat", "difficulty speaking", "blue lips", "triggered by allergens"],
        "Anxiety Attack": ["rapid heartbeat", "shortness of breath", "sweating", "trembling", "chest pain", "dizziness", "nausea", "fear", "rapid breathing", "tingling", "chills", "hot flashes", "triggered by stress"],
        "Dehydration": ["thirst", "dark urine", "fatigue", "dizziness", "dry mouth", "headache", "rapid heartbeat", "rapid breathing", "confusion", "irritability", "dry skin", "muscle cramps", "reduced urination"],
        "Heat Exhaustion": ["heavy sweating", "weakness", "dizziness", "nausea", "headache", "muscle cramps", "rapid heartbeat", "rapid breathing", "thirst", "confusion", "fainting", "pale skin", "triggered by heat"],
        "Panic Attack": ["rapid heartbeat", "shortness of breath", "sweating", "trembling", "chest pain", "dizziness", "nausea", "fear", "rapid breathing", "tingling", "chills", "hot flashes", "sense of doom"],
        "Hypoglycemia": ["shakiness", "sweating", "rapid heartbeat", "hunger", "confusion", "dizziness", "fatigue", "headache", "irritability", "anxiety", "blurred vision", "weakness", "triggered by low blood sugar"],
        "Hypertension": ["headache", "dizziness", "chest pain", "shortness of breath", "rapid heartbeat", "nausea", "fatigue", "anxiety", "sweating", "blurred vision", "nosebleeds", "irregular heartbeat"],
        "Anemia": ["fatigue", "weakness", "pale skin", "shortness of breath", "dizziness", "headache", "cold hands", "rapid heartbeat", "chest pain", "irritability", "brittle nails", "cravings", "prolonged symptoms"],
        "Thyroid Issues": ["fatigue", "weight changes", "rapid heartbeat", "sweating", "anxiety", "trembling", "hair loss", "sleep problems", "mood changes", "temperature sensitivity", "prolonged symptoms"],
        "Kidney Stones": ["severe pain", "nausea", "vomiting", "blood in urine", "frequent urination", "painful urination", "fever", "chills", "sweating", "back pain", "abdominal pain", "urgency", "cloudy urine"]
    ]
    
    private let recommendations: [String: [String]] = [
        "Common Cold": [
            "Rest and get plenty of sleep",
            "Stay hydrated with water and warm fluids",
            "Use over-the-counter cold medications",
            "Use a humidifier to ease congestion",
            "Gargle with warm salt water for sore throat",
            "Take vitamin C supplements",
            "Use nasal saline spray",
            "Avoid close contact with others"
        ],
        "Flu": [
            "Rest and stay in bed",
            "Take prescribed antiviral medications if available",
            "Stay hydrated with water and electrolyte drinks",
            "Use fever-reducing medications as needed",
            "Keep warm and avoid exposure to cold",
            "Monitor fever regularly",
            "Practice good hand hygiene",
            "Avoid physical exertion"
        ],
        "Stomach Bug": [
            "Stay hydrated with small sips of water",
            "Rest and avoid solid foods initially",
            "Gradually reintroduce bland foods",
            "Use anti-nausea medications if prescribed",
            "Practice good hand hygiene",
            "Use electrolyte drinks",
            "Avoid dairy products",
            "Monitor for dehydration"
        ],
        "Sinus Infection": [
            "Use saline nasal spray",
            "Take prescribed antibiotics if bacterial",
            "Use over-the-counter decongestants",
            "Apply warm compresses to face",
            "Stay hydrated",
            "Use a humidifier",
            "Avoid irritants",
            "Practice good hand hygiene"
        ],
        "Bronchitis": [
            "Rest and avoid irritants",
            "Use prescribed inhalers if needed",
            "Stay hydrated with warm fluids",
            "Use a humidifier",
            "Take prescribed medications",
            "Practice breathing exercises",
            "Avoid smoking",
            "Monitor breathing"
        ],
        "Strep Throat": [
            "Take prescribed antibiotics",
            "Rest voice",
            "Stay hydrated with warm fluids",
            "Use throat lozenges",
            "Practice good hand hygiene",
            "Avoid sharing utensils",
            "Use a humidifier",
            "Monitor fever"
        ],
        "Pneumonia": [
            "Take prescribed antibiotics",
            "Rest and avoid physical exertion",
            "Stay hydrated",
            "Use prescribed inhalers if needed",
            "Monitor oxygen levels",
            "Practice deep breathing",
            "Keep warm",
            "Seek emergency care if breathing worsens"
        ],
        "COVID-19": [
            "Isolate from others",
            "Rest and monitor symptoms",
            "Stay hydrated",
            "Take prescribed medications",
            "Monitor oxygen levels",
            "Practice good hand hygiene",
            "Wear a mask",
            "Seek emergency care if breathing worsens"
        ],
        "Allergies": [
            "Take prescribed antihistamines",
            "Use nasal sprays",
            "Avoid triggers",
            "Keep windows closed",
            "Use air purifier",
            "Wash bedding regularly",
            "Consider allergy shots",
            "Use eye drops"
        ],
        "Migraine": [
            "Rest in a dark, quiet room",
            "Take prescribed medications",
            "Apply cold or warm compress",
            "Stay hydrated",
            "Avoid triggers",
            "Practice stress management",
            "Consider acupuncture",
            "Use eye mask"
        ],
        "Ear Infection": [
            "Take prescribed antibiotics",
            "Use prescribed ear drops",
            "Apply warm compress",
            "Rest and avoid pressure changes",
            "Stay hydrated",
            "Use over-the-counter pain relievers",
            "Keep ears dry",
            "Avoid swimming"
        ],
        "UTI": [
            "Take prescribed antibiotics",
            "Stay hydrated",
            "Use heating pad for pain",
            "Avoid irritants",
            "Practice good hygiene",
            "Take probiotics",
            "Avoid caffeine",
            "Use cranberry supplements"
        ],
        "Food Poisoning": [
            "Stay hydrated with electrolyte drinks",
            "Rest and avoid solid foods initially",
            "Gradually reintroduce bland foods",
            "Practice good hand hygiene",
            "Monitor for dehydration",
            "Take probiotics",
            "Avoid dairy products",
            "Seek medical care if severe"
        ],
        "RSV": [
            "Rest and avoid irritants",
            "Stay hydrated",
            "Use prescribed medications",
            "Monitor breathing",
            "Practice good hand hygiene",
            "Use a humidifier",
            "Keep warm",
            "Seek emergency care if breathing worsens"
        ],
        "Hand Foot Mouth": [
            "Rest and stay hydrated",
            "Use pain relievers for fever",
            "Avoid acidic foods",
            "Practice good hand hygiene",
            "Keep blisters clean and dry",
            "Use soothing mouth rinses",
            "Avoid close contact",
            "Monitor for dehydration"
        ],
        "Laryngitis": [
            "Rest voice completely",
            "Stay hydrated",
            "Use a humidifier",
            "Avoid whispering",
            "Practice good hand hygiene",
            "Use throat lozenges",
            "Avoid irritants",
            "Use steam inhalation"
        ],
        "Conjunctivitis": [
            "Use prescribed eye drops",
            "Keep eyes clean",
            "Avoid touching eyes",
            "Practice good hand hygiene",
            "Use cool compresses",
            "Avoid makeup",
            "Don't share towels",
            "Wash hands frequently"
        ],
        "Bronchiolitis": [
            "Rest and monitor breathing",
            "Stay hydrated",
            "Use a humidifier",
            "Practice good hand hygiene",
            "Keep warm",
            "Monitor oxygen levels",
            "Avoid irritants",
            "Seek emergency care if breathing worsens"
        ],
        "Gastroenteritis": [
            "Stay hydrated with electrolyte drinks",
            "Rest and avoid solid foods",
            "Practice good hand hygiene",
            "Monitor for dehydration",
            "Take probiotics",
            "Avoid dairy products",
            "Gradually reintroduce foods",
            "Seek medical care if severe"
        ],
        "Tonsillitis": [
            "Take prescribed antibiotics",
            "Rest voice",
            "Stay hydrated",
            "Use throat lozenges",
            "Practice good hand hygiene",
            "Use a humidifier",
            "Avoid irritants",
            "Monitor fever"
        ],
        "Mononucleosis": [
            "Rest and avoid physical exertion",
            "Stay hydrated",
            "Use pain relievers as needed",
            "Practice good hand hygiene",
            "Avoid contact sports",
            "Monitor spleen size",
            "Get plenty of sleep",
            "Avoid alcohol"
        ]
    ]
    
    private let avoidActions: [String: [String]] = [
        "Common Cold": [
            "Avoid close contact with others",
            "Don't share personal items",
            "Avoid smoking and secondhand smoke",
            "Don't skip rest",
            "Avoid cold environments",
            "Don't touch face",
            "Avoid crowded places",
            "Don't skip fluids"
        ],
        "Flu": [
            "Avoid public places",
            "Don't share personal items",
            "Avoid physical exertion",
            "Don't skip prescribed medications",
            "Avoid cold environments",
            "Don't touch face",
            "Avoid crowds",
            "Don't skip rest"
        ],
        "Stomach Bug": [
            "Avoid solid foods initially",
            "Don't share food or drinks",
            "Avoid dairy products",
            "Don't skip hand washing",
            "Avoid public places",
            "Don't prepare food for others",
            "Avoid spicy foods",
            "Don't skip fluids"
        ],
        "Sinus Infection": [
            "Avoid irritants and allergens",
            "Don't skip prescribed medications",
            "Avoid swimming",
            "Don't blow nose too forcefully",
            "Avoid cold environments",
            "Don't smoke",
            "Avoid air travel",
            "Don't skip rest"
        ],
        "Bronchitis": [
            "Avoid smoking and secondhand smoke",
            "Don't skip prescribed medications",
            "Avoid cold air",
            "Don't overexert yourself",
            "Avoid irritants",
            "Don't skip rest",
            "Avoid crowds",
            "Don't skip fluids"
        ],
        "Strep Throat": [
            "Avoid sharing food and drinks",
            "Don't skip antibiotics",
            "Avoid spicy foods",
            "Don't strain voice",
            "Avoid close contact",
            "Don't share utensils",
            "Avoid cold foods",
            "Don't skip rest"
        ],
        "Pneumonia": [
            "Avoid physical exertion",
            "Don't skip prescribed medications",
            "Avoid cold environments",
            "Don't smoke",
            "Avoid crowds",
            "Don't skip rest",
            "Avoid air travel",
            "Don't skip fluids"
        ],
        "COVID-19": [
            "Avoid contact with others",
            "Don't skip isolation",
            "Avoid public places",
            "Don't share personal items",
            "Avoid physical exertion",
            "Don't touch face",
            "Avoid crowds",
            "Don't skip monitoring"
        ],
        "Allergies": [
            "Avoid known triggers",
            "Don't skip medications",
            "Avoid outdoor activities during high pollen",
            "Don't open windows",
            "Avoid pets if allergic",
            "Don't skip antihistamines",
            "Avoid fresh flowers",
            "Don't skip air purifier"
        ],
        "Migraine": [
            "Avoid bright lights",
            "Don't skip prescribed medications",
            "Avoid loud noises",
            "Don't skip meals",
            "Avoid known triggers",
            "Don't skip sleep",
            "Avoid strong smells",
            "Don't skip rest"
        ],
        "Ear Infection": [
            "Avoid water in ears",
            "Don't skip prescribed medications",
            "Avoid pressure changes",
            "Don't use cotton swabs",
            "Avoid loud noises",
            "Don't skip rest",
            "Avoid swimming",
            "Don't skip ear drops"
        ],
        "UTI": [
            "Avoid irritants",
            "Don't skip antibiotics",
            "Avoid tight clothing",
            "Don't hold urine",
            "Avoid caffeine",
            "Don't skip water",
            "Avoid bubble baths",
            "Don't skip hygiene"
        ],
        "Food Poisoning": [
            "Avoid solid foods initially",
            "Don't skip hand washing",
            "Avoid dairy products",
            "Don't share food",
            "Avoid public places",
            "Don't prepare food for others",
            "Avoid spicy foods",
            "Don't skip fluids"
        ],
        "RSV": [
            "Avoid close contact",
            "Don't skip prescribed medications",
            "Avoid irritants",
            "Don't share personal items",
            "Avoid physical exertion",
            "Don't skip rest",
            "Avoid crowds",
            "Don't skip monitoring"
        ],
        "Hand Foot Mouth": [
            "Avoid close contact",
            "Don't share personal items",
            "Avoid acidic foods",
            "Don't skip hand washing",
            "Avoid public places",
            "Don't share utensils",
            "Avoid spicy foods",
            "Don't skip fluids"
        ],
        "Laryngitis": [
            "Avoid talking",
            "Don't whisper",
            "Avoid cold air",
            "Don't skip rest",
            "Avoid irritants",
            "Don't strain voice",
            "Avoid crowds",
            "Don't skip fluids"
        ],
        "Conjunctivitis": [
            "Avoid touching eyes",
            "Don't share towels",
            "Avoid makeup",
            "Don't wear contacts",
            "Avoid bright lights",
            "Don't rub eyes",
            "Avoid swimming",
            "Don't skip eye drops"
        ],
        "Bronchiolitis": [
            "Avoid irritants",
            "Don't skip rest",
            "Avoid cold air",
            "Don't overexert",
            "Avoid crowds",
            "Don't smoke",
            "Avoid physical exertion",
            "Don't skip monitoring"
        ],
        "Gastroenteritis": [
            "Avoid solid foods",
            "Don't share food",
            "Avoid dairy products",
            "Don't skip hand washing",
            "Avoid public places",
            "Don't prepare food",
            "Avoid spicy foods",
            "Don't skip fluids"
        ],
        "Tonsillitis": [
            "Avoid talking",
            "Don't share utensils",
            "Avoid cold foods",
            "Don't skip antibiotics",
            "Avoid irritants",
            "Don't strain voice",
            "Avoid crowds",
            "Don't skip rest"
        ],
        "Mononucleosis": [
            "Avoid physical exertion",
            "Don't skip rest",
            "Avoid contact sports",
            "Don't share drinks",
            "Avoid alcohol",
            "Don't skip fluids",
            "Avoid crowded places",
            "Don't skip monitoring"
        ]
    ]
    
    func estimateIllness(currentSymptoms: [String], recentSymptoms: [[String]]) -> IllnessEstimate? {
        // If there are no symptoms at all, return nil
        if currentSymptoms.isEmpty && recentSymptoms.isEmpty {
            return nil
        }
        
        var bestMatch: (illness: String, confidence: Double, symptoms: [String])?
        var highestConfidence = 0.0
        
        // Combine current and recent symptoms
        let allSymptoms = Set(currentSymptoms + recentSymptoms.flatMap { $0 })
        
        for (illness, pattern) in illnessPatterns {
            let matchingSymptoms = allSymptoms.intersection(pattern)
            let confidence = Double(matchingSymptoms.count) / Double(pattern.count)
            
            // Require at least 3 matching symptoms for a valid estimate
            // For more serious conditions, require higher confidence
            let requiredConfidence = isSeriousCondition(illness) ? 0.5 : 0.4
            let requiredSymptoms = isSeriousCondition(illness) ? 4 : 3
            
            if confidence > highestConfidence && 
               matchingSymptoms.count >= requiredSymptoms && 
               confidence >= requiredConfidence {
                highestConfidence = confidence
                bestMatch = (illness, confidence, Array(matchingSymptoms))
            }
        }
        
        // Only return an estimate if we have a good match
        guard let match = bestMatch else { return nil }
        
        return IllnessEstimate(
            illness: match.illness,
            confidence: match.confidence,
            symptoms: match.symptoms,
            recommendations: recommendations[match.illness] ?? [],
            avoidActions: avoidActions[match.illness] ?? []
        )
    }
    
    private func isSeriousCondition(_ illness: String) -> Bool {
        let seriousConditions = [
            "Pneumonia", "COVID-19", "RSV", "Bronchiolitis",
            "Kidney Stones", "Hypertension", "Panic Attack",
            "Heat Exhaustion", "Dehydration", "Hypoglycemia"
        ]
        return seriousConditions.contains(illness)
    }
} 