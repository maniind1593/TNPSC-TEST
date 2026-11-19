TNPSC TWO-PLAYER QUIZ – MOBILE SETUP

இந்த starter project மூலம் இருவர் தனித்தனி மொபைலில் ஒரே website link வழியாக quiz எழுதலாம்.
இருவரும் submit செய்த பிறகே score மற்றும் விளக்கங்கள் வெளிவரும்.

A. SUPABASE SETUP
1. Supabase dashboard திறக்கவும்.
2. உங்கள் project-ல் SQL Editor -> New query செல்லவும்.
3. schema.sql கோப்பின் முழு உள்ளடக்கத்தையும் paste செய்து Run செய்யவும்.
4. Project Settings -> API (அல்லது API Keys) பகுதியில் Project URL மற்றும் anon/public key எடுக்கவும்.
5. config.js-ல் உள்ள placeholders-ஐ மாற்றவும்.
முக்கியம்: service_role / secret key-ஐ config.js-ல் ஒருபோதும் வைக்க வேண்டாம்.

B. GITHUB (PHONE)
1. GitHub app அல்லது browser-ல் New repository உருவாக்கவும் (Public).
2. index.html, config.js, schema.sql ஆகியவற்றை upload செய்யவும்.
3. README_TAMIL.txt-ஐயும் சேர்க்கலாம்.

C. NETLIFY PUBLISH
1. https://app.netlify.com/ திறந்து GitHub மூலம் sign in செய்யவும்.
2. Add new site -> Import an existing project தேர்வு செய்யவும்.
3. உங்கள் repository-ஐ தேர்ந்தெடுத்து Deploy செய்யவும்.
4. Netlify தரும் netlify.app URL தான் நண்பருக்கு அனுப்ப வேண்டிய link.

D. TEST
1. இருவரும் ஒரே Test Code (உதா: TNPSC01) பயன்படுத்தவும்.
2. தனித்தனி போனில் பெயர் கொடுத்து join செய்யவும்.
3. 10 கேள்விகளுக்கும் பதில் தேர்வு செய்து Submit செய்யவும்.
4. இருவரும் submit செய்த பிறகே இருவரின் score மற்றும் விளக்கங்கள் வெளியாகும்.

குறிப்பு:
- ஒரு Test Code-க்கு அதிகபட்சம் இரண்டு பங்கேற்பாளர்கள்.
- இந்த demo-வில் 10 மாதிரி கேள்விகள் உள்ளன.
- கேள்விகளை மாற்றும்போது index.html-இன் QUESTIONS மற்றும் schema.sql-இன் v_key/quiz_status answer-key ஆகியவற்றையும் பொருந்துமாறு மாற்ற வேண்டும்.
- இது அடிப்படை starter. அதிகாரப்பூர்வ தேர்வு அல்லது high-stakes proctoring system அல்ல.
